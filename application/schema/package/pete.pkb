CREATE OR REPLACE PACKAGE BODY pete AS

    TYPE typ_run_result IS RECORD(
        run_log_id pete_run_log.id%TYPE,
        RESULT     pete_core.typ_execution_result);

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
        a_result_in     IN pete_core.typ_execution_result,
        a_run_log_id_in IN pete_run_log.id%TYPE
    ) IS
    BEGIN
        pete_core.end_test(a_run_log_id_in       => a_run_log_id_in,
                           a_execution_result_in => a_result_in);
    END;

    --------------------------------------------------------------------------------
    FUNCTION run_test_suite_impl
    (
        a_suite_name_in         IN VARCHAR2 DEFAULT NULL,
        a_style_conventional_in IN BOOLEAN DEFAULT TRUE,
        a_parent_run_log_id_in  IN INTEGER DEFAULT NULL
    ) RETURN typ_run_result IS
        l_style_conventional BOOLEAN := nvl(a_style_conventional_in, TRUE);
        l_suite_name         VARCHAR2(255) := nvl(a_suite_name_in, USER);
        l_result             typ_run_result;
    BEGIN
        pete_logger.trace('RUN_TEST_SUITE_IMPL: ' || 'a_suite_name_in:' ||
                          NVL(a_suite_name_in, 'NULL') || ', ' ||
                          'a_style_conventional_in:' ||
                          NVL(CASE WHEN a_style_conventional_in THEN 'TRUE' WHEN
                              NOT a_style_conventional_in THEN 'FALSE' ELSE NULL END,
                              'NULL'));
        --
        l_result.run_log_id := begin_test(a_object_name_in       => l_suite_name,
                                          a_object_type_in       => pete_core.g_OBJECT_TYPE_SUITE,
                                          a_parent_run_log_id_in => a_parent_run_log_id_in);
        --
        CASE l_style_conventional
            WHEN TRUE THEN
                l_result.result := pete_convention_runner.run_suite(a_suite_name_in        => l_suite_name,
                                                                    a_parent_run_log_id_in => l_result.run_log_id);
            WHEN FALSE THEN
                l_result.result := pete_configuration_runner.run_suite(a_suite_name_in        => l_suite_name,
                                                                       a_parent_run_log_id_in => l_result.run_log_id);
        END CASE;
        --
        --do not output log if recursive call
        end_test(a_result_in     => l_result.result,
                 a_run_log_id_in => l_result.run_log_id);
        --
        RETURN l_result;
        --
    END run_test_suite_impl;

    --------------------------------------------------------------------------------
    PROCEDURE run_test_suite
    (
        a_suite_name_in         IN VARCHAR2 DEFAULT NULL,
        a_style_conventional_in IN BOOLEAN DEFAULT TRUE,
        a_parent_run_log_id_in  IN INTEGER DEFAULT NULL
    ) IS
        l_impl_call_result typ_run_result;
    BEGIN
        l_impl_call_result := run_test_suite_impl(a_suite_name_in         => a_suite_name_in,
                                                  a_style_conventional_in => a_style_conventional_in,
                                                  a_parent_run_log_id_in  => a_parent_run_log_id_in);
        --
        IF a_parent_run_log_id_in IS NULL
        THEN
            pete_logger.output_log(a_run_log_id_in => l_impl_call_result.run_log_id);
        END IF;
        --
    END run_test_suite;

    --------------------------------------------------------------------------------
    FUNCTION run_test_suite
    (
        a_suite_name_in         IN VARCHAR2 DEFAULT NULL,
        a_style_conventional_in IN BOOLEAN DEFAULT TRUE,
        a_parent_run_log_id_in  IN INTEGER DEFAULT NULL
    ) RETURN pete_core.typ_execution_result IS
        l_impl_call_result typ_run_result;
    BEGIN
        l_impl_call_result := run_test_suite_impl(a_suite_name_in         => a_suite_name_in,
                                                  a_style_conventional_in => a_style_conventional_in,
                                                  a_parent_run_log_id_in  => a_parent_run_log_id_in);
        --
        RETURN l_impl_call_result.result;
        --
    END run_test_suite;

    --------------------------------------------------------------------------------
    FUNCTION run_test_case_impl
    (
        a_case_name_in         VARCHAR2,
        a_parent_run_log_id_in IN INTEGER DEFAULT NULL
    ) RETURN typ_run_result IS
        l_result typ_run_result;
    BEGIN
        pete_logger.trace('RUN_TEST_CASE: ' || 'a_case_name_in:' ||
                          NVL(a_case_name_in, 'NULL'));
        IF a_case_name_in IS NULL
        THEN
            raise_application_error(-20000, 'Test case name not specified');
        END IF;
        --
        l_result.run_log_id := begin_test(a_object_name_in       => a_case_name_in,
                                          a_object_type_in       => pete_core.g_OBJECT_TYPE_CASE,
                                          a_parent_run_log_id_in => a_parent_run_log_id_in);
    
        --
        l_result.result := pete_configuration_runner.run_case(a_case_name_in         => a_case_name_in,
                                                              a_parent_run_log_id_in => l_result.run_log_id);
        --
        --do not output log if recursive call
        end_test(a_result_in     => l_result.result,
                 a_run_log_id_in => l_result.run_log_id);
        --
        RETURN l_result;
        --
    END run_test_case_impl;

    --------------------------------------------------------------------------------
    PROCEDURE run_test_case
    (
        a_case_name_in         VARCHAR2,
        a_parent_run_log_id_in IN INTEGER DEFAULT NULL
    ) IS
        l_impl_call_result typ_run_result;
    BEGIN
        l_impl_call_result := run_test_case_impl(a_case_name_in         => a_case_name_in,
                                                 a_parent_run_log_id_in => a_parent_run_log_id_in);
        --
        IF a_parent_run_log_id_in IS NULL
        THEN
            pete_logger.output_log(a_run_log_id_in => l_impl_call_result.run_log_id);
        END IF;
        --
    END;

    --------------------------------------------------------------------------------
    FUNCTION run_test_case
    (
        a_case_name_in         IN VARCHAR2,
        a_parent_run_log_id_in IN INTEGER DEFAULT NULL
    ) RETURN pete_core.typ_execution_result IS
        l_impl_call_result typ_run_result;
    BEGIN
        l_impl_call_result := run_test_case_impl(a_case_name_in         => a_case_name_in,
                                                 a_parent_run_log_id_in => a_parent_run_log_id_in);
        --
        RETURN l_impl_call_result.result;
        --
    END;

    --------------------------------------------------------------------------------
    FUNCTION run_test_package_impl
    (
        a_package_name_in      IN VARCHAR2,
        a_method_name_like_in  IN VARCHAR2 DEFAULT NULL,
        a_parent_run_log_id_in IN INTEGER DEFAULT NULL
    ) RETURN typ_run_result IS
        l_result typ_run_result;
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
        l_result.run_log_id := begin_test(a_object_name_in       => a_package_name_in,
                                          a_object_type_in       => pete_core.g_OBJECT_TYPE_PACKAGE,
                                          a_parent_run_log_id_in => a_parent_run_log_id_in);
        --
        l_result.result := pete_convention_runner.run_package(a_package_name_in      => a_package_name_in,
                                                              a_method_name_like_in  => a_method_name_like_in,
                                                              a_parent_run_log_id_in => l_result.run_log_id);
    
        --
        --do not output log if recursive call
        end_test(a_result_in     => l_result.result,
                 a_run_log_id_in => l_result.run_log_id);
        --
        RETURN l_result;
        --
    END run_test_package_impl;

    --------------------------------------------------------------------------------
    PROCEDURE run_test_package
    (
        a_package_name_in      VARCHAR2,
        a_method_name_like_in  IN VARCHAR2 DEFAULT NULL,
        a_parent_run_log_id_in IN INTEGER DEFAULT NULL
    ) IS
        l_impl_call_result typ_run_result;
    BEGIN
        l_impl_call_result := run_test_package_impl(a_package_name_in      => a_package_name_in,
                                                    a_method_name_like_in  => a_method_name_like_in,
                                                    a_parent_run_log_id_in => a_parent_run_log_id_in);
        --
        IF a_parent_run_log_id_in IS NULL
        THEN
            pete_logger.output_log(a_run_log_id_in => l_impl_call_result.run_log_id);
        END IF;
        --
    END run_test_package;

    --------------------------------------------------------------------------------
    FUNCTION run_test_package
    (
        a_package_name_in      IN VARCHAR2,
        a_method_name_like_in  IN VARCHAR2 DEFAULT NULL,
        a_parent_run_log_id_in IN INTEGER DEFAULT NULL
    ) RETURN pete_core.typ_execution_result IS
        l_impl_call_result typ_run_result;
    BEGIN
        l_impl_call_result := run_test_package_impl(a_package_name_in      => a_package_name_in,
                                                    a_method_name_like_in  => a_method_name_like_in,
                                                    a_parent_run_log_id_in => a_parent_run_log_id_in);
        --
        RETURN l_impl_call_result.result;
        --
    END run_test_package;

    --------------------------------------------------------------------------------
    FUNCTION run_all_tests_impl(a_parent_run_log_id_in IN INTEGER DEFAULT NULL)
        RETURN typ_run_result IS
        l_result typ_run_result;
    BEGIN
        pete_logger.trace('RUN_ALL_TESTS: ');
        --
        l_result.run_log_id := begin_test(a_object_name_in       => 'Run all test',
                                          a_object_type_in       => pete_core.g_OBJECT_TYPE_PETE,
                                          a_parent_run_log_id_in => a_parent_run_log_id_in);
        --
        --1. run all Configuration suites
        l_result.result := abs(pete_configuration_runner.run_all_test_suites) +
                           abs(l_result.result);
        --2. run user Conventional suite
        l_result.result := abs(pete_convention_runner.run_suite(a_suite_name_in        => USER,
                                                                a_parent_run_log_id_in => l_result.run_log_id)) +
                           abs(l_result.result);
        --
        --do not output log if recursive call
        end_test(a_result_in     => l_result.result,
                 a_run_log_id_in => l_result.run_log_id);
        --
        RETURN l_result;
        --
    END run_all_tests_impl;

    --------------------------------------------------------------------------------
    PROCEDURE run_all_tests(a_parent_run_log_id_in IN INTEGER DEFAULT NULL) IS
        l_impl_call_result typ_run_result;
    BEGIN
        l_impl_call_result := run_all_tests_impl(a_parent_run_log_id_in => a_parent_run_log_id_in);
        --
        IF a_parent_run_log_id_in IS NULL
        THEN
            pete_logger.output_log(a_run_log_id_in => l_impl_call_result.run_log_id);
        END IF;
        --
    END run_all_tests;

    --------------------------------------------------------------------------------
    FUNCTION run_all_tests(a_parent_run_log_id_in IN INTEGER DEFAULT NULL)
        RETURN pete_core.typ_execution_result IS
        l_impl_call_result typ_run_result;
    BEGIN
        l_impl_call_result := run_all_tests_impl(a_parent_run_log_id_in => a_parent_run_log_id_in);
        --
        RETURN l_impl_call_result.result;
        --
    END run_all_tests;

    --------------------------------------------------------------------------------
    FUNCTION run_impl
    (
        a_suite_name_in         IN VARCHAR2 DEFAULT NULL,
        a_package_name_in       IN VARCHAR2 DEFAULT NULL,
        a_method_name_in        IN VARCHAR2 DEFAULT NULL,
        a_case_name_in          IN VARCHAR2 DEFAULT NULL,
        a_style_conventional_in IN BOOLEAN DEFAULT NULL,
        a_parent_run_log_id_in  IN INTEGER DEFAULT NULL
    ) RETURN typ_run_result IS
        l_cnt INTEGER;
    BEGIN
        pete_logger.trace('RUN: ' || 'a_suite_name_in:' ||
                          NVL(a_suite_name_in, 'NULL') || ', ' ||
                          'a_package_name_in:' ||
                          NVL(a_package_name_in, 'NULL') || ', ' ||
                          'a_method_name_in:' || NVL(a_method_name_in, 'NULL') || ', ' ||
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
            RETURN run_test_suite_impl(a_suite_name_in         => a_suite_name_in,
                                       a_style_conventional_in => a_style_conventional_in,
                                       a_parent_run_log_id_in  => a_parent_run_log_id_in);
        ELSIF a_package_name_in IS NOT NULL
        THEN
            RETURN run_test_package_impl(a_package_name_in      => a_package_name_in,
                                         a_method_name_like_in  => a_method_name_in,
                                         a_parent_run_log_id_in => a_parent_run_log_id_in);
        ELSIF a_case_name_in IS NOT NULL
        THEN
            RETURN run_test_case_impl(a_case_name_in         => a_case_name_in,
                                      a_parent_run_log_id_in => a_parent_run_log_id_in);
        ELSE
            raise_application_error(pete.gc_AMBIGUOUS_INPUT,
                                    'Ambiguous input - nothing specified');
        END IF;
    
    END run_impl;

    --------------------------------------------------------------------------------
    PROCEDURE run
    (
        a_suite_name_in         IN VARCHAR2 DEFAULT NULL,
        a_package_name_in       IN VARCHAR2 DEFAULT NULL,
        a_method_name_in        IN VARCHAR2 DEFAULT NULL,
        a_case_name_in          IN VARCHAR2 DEFAULT NULL,
        a_style_conventional_in IN BOOLEAN DEFAULT NULL,
        a_parent_run_log_id_in  IN INTEGER DEFAULT NULL
    ) IS
        l_impl_call_result typ_run_result;
    BEGIN
        l_impl_call_result := run_impl(a_suite_name_in         => a_suite_name_in,
                                       a_package_name_in       => a_package_name_in,
                                       a_method_name_in        => a_method_name_in,
                                       a_case_name_in          => a_case_name_in,
                                       a_style_conventional_in => a_style_conventional_in,
                                       a_parent_run_log_id_in  => a_parent_run_log_id_in);
        --
        IF a_parent_run_log_id_in IS NULL
        THEN
            pete_logger.output_log(a_run_log_id_in => l_impl_call_result.run_log_id);
        END IF;
        --
    END;

    --------------------------------------------------------------------------------
    FUNCTION run
    (
        a_suite_name_in         IN VARCHAR2 DEFAULT NULL,
        a_package_name_in       IN VARCHAR2 DEFAULT NULL,
        a_method_name_in        IN VARCHAR2 DEFAULT NULL,
        a_case_name_in          IN VARCHAR2 DEFAULT NULL,
        a_style_conventional_in IN BOOLEAN DEFAULT NULL,
        a_parent_run_log_id_in  IN INTEGER DEFAULT NULL
    ) RETURN pete_core.typ_execution_result IS
        l_impl_call_result typ_run_result;
    BEGIN
        l_impl_call_result := run_impl(a_suite_name_in         => a_suite_name_in,
                                       a_package_name_in       => a_package_name_in,
                                       a_method_name_in        => a_method_name_in,
                                       a_case_name_in          => a_case_name_in,
                                       a_style_conventional_in => a_style_conventional_in,
                                       a_parent_run_log_id_in  => a_parent_run_log_id_in);
        --
        RETURN l_impl_call_result.result;
        --
    END;

    --------------------------------------------------------------------------------
    procedure set_method_description(a_description_in in varchar2)
    is
    begin
        pete_logger.set_method_description(a_description_in => a_description_in);
    end;


END;
/
