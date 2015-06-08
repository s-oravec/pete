CREATE OR REPLACE PACKAGE BODY pete_configuration_runner IS

    -- Cursor used to find PLSQL block in test case
    -- NoFormat Start
    CURSOR gcur_test_case_instance(p_test_case_id NUMBER) IS
        WITH plsql_blocks AS
         (SELECT /*+ materialized */
                 blk.id,
                 blk.name,
                 blk.owner,
                 blk.package,
                 blk.method,
                 blk.anonymous_block,
                 bic.description,
                 bic.block_order,
                 bic.run_modifier,
                 inarg.value AS input,
                 er.value AS expected_output,
                 SUM(CASE WHEN bic.run_modifier = 'ONLY' THEN 1 ELSE 0 END) OVER() AS overall_block_only
            FROM pete_plsql_block_in_case bic,
                 pete_plsql_block         blk,
                 pete_input_argument      inarg,
                 pete_expected_result     er
           WHERE bic.test_case_id = p_test_case_id
             AND (bic.run_modifier != 'SKIP' OR bic.run_modifier IS NULL)
             AND inarg.id(+) = bic.input_argument_id
             AND er.id(+) = bic.expected_result_id
             AND blk.id = bic.plsql_block_id)
        SELECT id,
               NAME,
               owner,
               PACKAGE,
               method,
               anonymous_block,
               description,
               input,
               expected_output
          FROM plsql_blocks
         WHERE -- no ONLY run modifiers
               (overall_block_only = 0)
               -- or block has only modifier
            OR (run_modifier = 'ONLY')
         ORDER BY block_order;
        -- NoFormat End

    -- Cursor used to find test case in test script
    -- NoFormat Start
    CURSOR gcur_test_case_in_test_script(p_test_cript_id NUMBER) IS
        WITH test_cases AS
         (SELECT /*+ materialize */
          DISTINCT tc.*,
                   cis.case_order,
                   cis.run_modifier,
                   SUM(CASE WHEN cis.run_modifier = 'ONLY' THEN 1 ELSE 0 END) OVER() AS overall_case_only,
                   SUM(CASE WHEN bic.run_modifier = 'ONLY' THEN 1 ELSE 0 END) OVER() AS overall_block_only,
                   SUM(CASE WHEN bic.run_modifier = 'ONLY' THEN 1 ELSE 0 END) OVER(PARTITION BY tc.id) AS case_has_block_only
            FROM pete_test_case_in_script cis,
                 pete_test_case           tc,
                 pete_plsql_block_in_case bic
           WHERE cis.test_script_id = p_test_cript_id
             AND (cis.run_modifier != 'SKIP' OR cis.run_modifier IS NULL)
             AND bic.test_case_id = cis.test_case_id
             AND (bic.run_modifier != 'SKIP' OR bic.run_modifier IS NULL)
             AND tc.id = cis.test_case_id
           ORDER BY cis.case_order)
        SELECT id, NAME, description
          FROM test_cases
         WHERE --no ONLY run modifiers
               (overall_case_only = 0 AND overall_block_only = 0)
               --or case or its blocks have ONLY run modifier 
            OR (run_modifier = 'ONLY' OR case_has_block_only > 0)
         ORDER BY case_order;
        -- NoFormat End

    -- Cursor used to find test scripts to run
    -- NoFormat Start
    CURSOR gcur_test_scripts IS
        WITH test_scripts AS
         (SELECT /*+ materialize */ 
        DISTINCT ts.*,
                 SUM(CASE WHEN ts.run_modifier  = 'ONLY' THEN 1 ELSE 0 END) OVER() AS overall_script_only,
                 SUM(CASE WHEN cis.run_modifier = 'ONLY' THEN 1 ELSE 0 END) OVER() AS overall_case_only,
                 SUM(CASE WHEN bic.run_modifier = 'ONLY' THEN 1 ELSE 0 END) OVER() AS overall_block_only,
                 SUM(CASE WHEN cis.run_modifier = 'ONLY' THEN 1 ELSE 0 END) OVER (PARTITION BY ts.id) AS script_has_case_only,
                 SUM(CASE WHEN bic.run_modifier = 'ONLY' THEN 1 ELSE 0 END) OVER (PARTITION BY ts.id) AS script_has_block_only
            FROM pete_test_script         ts,
                 pete_test_case_in_script cis,
                 pete_plsql_block_in_case bic
           WHERE (ts.run_modifier != 'SKIP' OR ts.run_modifier IS NULL)
             AND cis.test_script_id = ts.id
             AND (cis.run_modifier != 'SKIP' OR cis.run_modifier IS NULL)
             AND bic.test_case_id = cis.test_case_id
             AND (bic.run_modifier != 'SKIP' OR bic.run_modifier IS NULL)
         )
        SELECT id, NAME, run_modifier, DESCRIPTION
          FROM test_scripts
         WHERE --no ONLY run modifiers
               (overall_script_only = 0 AND overall_case_only = 0 AND overall_block_only = 0)
               --or script or its case/block have ONLY run modifier
            OR (run_modifier = 'ONLY' OR script_has_case_only > 0 OR script_has_block_only > 0);
    -- NoFormat End

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
        pete_logger.trace('RUN_BLOCK: ' || 'a_parent_run_log_id_in:' ||
                          NVL(to_char(a_parent_run_log_id_in), 'NULL') ||
                          'block name : ' ||
                          nvl(a_block_instance_in_case_in.name, 'NULL'));
        IF a_block_instance_in_case_in.anonymous_block IS NULL
        THEN
        
            l_stored_procedure_name := CASE
                                           WHEN a_block_instance_in_case_in.owner IS NOT NULL THEN
                                            a_block_instance_in_case_in.owner || '.'
                                       END || CASE
                                           WHEN a_block_instance_in_case_in.package IS NOT NULL THEN
                                            a_block_instance_in_case_in.package || '.'
                                       END || a_block_instance_in_case_in.method;
        
            l_stored_procedure_name := dbms_assert.SQL_OBJECT_NAME(l_stored_procedure_name);
        
            l_plsql_block := REPLACE(l_plsql_block_template,
                                     '#StoredProcedureName#',
                                     l_stored_procedure_name);
        ELSE
            l_plsql_block := a_block_instance_in_case_in.anonymous_block;
        END IF;
        pete_logger.trace('l_plsql_block:' || l_plsql_block);
        -- execute plsql block
        BEGIN
            l_run_log_id := pete_core.begin_test(a_object_name_in       => a_block_instance_in_case_in.name,
                                                 a_object_type_in       => pete_core.g_OBJECT_TYPE_BLOCK,
                                                 a_description_in       => a_block_instance_in_case_in.description,
                                                 a_parent_run_log_id_in => a_parent_run_log_id_in);
            --
            EXECUTE IMMEDIATE l_plsql_block
                USING IN a_block_instance_in_case_in.input, OUT l_xml_out;
            --
            IF a_block_instance_in_case_in.expected_output IS NOT NULL
            THEN
                pete_logger.trace('block has expected_output - compare');
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
                pete_core.end_test(a_run_log_id_in => l_run_log_id,
                                   a_is_succes_in  => l_result,
                                   a_xml_in_in     => a_block_instance_in_case_in.input,
                                   a_xml_out_in    => l_xml_out,
                                   a_error_code_in => SQLCODE);
        END;
    
        pete_logger.trace('l_result ' || CASE WHEN l_result THEN 'TRUE' ELSE
                          'FALSE' END);
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
        FOR test_script IN gcur_test_scripts
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
