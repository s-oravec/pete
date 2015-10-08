CREATE OR REPLACE PACKAGE BODY pete_convention_runner AS

    --
    --wrapper for dynamic SQL
    --
    PROCEDURE execute_sql(a_sql_in IN VARCHAR2) IS
    BEGIN
        pete_logger.trace(a_trace_message_in => 'EXEC IMM:' || a_sql_in);
        EXECUTE IMMEDIATE a_sql_in;
    END;

    -- TODO: move to config
    --------------------------------------------------------------------------------
    FUNCTION get_tst_pkg_regexp RETURN VARCHAR2 IS
    BEGIN
        --TODO escape
        RETURN '^' || pete_config.get_test_package_prefix || '.*';
    END;

    --------------------------------------------------------------------------------
    FUNCTION get_tst_pkg_only_regexp RETURN VARCHAR2 IS
    BEGIN
        --TODO escape
        RETURN '^' || pete_config.get_test_package_prefix || 'OO.*';
    END;

    --------------------------------------------------------------------------------
    FUNCTION get_method_name_only_regexp RETURN VARCHAR2 IS
    BEGIN
        RETURN '^OO.*';
    END;

    --------------------------------------------------------------------------------
    FUNCTION get_method_name_skip_regexp RETURN VARCHAR2 IS
    BEGIN
        RETURN '^XX.*';
    END;

    --------------------------------------------------------------------------------
    -- returns true if package exists. Case sensitive
    FUNCTION package_exists(a_package_name_in IN pete_core.typ_object_name)
        RETURN BOOLEAN IS
        l_owner        pete_core.typ_object_name;
        l_package_name pete_core.typ_object_name;
    BEGIN
        -- NoFormat Start
        pete_logger.trace('PACKAGE_EXISTS: ' ||
                          'a_package_name_in:' || NVL(a_package_name_in, 'NULL'));
        -- NoFormat End
        l_owner        := pete_utils.get_sql_schema_name(a_package_name_in => a_package_name_in);
        l_package_name := pete_utils.get_sql_package_name(a_package_name_in => a_package_name_in);
        --
        FOR ii IN (SELECT NULL
                     FROM all_objects uo
                    WHERE object_type = 'PACKAGE'
                      AND owner = l_owner
                      AND object_name = l_package_name)
        LOOP
            pete_logger.trace('returns true');
            RETURN TRUE;
        END LOOP;
        --
        pete_logger.trace('returns false');
        RETURN FALSE;
        --
    END;

    --------------------------------------------------------------------------------
    FUNCTION package_has_method
    (
        a_package_name_in IN pete_core.typ_object_name,
        a_method_name_in  IN pete_core.typ_object_name
    ) RETURN BOOLEAN IS
        l_owner        pete_core.typ_object_name;
        l_package_name pete_core.typ_object_name;
        l_method_name  pete_core.typ_object_name;
    BEGIN
        -- NoFormat Start
        pete_logger.trace('PACKAGE_HAS_METHOD: ' ||
                          'a_package_name_in:' || NVL(a_package_name_in, 'NULL') || ', ' ||
                          'a_method_name_in:' || NVL(a_method_name_in, 'NULL'));
        -- NoFormat End
        l_owner        := pete_utils.get_sql_schema_name(a_package_name_in => a_package_name_in);
        l_package_name := pete_utils.get_sql_package_name(a_package_name_in => a_package_name_in);
        l_method_name  := REPLACE(dbms_assert.enquote_name(a_method_name_in),
                                  '"');
        --
        FOR ii IN (SELECT 1
                     FROM all_procedures
                    WHERE owner = l_owner
                      AND object_name = l_package_name
                      AND procedure_name = l_method_name)
        LOOP
            pete_logger.trace('returns true');
            RETURN TRUE;
        END LOOP;
        --
        pete_logger.trace('returns false');
        RETURN FALSE;
        --
    END package_has_method;

    --------------------------------------------------------------------------------
    FUNCTION run_hook_method
    (
        a_package_name_in      IN pete_core.typ_object_name,
        a_hook_method_name_in  IN pete_core.typ_object_name,
        a_parent_run_log_id_in IN pete_run_log.parent_id%TYPE
    ) RETURN pete_core.typ_execution_result IS
    BEGIN
        -- NoFormat Start
        pete_logger.trace('RUN_HOOK_METHOD: ' ||
                          'a_package_name_in:' || NVL(a_package_name_in, 'NULL') || ', ' ||
                          'a_hook_method_name_in:' || NVL(a_hook_method_name_in, 'NULL') || ', ' ||
                          'a_parent_run_log_id_in:' || NVL(TO_CHAR(a_parent_run_log_id_in), 'NULL'));
        -- NoFormat End
        IF package_has_method(a_package_name_in => a_package_name_in,
                              a_method_name_in  => a_hook_method_name_in)
        THEN
            pete_logger.trace('has hook method, execute');
            RETURN run_method(a_package_name_in      => a_package_name_in,
                              a_method_name_in       => a_hook_method_name_in,
                              a_object_type_in       => pete_core.g_OBJECT_TYPE_HOOK,
                              a_description_in       => a_hook_method_name_in,
                              a_parent_run_log_id_in => a_parent_run_log_id_in);
        ELSE
            pete_logger.trace('doesn''t have hook method, do nothing');
            RETURN pete_core.g_SUCCESS;
        END IF;
    END;

    --------------------------------------------------------------------------------
    FUNCTION run_method
    (
        a_package_name_in      IN pete_core.typ_object_name,
        a_method_name_in       IN pete_core.typ_object_name,
        a_object_type_in       IN pete_core.typ_object_type,
        a_description_in       IN pete_core.typ_description DEFAULT NULL,
        a_parent_run_log_id_in IN pete_run_log.parent_id%TYPE DEFAULT NULL
    ) RETURN pete_core.typ_execution_result IS
        l_sql        VARCHAR2(500);
        l_run_log_id INTEGER;
        l_result     pete_core.typ_execution_result := pete_core.g_SUCCESS;
        l_dummy      VARCHAR2(93);
    BEGIN
        l_run_log_id := pete_core.begin_test(a_object_name_in       => a_package_name_in || '.' ||
                                                                       a_method_name_in,
                                             a_object_type_in       => a_object_type_in,
                                             a_description_in       => a_description_in,
                                             a_parent_run_log_id_in => a_parent_run_log_id_in);
        --
        l_dummy := dbms_assert.SQL_OBJECT_NAME(a_package_name_in);
    
        l_sql := 'begin ' || a_package_name_in || '.' || a_method_name_in ||
                 ';end;';
        execute_sql(a_sql_in => l_sql);
        --
        pete_core.end_test(a_run_log_id_in => l_run_log_id);
        --
        RETURN l_result;
        --
    EXCEPTION
        WHEN OTHERS THEN
            l_result := pete_core.g_FAILURE;
            pete_core.end_test(a_run_log_id_in       => l_run_log_id,
                               a_execution_result_in => l_result,
                               a_error_code_in       => SQLCODE);
            --
            RETURN l_result;
            --
    END run_method;

    --------------------------------------------------------------------------------
    FUNCTION run_package
    (
        a_package_name_in      IN pete_core.typ_object_name,
        a_method_name_like_in  IN pete_core.typ_object_name DEFAULT NULL,
        a_description_in       IN pete_core.typ_description DEFAULT NULL,
        a_parent_run_log_id_in IN pete_run_log.parent_id%TYPE DEFAULT NULL
    ) RETURN pete_core.typ_execution_result IS
        l_result     pete_core.typ_execution_result := pete_core.g_SUCCESS;
        l_run_log_id INTEGER;
        --
        --l_method_only_regexp varchar2(255) := get_method_name_only_regexp;
        --l_method_skip_regexp varchar2(255) := get_method_name_skip_regexp;
        --
        l_before_all_result  pete_core.typ_execution_result := pete_core.g_SUCCESS;
        l_before_each_result pete_core.typ_execution_result := pete_core.g_SUCCESS;
        --
        l_something_run BOOLEAN := FALSE;
        --
        --l_owner pete_core.typ_object_name;
        --l_package_name pete_core.typ_object_name;
        --
        CURSOR lcrs_tested_methods
        (
            a_owner              IN pete_core.typ_object_name,
            a_package_name       IN pete_core.typ_object_name,
            a_method_only_regexp IN VARCHAR2,
            a_method_skip_regexp IN VARCHAR2
        ) IS
            -- NoFormat Start
            WITH convention_runner_procedures AS
             (SELECT /*+ materialize */
                     procedure_name,
                     subprogram_id,
                     SUM(CASE WHEN REGEXP_LIKE(UPPER(procedure_name), upper(a_method_only_regexp)) THEN 1 ELSE 0 END) over() AS oo_method
                FROM all_procedures up
               WHERE owner = a_owner
                 AND object_name = a_package_name
                 --ignore hooks
                 AND procedure_name NOT IN ('BEFORE_ALL', 'BEFORE_EACH', 'AFTER_ALL', 'AFTER_EACH')
                 --a_method_name_like_in filter
                 AND (a_method_name_like_in IS NULL OR upper(procedure_NAME) LIKE upper(a_method_name_like_in))
                 AND procedure_name IS NOT NULL
                 --skipped methods
                 AND not regexp_like(upper(procedure_name), upper(a_method_skip_regexp))
                    -- it is not a function or a procedure with out/in_out arguments
                    -- or a procedure in argument without default value
                 AND NOT EXISTS
               (SELECT 1
                  FROM all_arguments ua
                 WHERE ua.owner = up.owner
                   AND ua.object_name = up.procedure_name
                   AND ua.package_name = up.object_name
                   AND ( --function result or out, in/out argument in procedure
                        (ua.in_out IN ('OUT', 'IN/OUT')) OR
                       --procedure argument without default value
                        (ua.argument_name IS NOT NULL AND ua.defaulted = 'N')))
             )
            SELECT '"' || procedure_name || '"' as procedure_name
              FROM convention_runner_procedures
             WHERE (oo_method = 0) --no oo method in packge
                OR --some oo methods
                   (oo_method > 0 AND REGEXP_LIKE(UPPER(procedure_name), upper(a_method_only_regexp)))
             ORDER BY subprogram_id;
            -- NoFormat End
        TYPE typ_tested_methods_tab IS TABLE OF lcrs_tested_methods%ROWTYPE;
        ltab_tested_methods typ_tested_methods_tab;
        --
    BEGIN
        --
        -- NoFormat Start
        pete_logger.trace('RUN_PACKAGE: ' ||
                          'a_package_name_in:' || NVL(a_package_name_in, 'NULL') || ', ' ||
                          'a_method_name_like_in:' || NVL(a_method_name_like_in, 'NULL') || ', ' ||
                          'a_description_in:' || NVL(a_description_in, 'NULL') || ', ' ||
                          'a_parent_run_log_id_in:' || NVL(TO_CHAR(a_parent_run_log_id_in), 'NULL'));
        -- NoFormat End
        --l_owner := pete_utils.get_sql_schema_name(a_package_name_in => a_package_name_in);
        --l_package_name := pete_utils.get_sql_package_name(a_package_name_in => a_package_name_in);
        --
        l_run_log_id := pete_core.begin_test(a_object_name_in       => a_package_name_in,
                                             a_object_type_in       => pete_core.g_OBJECT_TYPE_PACKAGE,
                                             a_description_in       => a_description_in,
                                             a_parent_run_log_id_in => a_parent_run_log_id_in);
        pete_logger.trace('l_run_log_id ' || l_run_log_id);
        --
        IF package_exists(a_package_name_in => a_package_name_in)
        THEN
            <<test>>
            BEGIN
                pete_logger.trace('package exists');
                l_before_all_result := run_hook_method(a_package_name_in      => a_package_name_in,
                                                       a_hook_method_name_in  => 'BEFORE_ALL',
                                                       a_parent_run_log_id_in => l_run_log_id);
                l_result            := ABS(l_before_all_result) + ABS(l_result);
                pete_logger.trace('l_result: ' || l_result);
                IF (l_before_all_result = pete_core.g_SUCCESS --before_all succeeded
                   OR NOT pete_config.get_skip_if_before_hook_fails --continue if before_all failed
                   )
                THEN
                    pete_logger.trace('looping over methods');
                    OPEN lcrs_tested_methods(a_owner              => pete_utils.get_sql_schema_name(a_package_name_in => a_package_name_in),
                                             a_package_name       => pete_utils.get_sql_package_name(a_package_name_in => a_package_name_in),
                                             a_method_only_regexp => get_method_name_only_regexp,
                                             a_method_skip_regexp => get_method_name_skip_regexp);
                    FETCH lcrs_tested_methods BULK COLLECT
                        INTO ltab_tested_methods;
                    CLOSE lcrs_tested_methods;
                    <<tested_methods_loop>>
                    FOR iterator IN 1 .. ltab_tested_methods.count
                    LOOP
                        pete_logger.trace('run method ' || ltab_tested_methods(iterator)
                                          .procedure_name ||
                                          ' - before_each hook');
                        l_before_each_result := run_hook_method(a_package_name_in      => a_package_name_in,
                                                                a_hook_method_name_in  => 'BEFORE_EACH',
                                                                a_parent_run_log_id_in => l_run_log_id);
                        l_result             := ABS(l_before_each_result) +
                                                ABS(l_result);
                        pete_logger.trace('l_result: ' || l_result);
                        --
                        IF l_before_each_result = pete_core.g_SUCCESS --before_each succeeded
                           OR NOT pete_config.get_skip_if_before_hook_fails --continue if before_each failed
                        THEN
                            pete_logger.trace('run method ' || ltab_tested_methods(iterator)
                                              .procedure_name);
                            l_result        := ABS(run_method(a_package_name_in      => a_package_name_in,
                                                              a_method_name_in       => ltab_tested_methods(iterator)
                                                                                        .procedure_name,
                                                              a_object_type_in       => pete_core.g_OBJECT_TYPE_METHOD,
                                                              a_parent_run_log_id_in => l_run_log_id)) +
                                               ABS(l_result);
                            l_something_run := TRUE;
                        ELSE
                            pete_logger.trace('method ' || ltab_tested_methods(iterator)
                                              .procedure_name ||
                                              ' skipped - as before_each failed');
                        END IF;
                        --
                        pete_logger.trace('run method ' || ltab_tested_methods(iterator)
                                          .procedure_name ||
                                          ' - after_each hook');
                        l_result := ABS(run_hook_method(a_package_name_in      => a_package_name_in,
                                                        a_hook_method_name_in  => 'AFTER_EACH',
                                                        a_parent_run_log_id_in => l_run_log_id)) +
                                    ABS(l_result);
                    END LOOP tested_methods_loop;
                ELSE
                    pete_logger.trace('before_all failed - skipping all tests');
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    --TODO log error
                    pete_logger.trace('ERROR>' || SQLERRM);
                    pete_logger.trace('ERROR STACK>' || chr(10) ||
                                      dbms_utility.format_error_stack);
                    pete_logger.trace('ERROR BACKTRACE>' || chr(10) ||
                                      dbms_utility.format_error_backtrace);
                    l_result := pete_core.g_FAILURE;
            END test;
        
            --after all hook
            l_result := abs(l_result) +
                        abs(run_hook_method(a_package_name_in      => a_package_name_in,
                                            a_hook_method_name_in  => 'AFTER_ALL',
                                            a_parent_run_log_id_in => l_run_log_id));
        
        ELSE
            pete_logger.trace('unknown package  ' || a_package_name_in);
            l_result := pete_core.g_FAILURE;
        END IF;
    
        IF (NOT l_something_run AND a_method_name_like_in IS NOT NULL)
        THEN
            pete_logger.trace('nothing executed, even if I wanted -> failure');
            l_result := pete_core.g_FAILURE;
        END IF;
    
        pete_logger.trace('l_result: ' || l_result);
    
        pete_core.end_test(a_run_log_id_in       => l_run_log_id,
                           a_execution_result_in => l_result);
        --
        RETURN l_result;
        --
    END run_package;

    --------------------------------------------------------------------------------    
    FUNCTION run_suite
    (
        a_suite_name_in        IN pete_core.typ_object_name DEFAULT USER,
        a_description_in       IN pete_core.typ_description DEFAULT NULL,
        a_parent_run_log_id_in IN pete_run_log.parent_id%TYPE DEFAULT NULL
    ) RETURN pete_core.typ_execution_result IS
        l_result     pete_core.typ_execution_result := pete_core.g_SUCCESS;
        l_run_log_id INTEGER;
        --
        --l_tst_pkg_only_regexp varchar2(255) := get_tst_pkg_only_regexp;
        --l_tst_pkg_regexp      varchar2(255) := get_tst_pkg_regexp;
        --l_method_only_regexp  varchar2(255) := get_method_name_only_regexp;
        --l_method_skip_regexp  varchar2(255) := get_method_name_skip_regexp;
        --
        -- NoFormat Start
        CURSOR lcrs_tested_packages(
            a_owner_in            in pete_core.typ_object_name,
            a_tst_pkg_regexp      in varchar2,
            a_tst_pkg_only_regexp in varchar2,
            a_method_only_regexp  in varchar2,
            a_method_skip_regexp  in varchar2
        ) IS
            WITH convention_runner_procedures AS
                 (SELECT /*+ materialize */
                         owner,
                         object_name,
                         procedure_name,
                         SUM(CASE WHEN REGEXP_LIKE(object_name, a_tst_pkg_only_regexp) THEN 1 ELSE 0 END) OVER() AS oo_package,
                         SUM(CASE WHEN REGEXP_LIKE(procedure_name, a_method_only_regexp) THEN 1 ELSE 0 END) OVER() AS oo_method
                    FROM all_procedures up
                   WHERE up.owner = a_owner_in
                     AND REGEXP_LIKE(up.object_name, a_tst_pkg_regexp)
                     AND procedure_name IS NOT NULL
                     --skipped methods
                     --AND procedure_name NOT LIKE 'XX%'
                     AND NOT REGEXP_LIKE(procedure_name, a_method_skip_regexp)
                        -- it is not a function or a procedure with out/in_out arguments
                        -- or a procedure in argument without default value
                     AND NOT EXISTS
                   (SELECT 1
                      FROM all_arguments ua
                     WHERE ua.owner = up.owner
                       AND ua.object_name = up.procedure_name
                       AND ua.package_name = up.object_name
                       AND ( --function result or out, in/out argument in procedure
                            (ua.in_out IN ('OUT', 'IN/OUT')) OR
                           --procedure argument without default value
                            (ua.argument_name IS NOT NULL AND ua.defaulted = 'N')))
                 )
                SELECT DISTINCT '"' || owner || '"."' || object_name || '"' AS package_name
                  FROM convention_runner_procedures
                 WHERE (oo_method = 0 AND oo_package = 0) --no oo object
                    OR --oo package or oo method
                       ((oo_package > 0 AND REGEXP_LIKE(object_name, a_tst_pkg_only_regexp)) OR
                       (oo_method > 0 AND REGEXP_LIKE(procedure_name, a_method_only_regexp)))
                 ORDER BY package_name;
        -- NoFormat End
        --
    BEGIN
        --
        -- NoFormat Start
        pete_logger.trace('RUN_SUITE: ' ||
                          'a_suite_name_in:' || NVL(a_suite_name_in, 'NULL') || ', ' ||
                          'a_description_in:' || NVL(a_description_in, 'NULL') || ', ' ||
                          'a_parent_run_log_id_in:' || NVL(TO_CHAR(a_parent_run_log_id_in), 'NULL'));
        -- NoFormat End
        l_run_log_id := pete_core.begin_test(a_object_name_in       => a_suite_name_in,
                                             a_object_type_in       => pete_core.g_OBJECT_TYPE_SUITE,
                                             a_description_in       => a_description_in,
                                             a_parent_run_log_id_in => a_parent_run_log_id_in);
        pete_logger.trace('l_run_log_id ' || l_run_log_id);
        --
        l_result := ABS(run_hook_method(a_package_name_in      => a_suite_name_in ||
                                                                  '.PETE_BEFORE_ALL',
                                        a_hook_method_name_in  => 'RUN',
                                        a_parent_run_log_id_in => l_run_log_id)) +
                    ABS(l_result);
        --
        <<tested_packages_loop>>
        FOR lrec_test_package IN lcrs_tested_packages(a_owner_in            => pete_utils.get_sql_schema_name(a_schema_name_in => a_suite_name_in),
                                                      a_tst_pkg_regexp      => get_tst_pkg_regexp,
                                                      a_tst_pkg_only_regexp => get_tst_pkg_only_regexp,
                                                      a_method_only_regexp  => get_method_name_only_regexp,
                                                      a_method_skip_regexp  => get_method_name_skip_regexp)
        LOOP
            --
            pete_logger.trace('run package ' || lrec_test_package.package_name);
            l_result := ABS(run_hook_method(a_package_name_in      => a_suite_name_in ||
                                                                      '.PETE_BEFORE_EACH',
                                            a_hook_method_name_in  => 'RUN',
                                            a_parent_run_log_id_in => l_run_log_id)) +
                        ABS(l_result);
            --
            l_result := ABS(run_package(a_package_name_in      => lrec_test_package.package_name,
                                        a_parent_run_log_id_in => l_run_log_id)) +
                        ABS(l_result);
            --
            l_result := ABS(run_hook_method(a_package_name_in      => a_suite_name_in ||
                                                                      '.PETE_AFTER_EACH',
                                            a_hook_method_name_in  => 'RUN',
                                            a_parent_run_log_id_in => l_run_log_id)) +
                        ABS(l_result);
            --
        END LOOP tested_packages_loop;
        --
        l_result := ABS(run_hook_method(a_package_name_in      => a_suite_name_in ||
                                                                  '.PETE_AFTER_ALL',
                                        a_hook_method_name_in  => 'RUN',
                                        a_parent_run_log_id_in => l_run_log_id)) +
                    ABS(l_result);
        --
        pete_logger.trace('l_result: ' || l_result);
        pete_core.end_test(a_run_log_id_in       => l_run_log_id,
                           a_execution_result_in => l_result);
        --
        RETURN l_result;
        --
    END;

END;
/
