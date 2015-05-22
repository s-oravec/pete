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
            l_result := run_hook_method(a_package_name_in      => a_package_name_in,
                                        a_hook_method_name_in  => 'BEFORE_ALL',
                                        a_parent_run_log_id_in => l_run_log_id) AND
                        l_result;
            --
            <<tested_methods_loop>>
            FOR r_method IN (SELECT procedure_name
                               FROM user_procedures up
                              WHERE object_name = a_package_name_in
                                AND procedure_name NOT IN
                                    ('BEFORE_ALL',
                                     'BEFORE_EACH',
                                     'AFTER_ALL',
                                     'AFTER_EACH')
                                AND (a_method_name_like_in IS NULL OR
                                    procedure_name LIKE a_method_name_like_in)
                                AND NOT EXISTS
                              (SELECT 1
                                       FROM user_arguments ua
                                      WHERE ua.object_name = up.procedure_name
                                        AND ua.package_name = up.object_name
                                        AND (ua.defaulted = 'N' OR
                                            ua.in_out IN ('OUT', 'IN/OUT')))
                              ORDER BY up.subprogram_id)
            
            LOOP
                pete_logger.trace('spustim metodu ' || r_method.procedure_name);
                l_result := run_hook_method(a_package_name_in      => a_package_name_in,
                                            a_hook_method_name_in  => 'BEFORE_EACH',
                                            a_parent_run_log_id_in => l_run_log_id) AND
                            l_result;
                --
                l_result := run_method(a_package_name_in      => a_package_name_in,
                                       a_method_name_in       => r_method.procedure_name,
                                       a_object_type_in       => pete_core.g_OBJECT_TYPE_METHOD,
                                       a_parent_run_log_id_in => l_run_log_id) AND
                            l_result;
                --
                l_result := run_hook_method(a_package_name_in      => a_package_name_in,
                                            a_hook_method_name_in  => 'AFTER_EACH',
                                            a_parent_run_log_id_in => l_run_log_id) AND
                            l_result;
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
    -- TODO: configurable prefix
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
    BEGIN
        --
        pete_logger.trace('RUN_SUITE: ' || 'a_suite_name_in:' ||
                          NVL(a_suite_name_in, 'NULL') || ', ' ||
                          'a_description_in:' || NVL(a_description_in, 'NULL') || ', ' ||
                          'a_parent_run_log_id_in:' ||
                          NVL(to_char(a_parent_run_log_id_in), 'NULL'));
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
        FOR lrec_test_package IN (SELECT DISTINCT object_name
                                    FROM user_objects
                                   WHERE object_type = 'PACKAGE'
                                     AND object_name LIKE 'UT\_%' ESCAPE '\')
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
