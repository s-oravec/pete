CREATE OR REPLACE PACKAGE BODY pete AS

    --------------------------------------------------------------------------------
    PROCEDURE init(a_log_to_dbms_output_in IN BOOLEAN DEFAULT TRUE) IS
    BEGIN
        --
        pete_logger.init(a_log_to_dbms_output_in => a_log_to_dbms_output_in);
        --
    END;

    --------------------------------------------------------------------------------  
    FUNCTION begin_test
    (
        a_object_name_in       IN pete_run_log.object_name%TYPE,
        a_object_type_in       IN pete_run_log.object_type%TYPE,
        a_description_in       IN pete_run_log.description%TYPE DEFAULT NULL,
        a_parent_run_log_id_in IN INTEGER DEFAULT NULL
    ) RETURN pete_run_log.id%TYPE IS
    BEGIN
        RETURN pete_core.begin_test(a_object_name_in       => 'Pete:' ||
                                                              a_object_type_in || ':' ||
                                                              a_object_name_in,
                                    a_object_type_in       => pete_core.g_OBJECT_TYPE_PETE,
                                    a_description_in       => nvl(a_description_in,
                                                                  'Pete run @ ' ||
                                                                  to_char(systimestamp)),
                                    a_parent_run_log_id_in => a_parent_run_log_id_in);
    END;

    --------------------------------------------------------------------------------
    PROCEDURE end_test
    (
        a_result_in     IN pete_core.typ_is_success,
        a_run_log_id_in IN pete_run_log.id%TYPE,
        a_output_log_in IN BOOLEAN
    ) IS
    BEGIN
        pete_core.end_test(a_run_log_id_in => a_run_log_id_in,
                           a_is_succes_in  => a_result_in);
        IF a_output_log_in
        THEN
            pete_logger.output_log(a_run_log_id_in => a_run_log_id_in);
        END IF;
    END;

    --------------------------------------------------------------------------------
    PROCEDURE run
    (
        a_suite_name_in         IN VARCHAR2 DEFAULT NULL,
        a_package_name_in       IN VARCHAR2 DEFAULT NULL,
        a_method_name_in        IN VARCHAR2 DEFAULT NULL,
        a_script_name_in        IN VARCHAR2 DEFAULT NULL,
        a_case_name_in          IN VARCHAR2 DEFAULT NULL,
        a_style_conventional_in IN BOOLEAN DEFAULT NULL,
        a_parent_run_log_id_in  IN INTEGER DEFAULT NULL
    ) IS
        l_cnt INTEGER;
    BEGIN
        pete_logger.trace('RUN: ' || 'a_suite_name_in:' ||
                          NVL(a_suite_name_in, 'NULL') || ', ' ||
                          'a_package_name_in:' ||
                          NVL(a_package_name_in, 'NULL') || ', ' ||
                          'a_method_name_in:' || NVL(a_method_name_in, 'NULL') || ', ' ||
                          'a_script_name_in:' || NVL(a_script_name_in, 'NULL') || ', ' ||
                          'a_case_name_in:' || NVL(a_case_name_in, 'NULL') || ', ' ||
                          'a_style_conventional_in:' ||
                          NVL(CASE WHEN a_style_conventional_in THEN 'TRUE' WHEN
                              NOT a_style_conventional_in THEN 'FALSE' ELSE NULL END,
                              'NULL'));
    
        --
        --check arguments
        -- iba method nema zmysel - potrebuje package
        -- 
        WITH args AS
         (SELECT a_suite_name_in AS x
            FROM dual
          UNION ALL
          SELECT a_package_name_in AS x
            FROM dual
          UNION ALL
          SELECT a_method_name_in AS x
            FROM dual
          UNION ALL
          SELECT a_script_name_in AS x
            FROM dual
          UNION ALL
          SELECT a_case_name_in AS x
            FROM dual)
        SELECT COUNT(x) INTO l_cnt FROM args;
        pete_logger.trace('l_cnt ' || l_cnt);
        --
        IF l_cnt > 1
           AND a_method_name_in IS NULL
        THEN
            raise_application_error(pete.gc_CONFLICTING_INPUT,
                                    'Conflicting input - too many arguments set');
        END IF;
        --
        IF a_suite_name_in IS NOT NULL
        THEN
            run_test_suite(a_suite_name_in         => a_suite_name_in,
                           a_style_conventional_in => a_style_conventional_in,
                           a_parent_run_log_id_in  => a_parent_run_log_id_in);
        ELSIF a_package_name_in IS NOT NULL
        THEN
            run_test_package(a_package_name_in      => a_package_name_in,
                             a_method_name_like_in  => a_method_name_in,
                             a_parent_run_log_id_in => a_parent_run_log_id_in);
        ELSIF a_script_name_in IS NOT NULL
        THEN
            run_test_script(a_script_name_in       => a_script_name_in,
                            a_parent_run_log_id_in => a_parent_run_log_id_in);
        ELSIF a_case_name_in IS NOT NULL
        THEN
            run_test_case(a_case_name_in         => a_case_name_in,
                          a_parent_run_log_id_in => a_parent_run_log_id_in);
        ELSE
            raise_application_error(pete.gc_AMBIGUOUS_INPUT,
                                    'Ambiguous input - nothing specified');
        END IF;
    
    END run;

    --------------------------------------------------------------------------------
    PROCEDURE run_test_suite
    (
        a_suite_name_in         IN VARCHAR2 DEFAULT NULL,
        a_style_conventional_in IN BOOLEAN DEFAULT TRUE,
        a_parent_run_log_id_in  IN INTEGER DEFAULT NULL
    ) IS
        l_style_conventional BOOLEAN := nvl(a_style_conventional_in, TRUE);
        l_suite_name         VARCHAR2(255) := nvl(a_suite_name_in, USER);
        l_run_log_id         pete_run_log.id%TYPE;
        l_result             pete_core.typ_is_success;
    BEGIN
        pete_logger.trace('RUN_TEST_SUITE: ' || 'a_suite_name_in:' ||
                          NVL(a_suite_name_in, 'NULL') || ', ' ||
                          'a_style_conventional_in:' ||
                          NVL(CASE WHEN a_style_conventional_in THEN 'TRUE' WHEN
                              NOT a_style_conventional_in THEN 'FALSE' ELSE NULL END,
                              'NULL'));
        --
        l_run_log_id := begin_test(a_object_name_in       => l_suite_name,
                                   a_object_type_in       => pete_core.g_OBJECT_TYPE_SUITE,
                                   a_parent_run_log_id_in => a_parent_run_log_id_in);
        --
        CASE l_style_conventional
            WHEN TRUE THEN
                l_result := pete_convention_runner.run_suite(a_suite_name_in        => l_suite_name,
                                                             a_parent_run_log_id_in => l_run_log_id);
            WHEN FALSE THEN
                l_result := pete_configuration_runner.run_suite(a_suite_name_in        => l_suite_name,
                                                                a_parent_run_log_id_in => l_run_log_id);
        END CASE;
        --
        --do not output log if recursive call
        end_test(a_result_in     => l_result,
                 a_run_log_id_in => l_run_log_id,
                 a_output_log_in => a_parent_run_log_id_in IS NULL);
        --
    END run_test_suite;

    --------------------------------------------------------------------------------
    PROCEDURE run_test_script
    (
        a_script_name_in       IN VARCHAR2,
        a_parent_run_log_id_in IN INTEGER DEFAULT NULL
    ) IS
        l_run_log_id pete_run_log.id%TYPE;
        l_result     pete_core.typ_is_success;
    BEGIN
        pete_logger.trace('RUN_TEST_SCRIPT: ' || 'a_script_name_in:' ||
                          NVL(a_script_name_in, 'NULL'));
        IF a_script_name_in IS NULL
        THEN
            raise_application_error(-20000, 'Test script name not specified');
        END IF;
        --
        l_run_log_id := begin_test(a_object_name_in       => a_script_name_in,
                                   a_object_type_in       => pete_core.g_OBJECT_TYPE_SCRIPT,
                                   a_parent_run_log_id_in => a_parent_run_log_id_in);
    
        --
        l_result := pete_configuration_runner.run_script(a_script_name_in       => a_script_name_in,
                                                         a_parent_run_log_id_in => l_run_log_id);
        --
        --do not output log if recursive call
        end_test(a_result_in     => l_result,
                 a_run_log_id_in => l_run_log_id,
                 a_output_log_in => a_parent_run_log_id_in IS NULL);
        --
    END run_test_script;

    --------------------------------------------------------------------------------
    PROCEDURE run_test_case
    (
        a_case_name_in         VARCHAR2,
        a_parent_run_log_id_in IN INTEGER DEFAULT NULL
    ) IS
        l_run_log_id pete_run_log.id%TYPE;
        l_result     pete_core.typ_is_success;
    BEGIN
        pete_logger.trace('RUN_TEST_CASE: ' || 'a_case_name_in:' ||
                          NVL(a_case_name_in, 'NULL'));
        IF a_case_name_in IS NULL
        THEN
            raise_application_error(-20000, 'Test case name not specified');
        END IF;
        --
        l_run_log_id := begin_test(a_object_name_in       => a_case_name_in,
                                   a_object_type_in       => pete_core.g_OBJECT_TYPE_CASE,
                                   a_parent_run_log_id_in => a_parent_run_log_id_in);
    
        --
        l_result := pete_configuration_runner.run_case(a_case_name_in         => a_case_name_in,
                                                       a_parent_run_log_id_in => l_run_log_id);
        --
        --do not output log if recursive call
        end_test(a_result_in     => l_result,
                 a_run_log_id_in => l_run_log_id,
                 a_output_log_in => a_parent_run_log_id_in IS NULL);
        --
    END run_test_case;

    --------------------------------------------------------------------------------
    PROCEDURE run_test_package
    (
        a_package_name_in      IN VARCHAR2,
        a_method_name_like_in  IN VARCHAR2 DEFAULT NULL,
        a_parent_run_log_id_in IN INTEGER DEFAULT NULL
    ) IS
        l_run_log_id pete_run_log.id%TYPE;
        l_result     pete_core.typ_is_success;
    BEGIN
        pete_logger.trace('RUN_TEST_PACKAGE: ' || 'a_package_name_in:' ||
                          NVL(a_package_name_in, 'NULL') || ', ' ||
                          'a_method_name_like_in:' ||
                          NVL(a_method_name_like_in, 'NULL'));
        IF a_package_name_in IS NULL
        THEN
            raise_application_error(-20000, 'Test package name not specified');
        END IF;
        --
        l_run_log_id := begin_test(a_object_name_in       => a_package_name_in,
                                   a_object_type_in       => pete_core.g_OBJECT_TYPE_PACKAGE,
                                   a_parent_run_log_id_in => a_parent_run_log_id_in);
        --
        l_result := pete_convention_runner.run_package(a_package_name_in      => a_package_name_in,
                                                       a_method_name_like_in  => a_method_name_like_in,
                                                       a_parent_run_log_id_in => l_run_log_id);
    
        --
        --do not output log if recursive call
        end_test(a_result_in     => l_result,
                 a_run_log_id_in => l_run_log_id,
                 a_output_log_in => a_parent_run_log_id_in IS NULL);
        --
    END run_test_package;

    --------------------------------------------------------------------------------
    PROCEDURE run_all_tests(a_parent_run_log_id_in IN INTEGER DEFAULT NULL) IS
        l_run_log_id pete_run_log.id%TYPE;
        l_result     pete_core.typ_is_success;
    BEGIN
        pete_logger.trace('RUN_ALL_TESTS: ');
        --
        l_run_log_id := begin_test(a_object_name_in       => 'Run all test',
                                   a_object_type_in       => pete_core.g_OBJECT_TYPE_PETE,
                                   a_parent_run_log_id_in => a_parent_run_log_id_in);
        --
        --1. run all Configuration scripts
        l_result := pete_configuration_runner.run_all_test_scripts AND l_result;
        --2. run user Conventional suite
        l_result := pete_convention_runner.run_suite(a_suite_name_in        => USER,
                                                     a_parent_run_log_id_in => l_run_log_id) AND
                    l_result;
        --
        --do not output log if recursive call
        end_test(a_result_in     => l_result,
                 a_run_log_id_in => l_run_log_id,
                 a_output_log_in => a_parent_run_log_id_in IS NULL);
        --
    END run_all_tests;

END;
/
