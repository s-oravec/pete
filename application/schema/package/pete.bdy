CREATE OR REPLACE PACKAGE BODY pete AS

    g_INIT_BY_METHOD CONSTANT VARCHAR2(255) := 'METHOD';
    g_INIT_BY_USER   CONSTANT VARCHAR2(255) := 'USER';

    g_init_by VARCHAR2(255);
    g_result  pete_core.typ_is_success := TRUE;

    --------------------------------------------------------------------------------
    PROCEDURE init_impl
    (
        a_init_by               IN VARCHAR2,
        a_log_to_dbms_output_in IN BOOLEAN DEFAULT TRUE
    ) IS
    BEGIN
        --
        g_init_by := a_init_by;
        pete_logger.init(a_log_to_dbms_output_in => a_log_to_dbms_output_in);
    END;

    --------------------------------------------------------------------------------
    PROCEDURE init(a_log_to_dbms_output_in IN BOOLEAN DEFAULT TRUE) IS
    BEGIN
        init_impl(a_init_by               => g_INIT_BY_USER,
                  a_log_to_dbms_output_in => a_log_to_dbms_output_in);
    END init;

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
        a_style_conventional_in IN BOOLEAN DEFAULT NULL
    ) IS
        l_style_conventional BOOLEAN := a_style_conventional_in;
        l_suite_name         VARCHAR2(255) := a_suite_name_in;
    BEGIN
        --
        init_impl(a_init_by => g_INIT_BY_METHOD);
        --
        IF a_suite_name_in IS NULL
        THEN
            l_style_conventional := TRUE;
            l_suite_name         := USER;
        END IF;
        --
        CASE l_style_conventional
            WHEN TRUE THEN
                g_result := pete_convention_runner.run_suite(a_suite_name_in => l_suite_name);
            WHEN FALSE THEN
                g_result := pete_configuration_runner.run_suite(a_suite_name_in => l_suite_name);
            ELSE
                --
                -- 1. find configuration suite
                -- 2.1. if \e conf suite && \e conv suite -> raise ambiguous
                -- 2.2. if ~\e conf suite && ~\e conv suite -> raise not exists
                -- 2.3. run 
                raise_application_error(-20000, 'not implemented run_suite');
        END CASE;
        --
    END run_test_suite;

    --------------------------------------------------------------------------------
    PROCEDURE run_test_script(a_script_name_in IN VARCHAR2) IS
    BEGIN
        IF a_script_name_in IS NULL
        THEN
            raise_application_error(-20000, 'Test script name not specified');
        END IF;
        init_impl(a_init_by => g_INIT_BY_METHOD);
        g_result := pete_configuration_runner.run_script(a_script_name_in => a_script_name_in);
    END run_test_script;

    --------------------------------------------------------------------------------
    PROCEDURE run_test_case(a_case_name_in VARCHAR2) IS
    BEGIN
        IF a_case_name_in IS NULL
        THEN
            raise_application_error(-20000, 'Test case name not specified');
        END IF;
        init_impl(a_init_by => g_INIT_BY_METHOD);
        g_result := pete_configuration_runner.run_case(a_case_name_in => a_case_name_in);
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
        init_impl(a_init_by => g_INIT_BY_METHOD);
        g_result := pete_convention_runner.run_package(a_package_name_in     => a_package_name_in,
                                                       a_method_name_like_in => a_method_name_like_in);
    END run_test_package;

    --------------------------------------------------------------------------------
    PROCEDURE run_all_tests IS
    BEGIN
        init_impl(a_init_by => g_INIT_BY_METHOD);
        --1. run all Configuration scripts
        g_result := pete_configuration_runner.run_all_test_scripts;
        --2. run user Conventional suite
        --TODO: fix test result
        run_test_suite(a_suite_name_in         => USER,
                       a_style_conventional_in => TRUE);
    END run_all_tests;

END;
/
