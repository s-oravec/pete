CREATE OR REPLACE PACKAGE BODY pete AS

    g_master_run_log_id pete_run_log.id%TYPE;
    g_result            pete_core.typ_is_success := TRUE;

    --------------------------------------------------------------------------------
    PROCEDURE init(a_log_to_dbms_output_in IN BOOLEAN DEFAULT TRUE) IS
    BEGIN
        --
        pete_logger.init(a_log_to_dbms_output_in => a_log_to_dbms_output_in);
        --
    END;

    --------------------------------------------------------------------------------  
    PROCEDURE begin_test
    (
        a_object_name_in IN pete_run_log.object_name%TYPE,
        a_object_type_in IN pete_run_log.object_type%TYPE,
        a_description_in IN pete_run_log.description%TYPE DEFAULT NULL
    ) IS
    BEGIN
        g_result            := TRUE;
        g_master_run_log_id := pete_core.begin_test(a_object_name_in => 'Pete:' ||
                                                                        a_object_type_in || ':' ||
                                                                        a_object_name_in,
                                                    a_object_type_in => pete_core.g_OBJECT_TYPE_PETE,
                                                    a_description_in => nvl(a_description_in,
                                                                            'Pete run @ ' ||
                                                                            to_char(systimestamp)));
    END;

    --------------------------------------------------------------------------------
    PROCEDURE end_test IS
    BEGIN
        pete_core.end_test(a_run_log_id_in => g_master_run_log_id,
                           a_is_succes_in  => g_result);
        pete_logger.output_log(a_run_log_id_in => g_master_run_log_id);
    END;

    --------------------------------------------------------------------------------
    PROCEDURE run
    (
        a_suite_name_in         IN VARCHAR2 DEFAULT NULL,
        a_package_name_in       IN VARCHAR2 DEFAULT NULL,
        a_method_name_in        IN VARCHAR2 DEFAULT NULL,
        a_script_name_in        IN VARCHAR2 DEFAULT NULL,
        a_case_name_in          IN VARCHAR2 DEFAULT NULL,
        a_style_conventional_in IN BOOLEAN DEFAULT NULL
    ) IS
        l_cnt INTEGER;
    BEGIN
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
        SELECT COUNT(*) INTO l_cnt FROM args WHERE x IS NOT NULL;
    
        --
        IF l_cnt > 1
        THEN
            raise_application_error(pete.gc_CONFLICTING_INPUT,
                                    'Conflicting input - too many arguments set');
        END IF;
        --
        IF a_suite_name_in IS NOT NULL
        THEN
            run_test_suite(a_suite_name_in         => a_suite_name_in,
                           a_style_conventional_in => a_style_conventional_in);
        ELSIF a_package_name_in IS NOT NULL
        THEN
            run_test_package(a_package_name_in => a_package_name_in);
        ELSIF a_script_name_in IS NOT NULL
        THEN
            run_test_script(a_script_name_in => a_script_name_in);
        ELSIF a_case_name_in IS NOT NULL
        THEN
            run_test_case(a_case_name_in => a_case_name_in);
        ELSIF a_package_name_in IS NOT NULL
              AND a_method_name_in IS NOT NULL
        
        THEN
            run_test_package(a_package_name_in     => a_package_name_in,
                             a_method_name_like_in => a_method_name_in);
        ELSE
            raise_application_error(pete.gc_AMBIGUOUS_INPUT,
                                    'Ambiguous input - nothing specified');
        END IF;
    
    END run;

    --------------------------------------------------------------------------------
    PROCEDURE run_test_suite
    (
        a_suite_name_in         IN VARCHAR2 DEFAULT NULL,
        a_style_conventional_in IN BOOLEAN DEFAULT TRUE
    ) IS
        l_style_conventional BOOLEAN := nvl(a_style_conventional_in, TRUE);
        l_suite_name         VARCHAR2(255) := nvl(a_suite_name_in, USER);
    BEGIN
        --
        begin_test(a_object_name_in => l_suite_name,
                   a_object_type_in => pete_core.g_OBJECT_TYPE_SUITE);
        --
        CASE l_style_conventional
            WHEN TRUE THEN
                g_result := pete_convention_runner.run_suite(a_suite_name_in        => l_suite_name,
                                                             a_parent_run_log_id_in => g_master_run_log_id);
            WHEN FALSE THEN
                g_result := pete_configuration_runner.run_suite(a_suite_name_in        => l_suite_name,
                                                                a_parent_run_log_id_in => g_master_run_log_id);
        END CASE;
        --
        end_test;
        --
    END run_test_suite;

    --------------------------------------------------------------------------------
    PROCEDURE run_test_script(a_script_name_in IN VARCHAR2) IS
    BEGIN
        IF a_script_name_in IS NULL
        THEN
            raise_application_error(-20000, 'Test script name not specified');
        END IF;
        --
        begin_test(a_object_name_in => a_script_name_in,
                   a_object_type_in => pete_core.g_OBJECT_TYPE_SCRIPT);
    
        --
        g_result := pete_configuration_runner.run_script(a_script_name_in       => a_script_name_in,
                                                         a_parent_run_log_id_in => g_master_run_log_id);
        --
        end_test;
        --
    END run_test_script;

    --------------------------------------------------------------------------------
    PROCEDURE run_test_case(a_case_name_in VARCHAR2) IS
    BEGIN
        IF a_case_name_in IS NULL
        THEN
            raise_application_error(-20000, 'Test case name not specified');
        END IF;
        --
        begin_test(a_object_name_in => a_case_name_in,
                   a_object_type_in => pete_core.g_OBJECT_TYPE_CASE);
    
        --
        g_result := pete_configuration_runner.run_case(a_case_name_in         => a_case_name_in,
                                                       a_parent_run_log_id_in => g_master_run_log_id);
        --
        end_test;
        --
    END run_test_case;

    --------------------------------------------------------------------------------
    PROCEDURE run_test_package
    (
        a_package_name_in     IN VARCHAR2,
        a_method_name_like_in IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        IF a_package_name_in IS NULL
        THEN
            raise_application_error(-20000, 'Test package name not specified');
        END IF;
        --
        begin_test(a_object_name_in => a_package_name_in,
                   a_object_type_in => pete_core.g_OBJECT_TYPE_PACKAGE);
        --
        g_result := pete_convention_runner.run_package(a_package_name_in      => a_package_name_in,
                                                       a_method_name_like_in  => a_method_name_like_in,
                                                       a_parent_run_log_id_in => g_master_run_log_id);
    
        --
        end_test;
        --
    END run_test_package;

    --------------------------------------------------------------------------------
    PROCEDURE run_all_tests IS
    BEGIN
        --
        begin_test(a_object_name_in => 'Run all test',
                   a_object_type_in => pete_core.g_OBJECT_TYPE_PETE);
        --
        --1. run all Configuration scripts
        g_result := pete_configuration_runner.run_all_test_scripts AND g_result;
        --2. run user Conventional suite
        --TODO: fix test result
        g_result := pete_convention_runner.run_suite(a_suite_name_in        => USER,
                                                     a_parent_run_log_id_in => g_master_run_log_id) AND
                    g_result;
        --
        end_test;
        --
    END run_all_tests;

END;
/
