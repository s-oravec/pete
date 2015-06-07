CREATE OR REPLACE PACKAGE BODY pete_convention_runner AS

    --
    --wrapper for dynamic SQL
    --
    PROCEDURE execute_sql(a_sql_in IN VARCHAR2) IS
    BEGIN
        pete_logger.trace(a_trace_message_in => 'EXEC IMM:' || a_sql_in);
        EXECUTE IMMEDIATE a_sql_in;
    END;

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
    FUNCTION package_has_method
    (
        a_package_name_in IN user_procedures.object_name%TYPE,
        a_method_name_in  IN user_procedures.procedure_name%TYPE
    ) RETURN BOOLEAN IS
    BEGIN
        pete_logger.trace('PACKAGE_HAS_METHOD: ' || 'a_package_name_in:' ||
                          NVL(a_package_name_in, 'NULL') || ', ' ||
                          'a_method_name_in:' || NVL(a_method_name_in, 'NULL'));
        FOR ii IN (SELECT 1
                     FROM user_procedures
                    WHERE object_name = a_package_name_in
                      AND procedure_name = a_method_name_in)
        LOOP
            pete_logger.trace('returns true');
            RETURN TRUE;
        END LOOP;
        pete_logger.trace('returns false');
        RETURN FALSE;
    END package_has_method;

    --------------------------------------------------------------------------------
    FUNCTION run_hook_method
    (
        a_package_name_in      IN user_procedures.object_name%TYPE,
        a_hook_method_name_in  IN user_procedures.procedure_name%TYPE,
        a_parent_run_log_id_in IN pete_run_log.parent_id%TYPE
    ) RETURN pete_core.typ_is_success IS
    BEGIN
        pete_logger.trace('RUN_HOOK_METHOD: ' || 'a_package_name_in:' ||
                          NVL(a_package_name_in, 'NULL') || ', ' ||
                          'a_hook_method_name_in:' ||
                          NVL(a_hook_method_name_in, 'NULL') || ', ' ||
                          'a_parent_run_log_id_in:' ||
                          NVL(to_char(a_parent_run_log_id_in), 'NULL'));
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
            RETURN TRUE;
        END IF;
    END;

    -- Refactored procedure run_method 
    FUNCTION run_method
    (
        a_package_name_in      IN pete_core.typ_object_name,
        a_method_name_in       IN pete_core.typ_object_name,
        a_object_type_in       IN pete_core.typ_object_type,
        a_description_in       IN pete_core.typ_description DEFAULT NULL,
        a_parent_run_log_id_in IN pete_run_log.parent_id%TYPE DEFAULT NULL
    ) RETURN pete_core.typ_is_success IS
        l_sql        VARCHAR2(500);
        l_run_log_id INTEGER;
        l_result     pete_core.typ_is_success := TRUE;
    BEGIN
        l_run_log_id := pete_core.begin_test(a_object_name_in       => a_package_name_in || '.' ||
                                                                       a_method_name_in,
                                             a_object_type_in       => a_object_type_in,
                                             a_description_in       => a_description_in,
                                             a_parent_run_log_id_in => a_parent_run_log_id_in);
        --
        l_sql := 'begin ' || a_package_name_in || '.' || a_method_name_in ||
                 ';end;';
        pete_logger.trace('L_SQL>' || l_sql);
        execute_sql(a_sql_in => l_sql);
        --
        pete_core.end_test(a_run_log_id_in => l_run_log_id);
        --
        RETURN l_result;
        --
    EXCEPTION
        WHEN OTHERS THEN
            pete_core.end_test(a_run_log_id_in => l_run_log_id,
                               a_is_succes_in  => FALSE,
                               a_error_code_in => SQLCODE);
            --
            l_result := FALSE;
            RETURN l_result;
            --
    END run_method;

    --
    -- Tests one package
    -- %argument a_package_name_in package name to be tested
    -- %argument a_test_package_in if true, then methods of a_package_name_in would be run
    --                          if false, then methods of UT_ || a_package_name_in would be run
    -- %argument a_method_like_in filter for methods being run - if null, all methods would be run
    --
    --------------------------------------------------------------------------------
    FUNCTION run_package
    (
        a_package_name_in      IN pete_core.typ_object_name,
        a_method_name_like_in  IN pete_core.typ_object_name DEFAULT NULL,
        a_description_in       IN pete_core.typ_description DEFAULT NULL,
        a_parent_run_log_id_in IN pete_run_log.parent_id%TYPE DEFAULT NULL
    ) RETURN pete_core.typ_is_success IS
        l_result     BOOLEAN := TRUE;
        l_run_log_id INTEGER;
        --
        l_method_only_regexp VARCHAR2(255) := get_method_name_only_regexp;
        l_method_skip_regexp VARCHAR2(255) := get_method_name_skip_regexp;
        --
        l_before_all_result  BOOLEAN := TRUE;
        l_before_each_result BOOLEAN := TRUE;
        --
    BEGIN
        --
        pete_logger.trace('RUN_PACKAGE: ' || 'a_package_name_in:' ||
                          NVL(a_package_name_in, 'NULL') || ', ' ||
                          'a_method_name_like_in:' ||
                          NVL(a_method_name_like_in, 'NULL') || ', ' ||
                          'a_description_in:' || NVL(a_description_in, 'NULL') || ', ' ||
                          'a_parent_run_log_id_in:' ||
                          NVL(to_char(a_parent_run_log_id_in), 'NULL'));
        l_run_log_id := pete_core.begin_test(a_object_name_in       => a_package_name_in,
                                             a_object_type_in       => pete_core.g_OBJECT_TYPE_PACKAGE,
                                             a_description_in       => a_description_in,
                                             a_parent_run_log_id_in => a_parent_run_log_id_in);
        pete_logger.trace('l_run_log_id ' || l_run_log_id);
        <<test>>
        BEGIN
            --
            l_before_all_result := run_hook_method(a_package_name_in      => a_package_name_in,
                                                   a_hook_method_name_in  => 'BEFORE_ALL',
                                                   a_parent_run_log_id_in => l_run_log_id);
            l_result            := l_before_all_result AND l_result;
            --
            <<tested_methods_loop>>
            FOR r_method IN
                -- NoFormat Start
                (
                WITH convention_runner_procedures AS
                 (SELECT /*+ materialize */
                         procedure_name,
                         subprogram_id,
                         SUM(CASE WHEN regexp_like(procedure_name, l_method_only_regexp) THEN 1 ELSE 0 END) over() AS oo_method
                    FROM user_procedures up
                   WHERE object_name = a_package_name_in
                     --ignore hooks
                     AND procedure_name NOT IN ('BEFORE_ALL', 'BEFORE_EACH', 'AFTER_ALL', 'AFTER_EACH')
                     --a_method_name_like_in filter
                     AND (a_method_name_like_in IS NULL OR procedure_NAME LIKE a_method_name_like_in)
                     AND procedure_name IS NOT NULL                     
                     --skipped methods
                     AND not regexp_like(procedure_name, l_method_skip_regexp)
                        -- it is not a function or a procedure with out/in_out arguments
                        -- or a procedure in argument without default value
                     AND NOT EXISTS
                   (SELECT 1
                      FROM user_arguments ua
                     WHERE ua.object_name = up.procedure_name
                       AND ua.package_name = up.object_name
                       AND ( --function result or out, in/out argument in procedure
                            (ua.in_out IN ('OUT', 'IN/OUT')) OR
                           --procedure argument without default value 
                            (ua.argument_name IS NOT NULL AND ua.defaulted = 'N')))
                 )
                SELECT procedure_name
                  FROM convention_runner_procedures
                 WHERE (oo_method = 0) --no oo method in packge
                    OR --some oo methods
                       (oo_method > 0 AND regexp_like(procedure_name, l_method_only_regexp))
                 ORDER BY subprogram_id
                )
                -- NoFormat End
            LOOP
                IF l_before_all_result --before_all succeeded
                   OR NOT pete_config.get_skip_if_before_hook_fails --continue if before_all failed
                THEN
                    pete_logger.trace('run method ' || r_method.procedure_name ||
                                      ' - before_each hook');
                    l_before_each_result := run_hook_method(a_package_name_in      => a_package_name_in,
                                                            a_hook_method_name_in  => 'BEFORE_EACH',
                                                            a_parent_run_log_id_in => l_run_log_id);
                    l_result             := l_before_each_result AND l_result;
                    --
                    IF l_before_each_result --before_each succeeded
                       OR NOT pete_config.get_skip_if_before_hook_fails --continue if before_each failed
                    THEN
                        pete_logger.trace('run method ' ||
                                          r_method.procedure_name);
                        l_result := run_method(a_package_name_in      => a_package_name_in,
                                               a_method_name_in       => r_method.procedure_name,
                                               a_object_type_in       => pete_core.g_OBJECT_TYPE_METHOD,
                                               a_parent_run_log_id_in => l_run_log_id) AND
                                    l_result;
                    ELSE
                        pete_logger.trace('method ' || r_method.procedure_name ||
                                          ' skipped - as before_each failed');
                    
                    END IF;
                    --
                    pete_logger.trace('run method ' || r_method.procedure_name ||
                                      ' - after_each hook');
                    l_result := run_hook_method(a_package_name_in      => a_package_name_in,
                                                a_hook_method_name_in  => 'AFTER_EACH',
                                                a_parent_run_log_id_in => l_run_log_id) AND
                                l_result;
                END IF;
            END LOOP tested_methods_loop;
            --
            l_result := run_hook_method(a_package_name_in      => a_package_name_in,
                                        a_hook_method_name_in  => 'AFTER_ALL',
                                        a_parent_run_log_id_in => l_run_log_id) AND
                        l_result;
        EXCEPTION
            WHEN OTHERS THEN
                --TODO log error
                l_result := FALSE;
        END test;
    
        pete_logger.trace('l_result ' || CASE WHEN l_result THEN 'TRUE' ELSE
                          'FALSE' END);
    
        pete_core.end_test(a_run_log_id_in => l_run_log_id,
                           a_is_succes_in  => l_result);
        --
        RETURN l_result;
        --
    END run_package;

    --
    -- Tests suite
    -- %argument a_suite_name_in test suite name = USER
    -- runs all UT% packages defined in users schema
    --
    --------------------------------------------------------------------------------    
    FUNCTION run_suite
    (
        a_suite_name_in        IN pete_core.typ_object_name DEFAULT USER,
        a_description_in       IN pete_core.typ_description DEFAULT NULL,
        a_parent_run_log_id_in IN pete_run_log.parent_id%TYPE DEFAULT NULL
    ) RETURN pete_core.typ_is_success IS
        l_result     pete_core.typ_is_success := TRUE;
        l_run_log_id INTEGER;
        --
        l_tst_pkg_only_regexp VARCHAR2(255) := get_tst_pkg_only_regexp;
        l_tst_pkg_regexp      VARCHAR2(255) := get_tst_pkg_regexp;
        l_method_only_regexp  VARCHAR2(255) := get_method_name_only_regexp;
        l_method_skip_regexp  VARCHAR2(255) := get_method_name_skip_regexp;
        --
    BEGIN
        --
        pete_logger.trace('RUN_SUITE: ' || --
                          'a_suite_name_in:' || NVL(a_suite_name_in, 'NULL') || ', ' || --
                          'a_description_in:' || NVL(a_description_in, 'NULL') || ', ' || --
                          'a_parent_run_log_id_in:' ||
                          NVL(to_char(a_parent_run_log_id_in), 'NULL') --
                          );
        l_run_log_id := pete_core.begin_test(a_object_name_in       => a_suite_name_in,
                                             a_object_type_in       => pete_core.g_OBJECT_TYPE_SUITE,
                                             a_description_in       => a_description_in,
                                             a_parent_run_log_id_in => a_parent_run_log_id_in);
        pete_logger.trace('l_run_log_id ' || l_run_log_id);
        --
        l_result := run_hook_method(a_package_name_in      => a_suite_name_in ||
                                                              '.PETE_BEFORE_ALL',
                                    a_hook_method_name_in  => 'RUN',
                                    a_parent_run_log_id_in => l_run_log_id) AND
                    l_result;
        --
        <<test_packages_loop>>
        FOR lrec_test_package IN
            -- NoFormat Start
            (
            WITH convention_runner_procedures AS
             (SELECT /*+ materialize */
                     object_name,
                     procedure_name,
                     SUM(CASE WHEN regexp_like(object_name, l_tst_pkg_only_regexp) THEN 1 ELSE 0 END) over() AS oo_package,
                     SUM(CASE WHEN regexp_like(procedure_name, l_method_only_regexp) THEN 1 ELSE 0 END) over() AS oo_method
                FROM user_procedures up
               WHERE regexp_like(object_name, l_tst_pkg_regexp)
                 AND procedure_name IS NOT NULL
                 --skipped methods
                 --AND procedure_name NOT LIKE 'XX%'
                 AND not regexp_like(procedure_name, l_method_skip_regexp)
                    -- it is not a function or a procedure with out/in_out arguments
                    -- or a procedure in argument without default value
                 AND NOT EXISTS
               (SELECT 1
                  FROM user_arguments ua
                 WHERE ua.object_name = up.procedure_name
                   AND ua.package_name = up.object_name
                   AND ( --function result or out, in/out argument in procedure
                        (ua.in_out IN ('OUT', 'IN/OUT')) OR
                       --procedure argument without default value 
                        (ua.argument_name IS NOT NULL AND ua.defaulted = 'N')))
             )
            SELECT DISTINCT object_name
              FROM convention_runner_procedures
             WHERE (oo_method = 0 AND oo_package = 0) --no oo object
                OR --oo package or oo method
                   ((oo_package > 0 AND regexp_like(object_name, l_tst_pkg_only_regexp)) OR
                   (oo_method > 0 AND regexp_like(procedure_name, l_method_only_regexp)))
             ORDER BY object_name
            )
            -- NoFormat End
        LOOP
            --
            pete_logger.trace('spoustena package ' ||
                              lrec_test_package.object_name);
            l_result := run_hook_method(a_package_name_in      => a_suite_name_in ||
                                                                  '.PETE_BEFORE_EACH',
                                        a_hook_method_name_in  => 'RUN',
                                        a_parent_run_log_id_in => l_run_log_id) AND
                        l_result;
            --
            l_result := run_package(a_package_name_in      => lrec_test_package.object_name,
                                    a_parent_run_log_id_in => l_run_log_id) AND
                        l_result;
            --
            l_result := run_hook_method(a_package_name_in      => a_suite_name_in ||
                                                                  '.PETE_AFTER_EACH',
                                        a_hook_method_name_in  => 'RUN',
                                        a_parent_run_log_id_in => l_run_log_id) AND
                        l_result;
            --
        END LOOP test_packages;
        --
        l_result := run_hook_method(a_package_name_in      => a_suite_name_in ||
                                                              '.PETE_AFTER_ALL',
                                    a_hook_method_name_in  => 'RUN',
                                    a_parent_run_log_id_in => l_run_log_id) AND
                    l_result;
        --
        pete_logger.trace('l_result ' || CASE WHEN l_result THEN 'TRUE' ELSE
                          'FALSE' END);
        pete_core.end_test(a_run_log_id_in => l_run_log_id,
                           a_is_succes_in  => l_result);
        --
        RETURN l_result;
        --
    END;

END;
/
