CREATE OR REPLACE PACKAGE BODY petep_configuration_runner IS

    --test script run identifier
    g_run_id NUMBER;
    gc_block_result_ok    CONSTANT VARCHAR2(10) := 'OK';
    gc_block_result_raise CONSTANT VARCHAR2(10) := 'RAISE';

    -- Cursor used to find PLSQL block in test case
    CURSOR gcur_test_case_instance(p_test_case_id NUMBER) IS
        SELECT tc_i.plsql_block_id,
               tc_i.test_case_id,
               tc_i.block_order,
               blk.owner,
               blk.package,
               blk.method,
               blk.anonymous_block,
               tc_i.output_param,
               inpar.value         input,
               outpar.value        output
          FROM pete_plsql_block_in_case tc_i,
               pete_plsql_block         blk,
               pete_input_param         inpar,
               pete_output_param        outpar
         WHERE tc_i.plsql_block_id = blk.id
           AND tc_i.input_param_id = inpar.id(+)
           AND tc_i.output_param = outpar.id(+)
           AND tc_i.test_case_id = p_test_case_id
         ORDER BY tc_i.block_order;

    -- Cursor used to find test case in test script
    CURSOR gcur_test_case_in_test_script(p_test_cript_id NUMBER) IS
        SELECT ts_tc.test_script_id,
               ts_tc.test_case_id,
               ts_tc.catch_exception,
               ts_tc.expected_result
          FROM pete_test_case_in_script ts_tc
         WHERE ts_tc.test_script_id = p_test_cript_id
         ORDER BY ts_tc.script_order;

    exc_test_case EXCEPTION;

    -------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE debug(p_info VARCHAR2) IS
    BEGIN
        --dbms_output.put_line(p_info);
        NULL;
    END debug;

    -------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE write_runlog(prec pete_plsql_block_run%ROWTYPE) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO pete_plsql_block_run
        VALUES
            (petes_plsql_block.nextval,
             g_run_id,
             prec.plsql_block_id,
             prec.test_case_id,
             prec.test_script_id,
             prec.run_order,
             prec.start_time,
             prec.end_time,
             prec.expected_result,
             prec.result,
             prec.input_xml,
             prec.output_xml,
             prec.error_code,
             prec.error_message);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('co se deje s logem');
    END write_runlog;

    -------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE run_block
    (
        prec_tc_instance gcur_test_case_instance%ROWTYPE,
        p_xml            IN OUT xmltype,
        prec_runlog      IN pete_plsql_block_run%ROWTYPE
    ) IS
        l_template  VARCHAR2(32767) --
        := 'BEGIN' || chr(10) || --
           '  #BLOCK#(p_xml_in => :1, p_xml_out => :2);' || chr(10) || --
           'END;';
        l_xml_in    xmltype;
        l_execute   VARCHAR2(32767);
        l_block     VARCHAR2(32767);
        lrec_runlog pete_plsql_block_run%ROWTYPE;
    BEGIN
        -- Priprava rowtype pro ulozeni infa o behu plsql bloku
        lrec_runlog                := prec_runlog;
        lrec_runlog.plsql_block_id := prec_tc_instance.plsql_block_id;
        lrec_runlog.test_case_id   := prec_tc_instance.test_case_id;
        lrec_runlog.run_order      := prec_tc_instance.block_order;
    
        -- skladani plsql bloku ke spusteni podle sablony
        IF prec_tc_instance.anonymous_block IS NULL
        THEN
            BEGIN
                IF prec_tc_instance.package IS NOT NULL
                THEN
                    l_block := prec_tc_instance.owner || '.' ||
                               prec_tc_instance.package || '.' ||
                               prec_tc_instance.method;
                ELSE
                    l_block := prec_tc_instance.owner || '.' ||
                               prec_tc_instance.method;
                END IF;
                l_execute := REPLACE(l_template, '#BLOCK#', l_block);
            END;
        ELSE
            l_execute := prec_tc_instance.anonymous_block;
        END IF;
    
        -- priprava vstupniho parametru
        IF prec_tc_instance.output_param = 'Y'
        THEN
            l_xml_in := p_xml;
        ELSE
            l_xml_in := prec_tc_instance.input;
        END IF;
    
        debug('    EXECUTE:' || l_block);
        IF l_xml_in IS NOT NULL
        THEN
            debug('    INPUT:' || substr(l_xml_in.getclobval, 1, 100));
        ELSE
            debug('    INPUT : NULL');
        END IF;
        lrec_runlog.input_xml  := l_xml_in;
        lrec_runlog.start_time := localtimestamp;
        --    lrec_runlog.output_xml 
    
        -- nastaveni identifikatoru behu
        IF g_run_id IS NULL
        THEN
            g_run_id := petes_block_run_run_id.nextval;
        END IF;
    
        --Spusteni plsql bloku
        BEGIN
            EXECUTE IMMEDIATE l_execute
                USING IN l_xml_in, OUT p_xml;
        EXCEPTION
            WHEN OTHERS THEN
                -- Pri chybe je nutne zapsat vysledek a chybu propagovat nahoru k vyreseni
                lrec_runlog.end_time := localtimestamp;
                lrec_runlog.result   := gc_block_result_raise;
                write_runlog(prec => lrec_runlog);
                RAISE;
        END;
        --zapis vysledku behu plsql bloku
        lrec_runlog.end_time   := localtimestamp;
        lrec_runlog.output_xml := p_xml;
        lrec_runlog.result     := gc_block_result_ok;
        --dbms_output.put_line('debug ' || prec_tc_instance.output.getclobval());
        --dbms_output.put_line('debug ' || p_xml.getclobval());    
        petep_assert.eq(a_expected_in => prec_tc_instance.output,
                        a_actual_in   => p_xml,
                        a_comment_in  => 'assert vysledku parametricky');
        write_runlog(prec => lrec_runlog);
        IF p_xml IS NOT NULL
        THEN
            debug('    RETURN:' || substr(p_xml.getclobval, 1, 100));
        ELSE
            debug('    RETURN: NULL');
        END IF;
    END run_block;

    -------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE run_case
    (
        prec        IN pete_test_case%ROWTYPE,
        prec_runlog IN pete_plsql_block_run%ROWTYPE DEFAULT NULL
    ) IS
        l_xml_inout xmltype;
    BEGIN
        debug('  TEST CASE:' || prec.code || '-' || prec.name || ' START');
        petep_logger.init; --todo zde bude  pripadnem volani ne primo, ale z test script
    
        -- set global run identifier if not set
        IF g_run_id IS NULL
        THEN
            g_run_id := petes_block_run_run_id.nextval;
        END IF;
    
        FOR ii IN gcur_test_case_instance(p_test_case_id => prec.id)
        LOOP
            BEGIN
                run_block(prec_tc_instance => ii,
                          p_xml            => l_xml_inout,
                          prec_runlog      => prec_runlog);
            EXCEPTION
                WHEN OTHERS THEN
                    debug('    FAILED:' || prec.code || '-' || prec.name || ' ' ||
                          SQLCODE || '-' || substr(SQLERRM, 1, 200));
                    debug('  TEST CASE:' || prec.code || '-' || prec.name ||
                          ' FAILED END');
                    RAISE exc_test_case;
            END;
        END LOOP;
        debug('  TEST CASE:' || prec.code || '-' || prec.name || ' END');
        petep_logger.print_result;
    
    END run_case;

    -------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE run_case
    (
        p_id        pete_test_case.id%TYPE,
        prec_runlog IN pete_plsql_block_run%ROWTYPE DEFAULT NULL
    ) IS
        lrec_test_case pete_test_case%ROWTYPE;
    BEGIN
        SELECT * INTO lrec_test_case FROM pete_test_case WHERE id = p_id;
        run_case(prec => lrec_test_case, prec_runlog => prec_runlog);
    END run_case;

    -------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE run_case(p_id IN pete_test_case.id%TYPE) IS
        lrec_test_case pete_test_case%ROWTYPE;
    BEGIN
        SELECT * INTO lrec_test_case FROM pete_test_case WHERE id = p_id;
        run_case(prec => lrec_test_case);
    END;

    -------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE run_case(p_code pete_test_case.code%TYPE) IS
        lrec_test_case pete_test_case%ROWTYPE;
    BEGIN
        SELECT * INTO lrec_test_case FROM pete_test_case WHERE code = p_code;
        run_case(prec => lrec_test_case);
    END run_case;

    -------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE run_script(prec_test_script pete_test_script%ROWTYPE) IS
        lrec_run_log pete_plsql_block_run%ROWTYPE;
    BEGIN
        debug('TEST SCRIPT:' || prec_test_script.code || '-' ||
              prec_test_script.name || ' START');
    
        -- set run identifier
        g_run_id := petes_block_run_run_id.nextval;
    
        FOR ii IN gcur_test_case_in_test_script(p_test_cript_id => prec_test_script.id)
        LOOP
            BEGIN
                -- prepare record for PLSQL block run log
                lrec_run_log.test_script_id  := ii.test_script_id;
                lrec_run_log.expected_result := ii.expected_result;
            
                run_case(p_id => ii.test_case_id, prec_runlog => lrec_run_log);
            EXCEPTION
                WHEN exc_test_case THEN
                    debug('  FAILED:' || prec_test_script.code || '-' ||
                          prec_test_script.name || ' ' || SQLCODE || '-' ||
                          substr(SQLERRM, 1, 200));
                    -- catch based on test case settings
                    IF ii.catch_exception = gc_false
                    THEN
                        raise_application_error(-20000,
                                                'Test script ' ||
                                                prec_test_script.name ||
                                                '- FAILED see error log');
                    END IF;
                WHEN OTHERS THEN
                    RAISE;
            END;
        END LOOP;
    
        debug('TEST SRIPT:' || prec_test_script.code || '-' ||
              prec_test_script.name || ' END');
    END run_script;

    -------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE run_script(p_id pete_test_script.id%TYPE) IS
        lrec_test_script pete_test_script%ROWTYPE;
    BEGIN
        SELECT * INTO lrec_test_script FROM pete_test_script WHERE id = p_id;
        run_script(prec_test_script => lrec_test_script);
    END run_script;

    -------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE run_script(p_code pete_test_script.code%TYPE) IS
        lrec_test_script pete_test_script%ROWTYPE;
    BEGIN
        SELECT *
          INTO lrec_test_script
          FROM pete_test_script
         WHERE code = p_code;
        run_script(prec_test_script => lrec_test_script);
    END run_script;

    -------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE run_all_test_scripts(p_catch_exception IN gtyp_string_boolean DEFAULT gc_true) IS
        l_catch_exception gtyp_string_boolean := nvl(p_catch_exception, gc_true);
    BEGIN
        --
        -- serial
        -- loop through all test scripts
        FOR ii IN (SELECT * FROM pete_test_script)
        LOOP
            BEGIN
                -- run test script
                run_script(prec_test_script => ii);
            EXCEPTION
                WHEN OTHERS THEN
                    IF l_catch_exception != gc_true
                    THEN
                        RAISE;
                    END IF;
            END;
        END LOOP;
    END run_all_test_scripts;

    --------------------------------------------------------------------------------
    PROCEDURE run_suite(a_suite_name_in IN VARCHAR2) IS
    BEGIN
        raise_application_error(-20000,
                                'Not implemented - [petep_configuration_runner.run_suite]');
    END run_suite;

END petep_configuration_runner;
/
