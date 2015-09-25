CREATE OR REPLACE PACKAGE BODY pete_configuration_runner IS

    --TODO: move to pete_core???
    g_YES CONSTANT VARCHAR2(1) := 'Y';
    g_NO  CONSTANT VARCHAR2(1) := 'N';

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
                 bic.stop_on_failure,
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
               expected_output,
               stop_on_failure
          FROM plsql_blocks
         WHERE -- no ONLY run modifiers
               (overall_block_only = 0)
               -- or block has only modifier
            OR (run_modifier = 'ONLY')
         ORDER BY block_order;
        -- NoFormat End

    --TODO: add cursor for case in case for test case hierarchies

    -- Cursor used to find test case in test script
    -- NoFormat Start
    CURSOR gcur_test_case_in_test_suite(p_test_suite_id NUMBER) IS
        WITH test_cases AS
         (SELECT /*+ materialize */
          DISTINCT tc.*,
                   cis.case_order,
                   cis.stop_on_failure,
                   cis.run_modifier,
                   SUM(CASE WHEN cis.run_modifier = 'ONLY' THEN 1 ELSE 0 END) OVER() AS overall_case_only,
                   SUM(CASE WHEN bic.run_modifier = 'ONLY' THEN 1 ELSE 0 END) OVER() AS overall_block_only,
                   SUM(CASE WHEN bic.run_modifier = 'ONLY' THEN 1 ELSE 0 END) OVER(PARTITION BY tc.id) AS case_has_block_only
            FROM pete_test_case_in_suite  cis,
                 pete_test_case           tc, --TODO: add case_in_case for test case hierarchies
                 pete_plsql_block_in_case bic
           WHERE cis.test_suite_id = p_test_suite_id
             AND (cis.run_modifier != 'SKIP' OR cis.run_modifier IS NULL)
             AND bic.test_case_id = cis.test_case_id
             AND (bic.run_modifier != 'SKIP' OR bic.run_modifier IS NULL)
             AND tc.id = cis.test_case_id
           ORDER BY cis.case_order)
        SELECT id, NAME, description, stop_on_failure
          FROM test_cases
         WHERE --no ONLY run modifiers
               (overall_case_only = 0 AND overall_block_only = 0)
               --or case or its blocks have ONLY run modifier 
            OR (run_modifier = 'ONLY' OR case_has_block_only > 0)
         ORDER BY case_order;
        -- NoFormat End

    -- Cursor used to find test suites to run
    -- NoFormat Start
    CURSOR gcur_test_suites IS
        WITH test_suites AS
         (SELECT /*+ materialize */ 
        DISTINCT ts.*,
                 SUM(CASE WHEN ts.run_modifier  = 'ONLY' THEN 1 ELSE 0 END) OVER() AS overall_suite_only,
                 SUM(CASE WHEN cis.run_modifier = 'ONLY' THEN 1 ELSE 0 END) OVER() AS overall_case_only,
                 SUM(CASE WHEN bic.run_modifier = 'ONLY' THEN 1 ELSE 0 END) OVER() AS overall_block_only,
                 SUM(CASE WHEN cis.run_modifier = 'ONLY' THEN 1 ELSE 0 END) OVER (PARTITION BY ts.id) AS suite_has_case_only,
                 SUM(CASE WHEN bic.run_modifier = 'ONLY' THEN 1 ELSE 0 END) OVER (PARTITION BY ts.id) AS suite_has_block_only
            FROM pete_test_suite         ts,
                 pete_test_case_in_suite cis, --TODO: add case_in_case for test case hierarchies
                 pete_plsql_block_in_case bic
           WHERE (ts.run_modifier != 'SKIP' OR ts.run_modifier IS NULL)
             AND cis.test_suite_id = ts.id
             AND (cis.run_modifier != 'SKIP' OR cis.run_modifier IS NULL)
             AND bic.test_case_id = cis.test_case_id
             AND (bic.run_modifier != 'SKIP' OR bic.run_modifier IS NULL)
         )
        SELECT id, 
               name, 
               stop_on_failure,
               run_modifier, 
               description
          FROM test_suites
         WHERE --no ONLY run modifiers
               (overall_suite_only = 0 AND overall_case_only = 0 AND overall_block_only = 0)
               --or suite or its case/block have ONLY run modifier
            OR (run_modifier = 'ONLY' OR suite_has_case_only > 0 OR suite_has_block_only > 0);
    -- NoFormat End

    -------------------------------------------------------------------------------------------------------------------------------
    FUNCTION run_block
    (
        a_block_instance_in_case_in IN gcur_test_case_instance%ROWTYPE,
        a_parent_run_log_id_in      IN pete_run_log.parent_id%TYPE DEFAULT NULL
    ) RETURN pete_core.typ_execution_result IS
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
        l_result     pete_core.typ_execution_result := pete_core.g_SUCCESS;
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
            l_result := pete_core.g_SUCCESS;
            --
        EXCEPTION
            WHEN OTHERS THEN
                l_result := pete_core.g_FAILURE;
                pete_core.end_test(a_run_log_id_in       => l_run_log_id,
                                   a_execution_result_in => l_result,
                                   a_xml_in_in           => a_block_instance_in_case_in.input,
                                   a_xml_out_in          => l_xml_out,
                                   a_error_code_in       => SQLCODE);
        END;
    
        pete_logger.trace('l_result ' || l_result);
        RETURN l_result;
    
    END run_block;

    --TODO: implement case_in_case for test case hierarchies
    -------------------------------------------------------------------------------------------------------------------------------
    FUNCTION run_case
    (
        a_test_case_in         IN gcur_test_case_in_test_suite%ROWTYPE,
        a_parent_run_log_id_in IN pete_run_log.parent_id%TYPE DEFAULT NULL
    ) RETURN pete_core.typ_execution_result IS
        l_run_log_id pete_run_log.id%TYPE;
        l_result     pete_core.typ_execution_result := pete_core.g_SUCCESS;
    BEGIN
        l_run_log_id := pete_core.begin_test(a_object_name_in       => a_test_case_in.name,
                                             a_object_type_in       => pete_core.g_OBJECT_TYPE_CASE,
                                             a_description_in       => a_test_case_in.description,
                                             a_parent_run_log_id_in => a_parent_run_log_id_in);
    
        -- run all blocks in test case in order
        <<plblock_instances_in_test_case>>
        FOR plblock_instance_in_test_case IN gcur_test_case_instance(p_test_case_id => a_test_case_in.id)
        LOOP
            l_result := abs(run_block(a_block_instance_in_case_in => plblock_instance_in_test_case,
                                      a_parent_run_log_id_in      => l_run_log_id)) +
                        abs(l_result);
            --
            IF plblock_instance_in_test_case.stop_on_failure = g_YES
               AND NOT l_result = pete_core.g_SUCCESS
            THEN
                pete_logger.trace('RUN_CASE: stopping on failure');
                raise_application_error(-20000, 'Stopping on failure');
            END IF;
            --
        END LOOP plblock_instances_in_test_case;
    
        pete_core.end_test(a_run_log_id_in       => l_run_log_id,
                           a_execution_result_in => l_result);
        --
        RETURN l_result;
        --
    END run_case;

    --------------------------------------------------------------------------------  
    FUNCTION run_case
    (
        a_case_name_in         IN pete_core.typ_object_name,
        a_parent_run_log_id_in IN pete_run_log.parent_id%TYPE DEFAULT NULL
    ) RETURN pete_core.typ_execution_result IS
        lrec_test_case gcur_test_case_in_test_suite%ROWTYPE;
    BEGIN
        SELECT pete_test_case.*, g_NO AS stop_on_failure
          INTO lrec_test_case
          FROM pete_test_case
         WHERE NAME = a_case_name_in;
        --
        RETURN run_case(a_test_case_in         => lrec_test_case,
                        a_parent_run_log_id_in => a_parent_run_log_id_in);
        --
    END run_case;

    -------------------------------------------------------------------------------------------------------------------------------
    FUNCTION run_suite
    (
        a_test_suite_in        IN pete_test_suite%ROWTYPE,
        a_parent_run_log_id_in IN pete_run_log.parent_id%TYPE DEFAULT NULL
    ) RETURN pete_core.typ_execution_result IS
        l_result     pete_core.typ_execution_result := pete_core.g_SUCCESS;
        l_run_log_id pete_run_log.id%TYPE;
    BEGIN
        l_run_log_id := pete_core.begin_test(a_object_name_in       => a_test_suite_in.name,
                                             a_object_type_in       => pete_core.g_OBJECT_TYPE_SUITE,
                                             a_description_in       => a_test_suite_in.description,
                                             a_parent_run_log_id_in => a_parent_run_log_id_in);
    
        <<test_cases_in_test_suite>>
        FOR test_case_in_test_suite IN gcur_test_case_in_test_suite(p_test_suite_id => a_test_suite_in.id)
        LOOP
            l_result := abs(run_case(a_test_case_in         => test_case_in_test_suite,
                                     a_parent_run_log_id_in => l_run_log_id)) +
                        abs(l_result);
            --
            IF test_case_in_test_suite.stop_on_failure = g_YES
               AND NOT l_result = pete_core.g_SUCCESS
            THEN
                pete_logger.trace('RUN_SCRIPT: stopping on failure');
                raise_application_error(-20000, 'Stopping on failure');
            END IF;
            --
        END LOOP test_cases_in_test_suite;
        --
        pete_core.end_test(a_run_log_id_in       => l_run_log_id,
                           a_execution_result_in => l_result);
        --
        RETURN l_result;
        --
    END run_suite;

    -------------------------------------------------------------------------------------------------------------------------------
    FUNCTION run_suite
    (
        a_suite_name_in        IN pete_core.typ_object_name,
        a_parent_run_log_id_in IN pete_run_log.parent_id%TYPE DEFAULT NULL
    ) RETURN pete_core.typ_execution_result IS
        lrec_test_suite pete_test_suite%ROWTYPE;
    BEGIN
        SELECT *
          INTO lrec_test_suite
          FROM pete_test_suite
         WHERE NAME = a_suite_name_in;
        -- 
        RETURN run_suite(a_test_suite_in        => lrec_test_suite,
                         a_parent_run_log_id_in => a_parent_run_log_id_in);
        --
    END run_suite;

    -------------------------------------------------------------------------------------------------------------------------------
    FUNCTION run_all_test_suites(a_parent_run_log_id_in IN pete_run_log.parent_id%TYPE DEFAULT NULL)
        RETURN pete_core.typ_execution_result IS
        l_result pete_core.typ_execution_result := pete_core.g_SUCCESS;
    BEGIN
        <<test_suites_in_configuration>>
        FOR test_suite IN gcur_test_suites
        LOOP
            l_result := abs(run_suite(a_test_suite_in        => test_suite,
                                      a_parent_run_log_id_in => a_parent_run_log_id_in)) +
                        abs(l_result);
            IF test_suite.stop_on_failure = g_YES
               AND NOT l_result = pete_core.g_SUCCESS
            THEN
                pete_logger.trace('RUN_ALL_TEST_SCRIPTS: stopping on failure');
                raise_application_error(-20000, 'Stopping on failure');
            END IF;
        END LOOP test_suites_in_configuration;
        --
        RETURN l_result;
        --
    END run_all_test_suites;

END pete_configuration_runner;
/
