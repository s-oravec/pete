create or replace package body utp_ts_run is

  --test script run identifier
  g_run_id number;
  gc_block_result_ok    constant varchar2(10) := 'OK';
  gc_block_result_raise constant varchar2(10) := 'RAISE';

  -- Cursor used to find PLSQL block in test case
  cursor gcur_test_case_instance(p_test_case_id number) is
    select tc_i.plsql_block_id,
           tc_i.test_case_id,
           tc_i.block_order,
           blk.owner,
           blk.package,
           blk.method,
           blk.anonymous_block,
           tc_i.output_param,
           par.value
      from ut_plsql_block_in_case tc_i, ut_plsql_block blk, ut_input_param par
     where tc_i.plsql_block_id = blk.id
       and tc_i.input_param_id = par.id(+)
       and tc_i.test_case_id = p_test_case_id
     order by tc_i.block_order;

  -- Cursor used to find test case in test script
  cursor gcur_test_case_in_test_script(p_test_cript_id number) is
    select ts_tc.test_script_id, ts_tc.test_case_id, ts_tc.catch_exception, ts_tc.expected_result
      from ut_test_case_in_script ts_tc
     where ts_tc.test_script_id = p_test_cript_id
     order by ts_tc.script_order;

  exc_test_case exception;

  -------------------------------------------------------------------------------------------------------------------------------
  procedure debug(p_info varchar2) is
  begin
    dbms_output.put_line(p_info);
  end debug;

  -------------------------------------------------------------------------------------------------------------------------------
  procedure write_runlog(prec ut_plsql_block_run%rowtype) is
    pragma autonomous_transaction;
  begin
    insert into ut_plsql_block_run
    values
      (uts_plsql_block.nextval,
       g_run_id,
       prec.plsql_block_id,
       prec.test_case_id,
       prec.test_script_id,
       prec.run_order,
       prec.start_time,
       prec.end_time,
       prec.expected_result,
       prec.result,
       prec.param_xml,
       prec.output_xml);
    commit;
  exception
    when others then
      dbms_output.put_line('co se deje s logem');
  end write_runlog;

  -------------------------------------------------------------------------------------------------------------------------------
  procedure run_block
  (
    prec_tc_instance gcur_test_case_instance%rowtype,
    p_xml            in out xmltype,
    prec_runlog      in ut_plsql_block_run%rowtype
  ) is
    l_template  varchar2(32767) --
    := 'BEGIN' || chr(10) || --
       '  #BLOCK#(p_xml_in => :1, p_xml_out => :2);' || chr(10) || --
       'END;';
    l_xml_in    xmltype;
    l_execute   varchar2(32767);
    l_block     varchar2(32767);
    lrec_runlog ut_plsql_block_run%rowtype;
  begin
    -- Priprava rowtype pro ulozeni infa o behu plsql bloku
    lrec_runlog                := prec_runlog;
    lrec_runlog.plsql_block_id := prec_tc_instance.plsql_block_id;
    lrec_runlog.test_case_id   := prec_tc_instance.test_case_id;
    lrec_runlog.run_order      := prec_tc_instance.block_order;
  
    -- skladani plsql bloku ke spusteni podle sablony
    if prec_tc_instance.anonymous_block is null
    then
      begin
        if prec_tc_instance.package is not null
        then
          l_block := prec_tc_instance.owner || '.' || prec_tc_instance.package || '.' ||
                     prec_tc_instance.method;
        else
          l_block := prec_tc_instance.owner || '.' || prec_tc_instance.method;
        end if;
        l_execute := replace(l_template, '#BLOCK#', l_block);
      end;
    else
      l_execute := prec_tc_instance.anonymous_block;
    end if;
  
    -- priprava vstupniho parametru
    if prec_tc_instance.output_param = 'Y'
    then
      l_xml_in := p_xml;
    else
      l_xml_in := prec_tc_instance.value;
    end if;
  
    debug('    EXECUTE:' || l_block);
    if l_xml_in is not null
    then
      debug('    INPUT:' || substr(l_xml_in.getclobval, 1, 100));
    else
      debug('    INPUT : NULL');
    end if;
    lrec_runlog.param_xml  := l_xml_in;
    lrec_runlog.start_time := localtimestamp;
  
    -- nastaveni identifikatoru behu
    if g_run_id is null
    then
      g_run_id := uts_block_run_run_id.nextval;
    end if;
  
    --Spusteni plsql bloku
    begin
      execute immediate l_execute
        using in l_xml_in, out p_xml;
    exception
      when others then
        -- Pri chybe je nutne zapsat vysledek a chybu propagovat nahoru k vyreseni
        lrec_runlog.end_time := localtimestamp;
        lrec_runlog.result   := gc_block_result_raise;
        write_runlog(prec => lrec_runlog);
        raise;
    end;
    --zapis vysledku behu plsql bloku
    lrec_runlog.end_time   := localtimestamp;
    lrec_runlog.output_xml := p_xml;
    lrec_runlog.result     := gc_block_result_ok;
    write_runlog(prec => lrec_runlog);
    if p_xml is not null
    then
      debug('    RETURN:' || substr(p_xml.getclobval, 1, 100));
    else
      debug('    RETURN: NULL');
    end if;
  end run_block;

  -------------------------------------------------------------------------------------------------------------------------------
  procedure run_test_case
  (
    prec        in ut_test_case%rowtype,
    prec_runlog in ut_plsql_block_run%rowtype default null
  ) is
    l_xml_inout xmltype;
  begin
    debug('  TEST CASE:' || prec.code || '-' || prec.name || ' START');
  
    -- set global run identifier if not set
    if g_run_id is null
    then
      g_run_id := uts_block_run_run_id.nextval;
    end if;
  
    for ii in gcur_test_case_instance(p_test_case_id => prec.id)
    loop
      begin
        run_block(prec_tc_instance => ii, p_xml => l_xml_inout, prec_runlog => prec_runlog);
      exception
        when others then
          debug('    FAILED:' || prec.code || '-' || prec.name || ' ' || sqlcode || '-' ||
                substr(sqlerrm, 1, 200));
          debug('  TEST CASE:' || prec.code || '-' || prec.name || ' FAILED END');
          raise exc_test_case;
      end;
    end loop;
    debug('  TEST CASE:' || prec.code || '-' || prec.name || ' END');
  end run_test_case;

  -------------------------------------------------------------------------------------------------------------------------------
  procedure run_test_case
  (
    p_id        ut_test_case.id%type,
    prec_runlog in ut_plsql_block_run%rowtype default null
  ) is
    lrec_test_case ut_test_case%rowtype;
  begin
    select * into lrec_test_case from ut_test_case where id = p_id;
    run_test_case(prec => lrec_test_case, prec_runlog => prec_runlog);
  end run_test_case;

  -------------------------------------------------------------------------------------------------------------------------------
  procedure run_test_case(p_id in ut_test_case.id%type) is
    lrec_test_case ut_test_case%rowtype;
  begin
    select * into lrec_test_case from ut_test_case where id = p_id;
    run_test_case(prec => lrec_test_case);
  end;

  -------------------------------------------------------------------------------------------------------------------------------
  procedure run_test_case(p_code ut_test_case.code%type) is
    lrec_test_case ut_test_case%rowtype;
  begin
    select * into lrec_test_case from ut_test_case where code = p_code;
    run_test_case(prec => lrec_test_case);
  end run_test_case;

  -------------------------------------------------------------------------------------------------------------------------------
  procedure run_test_script(prec_test_script ut_test_script%rowtype) is
    lrec_run_log ut_plsql_block_run%rowtype;
  begin
    debug('TEST SCRIPT:' || prec_test_script.code || '-' || prec_test_script.name || ' START');
  
    -- set run identifier
    g_run_id := uts_block_run_run_id.nextval;
  
    for ii in gcur_test_case_in_test_script(p_test_cript_id => prec_test_script.id)
    loop
      begin
        -- prepare record for PLSQL block run log
        lrec_run_log.test_script_id  := ii.test_script_id;
        lrec_run_log.expected_result := ii.expected_result;
      
        run_test_case(p_id => ii.test_case_id, prec_runlog => lrec_run_log);
      exception
        when exc_test_case then
          debug('  FAILED:' || prec_test_script.code || '-' || prec_test_script.name || ' ' ||
                sqlcode || '-' || substr(sqlerrm, 1, 200));
          -- catch based on test case settings
          if ii.catch_exception = utp_ts_run.gc_false
          then
            raise_application_error(-20000,
                                    'Test script ' || prec_test_script.name ||
                                    '- FAILED see error log');
          end if;
        when others then
          raise;
      end;
    end loop;
  
    debug('TEST SRIPT:' || prec_test_script.code || '-' || prec_test_script.name || ' END');
  end run_test_script;

  -------------------------------------------------------------------------------------------------------------------------------
  procedure run_test_script(p_id ut_test_script.id%type) is
    lrec_test_script ut_test_script%rowtype;
  begin
    select * into lrec_test_script from ut_test_script where id = p_id;
    run_test_script(prec_test_script => lrec_test_script);
  end run_test_script;

  -------------------------------------------------------------------------------------------------------------------------------
  procedure run_test_script(p_code ut_test_script.code%type) is
    lrec_test_script ut_test_script%rowtype;
  begin
    select * into lrec_test_script from ut_test_script where code = p_code;
    run_test_script(prec_test_script => lrec_test_script);
  end run_test_script;

  -------------------------------------------------------------------------------------------------------------------------------
  procedure run_all_test_scripts(p_catch_exception in gtyp_string_boolean default gc_true) is
    l_catch_exception utp_ts_run.gtyp_string_boolean := nvl(p_catch_exception, gc_true);
  begin
    --
    -- serial
    -- loop through all test scripts
    for ii in (select * from ut_test_script)
    loop
      begin
        -- run test script
        run_test_script(prec_test_script => ii);
      exception
        when others then
          if l_catch_exception != gc_true
          then
            raise;
          end if;
      end;
    end loop;
  end run_all_test_scripts;

end utp_ts_run;
/
