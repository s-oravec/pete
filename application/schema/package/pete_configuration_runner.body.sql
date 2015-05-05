CREATE OR REPLACE PACKAGE BODY pete_configuration_runner IS

    -- Cursor used to find PLSQL block in test case
    CURSOR gcur_test_case_instance(p_test_case_id NUMBER) IS
        SELECT tc_i.plsql_block_id,
               tc_i.test_case_id,
               tc_i.block_order,
               tc.name             AS test_case_name,
               blk.name            AS block_name,
               blk.owner,
               blk.package,
               blk.method,
               blk.anonymous_block,
               inpar.value         input,
               outpar.value        expected_output
          FROM pete_plsql_block_in_case tc_i,
               pete_plsql_block         blk,
               pete_input_param         inpar,
               pete_output_param        outpar,
               pete_test_case           tc
         WHERE tc_i.plsql_block_id = blk.id
           AND tc_i.input_param_id = inpar.id(+)
           AND tc_i.output_param_id = outpar.id(+)
           AND tc_i.test_case_id = p_test_case_id
           AND tc.id = tc_i.test_case_id
         ORDER BY tc_i.block_order;

    -- Cursor used to find test case in test script
    CURSOR gcur_test_case_in_test_script(p_test_cript_id NUMBER) IS
        SELECT tc.*
          FROM pete_test_case_in_script ts_tc, pete_test_case tc
         WHERE ts_tc.test_script_id = p_test_cript_id
           AND tc.id = ts_tc.test_case_id
         ORDER BY ts_tc.script_order;

    -------------------------------------------------------------------------------------------------------------------------------
    FUNCTION run_block
    (
        a_block_instance_in_case_in IN gcur_test_case_instance%ROWTYPE,
        a_parent_run_log_id_in      IN pete_run_log.parent_id%TYPE DEFAULT NULL
    ) RETURN pete_core.typ_is_success IS
        --
        l_plsql_block_template  VARCHAR2(32767) --
        := 'BEGIN' || chr(10) || --
           '  #StoredProcedureName#(a_xml_in => :1, a_xml_out => :2);' ||
           chr(10) || --
           'END;';
        l_plsql_block           VARCHAR2(32767);
        l_stored_procedure_name VARCHAR2(32767);
        --
        l_xml_out xmltype;
        --
        l_run_log_id pete_run_log.id%TYPE;
        l_result     pete_core.typ_is_success := TRUE;
    BEGIN
        -- create anonymous plsql block
        IF a_block_instance_in_case_in.anonymous_block IS NULL
        THEN
            BEGIN
                IF a_block_instance_in_case_in.package IS NOT NULL
                THEN
                    l_stored_procedure_name := a_block_instance_in_case_in.owner || '.' ||
                                               a_block_instance_in_case_in.package || '.' ||
                                               a_block_instance_in_case_in.method;
                ELSE
                    l_stored_procedure_name := a_block_instance_in_case_in.owner || '.' ||
                                               a_block_instance_in_case_in.method;
                END IF;
                l_plsql_block := REPLACE(l_plsql_block_template,
                                         '#StoredProcedureName#',
                                         l_stored_procedure_name);
            END;
        ELSE
            l_plsql_block := a_block_instance_in_case_in.anonymous_block;
        END IF;
    
        -- execute plsql block
        BEGIN
            l_run_log_id := pete_core.begin_test(a_object_name_in       => a_block_instance_in_case_in.test_case_name,
                                                 a_object_type_in       => pete_core.g_OBJECT_TYPE_BLOCK,
                                                 a_description_in       => a_block_instance_in_case_in.block_name,
                                                 a_parent_run_log_id_in => a_parent_run_log_id_in);
            --
            EXECUTE IMMEDIATE l_plsql_block
                USING IN a_block_instance_in_case_in.input, OUT l_xml_out;
            --
            IF a_block_instance_in_case_in.expected_output IS NOT NULL
            THEN
                pete_assert.eq(a_expected_in => a_block_instance_in_case_in.expected_output,
                               a_actual_in   => l_xml_out,
                               a_comment_in  => 'Expected PLSQL block result');
            END IF;
            --
            pete_core.end_test(a_run_log_id_in => l_run_log_id,
                               a_xml_in_in     => a_block_instance_in_case_in.input,
                               a_xml_out_in    => l_xml_out);
            l_result := TRUE;
            --
        EXCEPTION
            WHEN OTHERS THEN
                l_result := FALSE;
                pete_core.end_test(a_run_log_id_in    => l_run_log_id,
                                   a_is_succes_in     => l_result,
                                   a_xml_in_in        => a_block_instance_in_case_in.input,
                                   a_xml_out_in       => l_xml_out,
                                   a_error_code_in    => SQLCODE,
                                   a_error_message_in => dbms_utility.format_error_backtrace);
        END;
    
        RETURN l_result;
    
    END run_block;

    -------------------------------------------------------------------------------------------------------------------------------
    FUNCTION run_case
    (
        a_test_case_in         IN pete_test_case%ROWTYPE,
        a_parent_run_log_id_in IN pete_run_log.parent_id%TYPE DEFAULT NULL
    ) RETURN pete_core.typ_is_success IS
        l_run_log_id pete_run_log.id%TYPE;
        l_result     pete_core.typ_is_success := TRUE;
    BEGIN
        l_run_log_id := pete_core.begin_test(a_object_name_in       => a_test_case_in.name,
                                             a_object_type_in       => pete_core.g_OBJECT_TYPE_CASE,
                                             a_description_in       => a_test_case_in.description,
                                             a_parent_run_log_id_in => a_parent_run_log_id_in);
    
        -- run all blocks in test case in order
        <<plblock_instances_in_test_case>>
        FOR plblock_instance_in_test_case IN gcur_test_case_instance(p_test_case_id => a_test_case_in.id)
        LOOP
            l_result := run_block(a_block_instance_in_case_in => plblock_instance_in_test_case,
                                  a_parent_run_log_id_in      => l_run_log_id) AND
                        l_result;
        END LOOP plblock_instances_in_test_case;
    
        pete_core.end_test(a_run_log_id_in => l_run_log_id,
                           a_is_succes_in  => l_result);
        --
        RETURN l_result;
        --
    END run_case;

    --------------------------------------------------------------------------------  
    FUNCTION run_case
    (
        a_case_name_in         IN pete_core.typ_object_name,
        a_parent_run_log_id_in IN pete_run_log.parent_id%TYPE DEFAULT NULL
    ) RETURN pete_core.typ_is_success IS
        lrec_test_case pete_test_case%ROWTYPE;
    BEGIN
        SELECT *
          INTO lrec_test_case
          FROM pete_test_case
         WHERE NAME = a_case_name_in;
        RETURN run_case(a_test_case_in         => lrec_test_case,
                        a_parent_run_log_id_in => a_parent_run_log_id_in);
    END run_case;

    -------------------------------------------------------------------------------------------------------------------------------
    FUNCTION run_script
    (
        a_test_script_in       IN pete_test_script%ROWTYPE,
        a_parent_run_log_id_in IN pete_run_log.parent_id%TYPE DEFAULT NULL
    ) RETURN pete_core.typ_is_success IS
        l_result     pete_core.typ_is_success := TRUE;
        l_run_log_id pete_run_log.id%TYPE;
    BEGIN
        l_run_log_id := pete_core.begin_test(a_object_name_in       => a_test_script_in.name,
                                             a_object_type_in       => pete_core.g_OBJECT_TYPE_SCRIPT,
                                             a_description_in       => a_test_script_in.description,
                                             a_parent_run_log_id_in => a_parent_run_log_id_in);
    
        <<test_cases_in_test_script>>
        FOR test_case_in_test_script IN gcur_test_case_in_test_script(p_test_cript_id => a_test_script_in.id)
        LOOP
            l_result := run_case(a_test_case_in         => test_case_in_test_script,
                                 a_parent_run_log_id_in => l_run_log_id) AND
                        l_result;
        END LOOP test_cases_in_test_script;
    
        pete_core.end_test(a_run_log_id_in => l_run_log_id,
                           a_is_succes_in  => l_result);
        --
        RETURN l_result;
        --
    END run_script;

    -------------------------------------------------------------------------------------------------------------------------------
    FUNCTION run_script
    (
        a_script_name_in       IN pete_core.typ_object_name,
        a_parent_run_log_id_in IN pete_run_log.parent_id%TYPE DEFAULT NULL
    ) RETURN pete_core.typ_is_success IS
        lrec_test_script pete_test_script%ROWTYPE;
    BEGIN
        SELECT *
          INTO lrec_test_script
          FROM pete_test_script
         WHERE NAME = a_script_name_in;
        RETURN run_script(a_test_script_in       => lrec_test_script,
                          a_parent_run_log_id_in => a_parent_run_log_id_in);
    END run_script;

    -------------------------------------------------------------------------------------------------------------------------------
    FUNCTION run_all_test_scripts RETURN pete_core.typ_is_success IS
        l_result pete_core.typ_is_success := TRUE;
    BEGIN
        <<test_scripts_in_configuration>>
        FOR test_script IN (SELECT * FROM pete_test_script)
        LOOP
            l_result := run_script(a_test_script_in => test_script) AND
                        l_result;
        END LOOP test_scripts_in_configuration;
    
        RETURN l_result;
    
    END run_all_test_scripts;

    --------------------------------------------------------------------------------
    FUNCTION run_suite
    (
        a_suite_name_in        IN pete_core.typ_object_name,
        a_parent_run_log_id_in IN pete_run_log.parent_id%TYPE DEFAULT NULL
    ) RETURN pete_core.typ_is_success IS
    BEGIN
        raise_application_error(-20000,
                                'Not implemented - [pete_configuration_runner.run_suite]');
        RETURN FALSE;
    END run_suite;

END pete_configuration_runner;
/
