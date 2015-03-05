CREATE OR REPLACE PACKAGE BODY utp_ts_run IS

  g_run_id NUMBER;
  gc_block_result_ok    CONSTANT VARCHAR2(10) := 'OK';
  gc_block_result_raise CONSTANT VARCHAR2(10) := 'RAISE';

  -- Kurzor pro nalezeni plsql bloku v ramci daneho test case
  CURSOR cur_tc_instance(p_test_case_id NUMBER) IS
    SELECT tc_i.plsql_block_id
          ,tc_i.test_case_id
          ,tc_i.block_order
          ,blk.owner
          ,blk.package
          ,blk.method
          ,blk.anonymous_block
          ,tc_i.output_param
          ,par.value
      FROM ut_plsql_block_in_case tc_i, ut_plsql_block blk, ut_input_param par
     WHERE tc_i.plsql_block_id = blk.id
       AND tc_i.input_param_id = par.id(+)
       AND tc_i.test_case_id = p_test_case_id
     ORDER BY tc_i.block_order;

  -- Kurzor pro nalezeni test casu v ramci daneho test scriptu
  CURSOR cur_tc_in_ts(p_test_cript_id NUMBER) IS
    SELECT ts_tc.test_script_id, ts_tc.test_case_id, ts_tc.catch_exception, ts_tc.expected_result
      FROM ut_test_case_in_script ts_tc
     WHERE ts_tc.test_script_id = p_test_cript_id
     ORDER BY ts_tc.script_order;

  exc_testcase EXCEPTION;

  -------------------------------------------------------------------------------------------------------------------------------
  PROCEDURE write_debug(p_info VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    -- prozatim je implementovan pouze vypis na output
    IF gc_debug = 'O' THEN
      dbms_output.put_line(p_info);
    END IF;
  END write_debug;

  -------------------------------------------------------------------------------------------------------------------------------
  PROCEDURE write_runlog(prec ut_plsql_block_run%ROWTYPE) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO ut_plsql_block_run
    VALUES
      (uts_plsql_block.nextval
      ,g_run_id
      ,prec.plsql_block_id
      ,prec.test_case_id
      ,prec.test_script_id
      ,prec.run_order
      ,prec.start_time
      ,prec.end_time
      ,prec.expected_result
      ,prec.result
      ,prec.param_xml
      ,prec.output_xml);
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('co se deje s logem');
  END write_runlog;

  -------------------------------------------------------------------------------------------------------------------------------
  PROCEDURE run_block
  (
    prec_tc_instance cur_tc_instance%ROWTYPE,
    p_xml            IN OUT xmltype,
    prec_runlog      IN ut_plsql_block_run%ROWTYPE
  ) IS
    l_template  VARCHAR2(32767) := 'BEGIN' || chr(10) ||
                                   '  #BLOCK#(p_xml_in => :1, r_xml_out => :2);' || chr(10) || 'END;';
    l_xml_in    xmltype;
    l_execute   VARCHAR2(32767);
    l_block     VARCHAR2(32767);
    lrec_runlog ut_plsql_block_run%ROWTYPE;
  BEGIN
    -- Priprava rowtype pro ulozeni infa o behu plsql bloku
    lrec_runlog                := prec_runlog;
    lrec_runlog.plsql_block_id := prec_tc_instance.plsql_block_id;
    lrec_runlog.test_case_id   := prec_tc_instance.test_case_id;
    lrec_runlog.run_order      := prec_tc_instance.block_order;

    -- skladani plsql bloku ke spusteni podle sablony
    IF prec_tc_instance.anonymous_block IS NULL THEN
      BEGIN
        IF prec_tc_instance.package IS NOT NULL THEN
          l_block := prec_tc_instance.owner || '.' || prec_tc_instance.package || '.' ||
                     prec_tc_instance.method;
        ELSE
          l_block := prec_tc_instance.owner || '.' || prec_tc_instance.method;
        END IF;
        l_execute := REPLACE(l_template, '#BLOCK#', l_block);
      END;
    ELSE
      l_execute := prec_tc_instance.anonymous_block;
    END IF;

    -- priprava vstupniho parametru
    IF prec_tc_instance.output_param = 'Y' THEN
      l_xml_in := p_xml;
    ELSE
      l_xml_in := prec_tc_instance.value;
    END IF;

    write_debug('    EXECUTE:' || l_block);
    IF l_xml_in IS NOT NULL THEN
      write_debug('    INPUT:' || substr(l_xml_in.getclobval, 1, 100));
    ELSE
      write_debug('    INPUT : NULL');
    END IF;
    lrec_runlog.param_xml  := l_xml_in;
    lrec_runlog.start_time := localtimestamp;

    -- nastaveni identifikatoru behu
    IF g_run_id IS NULL THEN
      g_run_id := uts_block_run_run_id.nextval;
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
    write_runlog(prec => lrec_runlog);
    IF p_xml IS NOT NULL THEN
      write_debug('    RETURN:' || substr(p_xml.getclobval, 1, 100));
    ELSE
      write_debug('    RETURN: NULL');
    END IF;
  END run_block;

  -------------------------------------------------------------------------------------------------------------------------------
  PROCEDURE run_testcase
  (
    prec        IN ut_test_case%ROWTYPE,
    prec_runlog IN ut_plsql_block_run%ROWTYPE DEFAULT NULL
  ) IS
    l_xml_inout xmltype;
  BEGIN
    write_debug('  TEST CASE:' || prec.code || '-' || prec.name || ' START');

    -- nastaveni identifikatoru behu
    IF g_run_id IS NULL THEN
      g_run_id := uts_block_run_run_id.nextval;
    END IF;

    FOR ii IN cur_tc_instance(p_test_case_id => prec.id)
    LOOP
      BEGIN
        run_block(prec_tc_instance => ii, p_xml => l_xml_inout, prec_runlog => prec_runlog);
      EXCEPTION
        WHEN OTHERS THEN
          write_debug('    FAILED:' || prec.code || '-' || prec.name || ' ' || SQLCODE || '-' ||
                      substr(SQLERRM, 1, 200));
          write_debug('  TEST CASE:' || prec.code || '-' || prec.name || ' FAILED END');
          RAISE exc_testcase;
      END;
    END LOOP;
    write_debug('  TEST CASE:' || prec.code || '-' || prec.name || ' END');
  END run_testcase;

  -------------------------------------------------------------------------------------------------------------------------------
  PROCEDURE run_testcase
  (
    p_id        ut_test_case.id%TYPE,
    prec_runlog IN ut_plsql_block_run%ROWTYPE DEFAULT NULL
  ) IS
    lrec_test_case ut_test_case%ROWTYPE;
  BEGIN
    SELECT * INTO lrec_test_case FROM ut_test_case WHERE Id = p_id;
    run_testcase(prec => lrec_test_case, prec_runlog => prec_runlog);
  END run_testcase;

  -------------------------------------------------------------------------------------------------------------------------------
  PROCEDURE run_testcase(p_id IN ut_test_case.id%TYPE) IS
    lrec_test_case ut_test_case%ROWTYPE;
  BEGIN
    SELECT * INTO lrec_test_case FROM ut_test_case WHERE Id = p_id;
    run_testcase(prec => lrec_test_case);
  END;

  -------------------------------------------------------------------------------------------------------------------------------
  PROCEDURE run_testcase(p_code ut_test_case.code%TYPE) IS
    lrec_test_case ut_test_case%ROWTYPE;
  BEGIN
    SELECT * INTO lrec_test_case FROM ut_test_case WHERE code = p_code;
    run_testcase(prec => lrec_test_case);
  END run_testcase;

  -------------------------------------------------------------------------------------------------------------------------------
  PROCEDURE run_testscript(prec ut_test_script%ROWTYPE) IS
    lrec_runlog ut_plsql_block_run%ROWTYPE;
  BEGIN
    write_debug('TEST SCRIPT:' || prec.code || '-' || prec.name || ' START');

    -- nastaveni identifikatoru behu
    g_run_id := uts_block_run_run_id.nextval;

    FOR ii IN cur_tc_in_ts(p_test_cript_id => prec.id)
    LOOP
      BEGIN
        -- Priprava rowtype pro ulozeni infa o behu plsql bloku
        lrec_runlog.test_script_id  := ii.test_script_id;
        lrec_runlog.expected_result := ii.expected_result;

        run_testcase(p_id => ii.test_case_id, prec_runlog => lrec_runlog);
      EXCEPTION
        WHEN exc_testcase THEN
          -- Pri vyjimce zpusobene behem test CASE rozhodnout jestli vyjimku potlacit pro moznost
          -- behu dalsich testovacich scenaru
          write_debug('  FAILED:' || prec.code || '-' || prec.name || ' ' || SQLCODE || '-' ||
                      substr(SQLERRM, 1, 200));
          IF ii.catch_exception = 'N' THEN
            raise_application_error(-20000,
                                    'Test script ' || prec.name || '- FAILED see error log');
          END IF;
        WHEN OTHERS THEN
          RAISE;
      END;
    END LOOP;

    write_debug('TEST SRIPT:' || prec.code || '-' || prec.name || ' END');
  END run_testscript;

  -------------------------------------------------------------------------------------------------------------------------------
  PROCEDURE run_testscript(p_id ut_test_script.id%TYPE) IS
    lrec_test_script ut_test_script%ROWTYPE;
  BEGIN
    SELECT * INTO lrec_test_script FROM ut_test_script WHERE Id = p_id;
    run_testscript(prec => lrec_test_script);
  END run_testscript;

  -------------------------------------------------------------------------------------------------------------------------------
  PROCEDURE run_testscript(p_code ut_test_script.code%TYPE) IS
    lrec_test_script ut_test_script%ROWTYPE;
  BEGIN
    SELECT * INTO lrec_test_script FROM ut_test_script WHERE code = p_code;
    run_testscript(prec => lrec_test_script);
  END run_testscript;

  -------------------------------------------------------------------------------------------------------------------------------
  PROCEDURE run_alltestscript(p_catch_exception VARCHAR2) IS
  BEGIN
    FOR ii IN (SELECT * FROM ut_test_script)
    LOOP
      BEGIN
        run_testscript(prec => ii);
      EXCEPTION
        WHEN OTHERS THEN
          IF p_catch_exception != 'Y' THEN
            RAISE;
          END IF;
      END;
    END LOOP;
  END run_alltestscript;

END utp_ts_run;
/

