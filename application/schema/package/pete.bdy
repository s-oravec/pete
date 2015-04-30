CREATE OR REPLACE PACKAGE BODY pete AS

    --------------------------------------------------------------------------------
    PROCEDURE run
    (
        a_suite_name_in         IN VARCHAR2 DEFAULT NULL,
        a_package_name_in       IN VARCHAR2 DEFAULT NULL,
        a_method_name_in        IN VARCHAR2 DEFAULT NULL,
        a_script_code_in        IN VARCHAR2 DEFAULT NULL,
        a_case_code_in          IN VARCHAR2 DEFAULT NULL,
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
          SELECT a_script_code_in AS x
            FROM dual
          UNION ALL
          SELECT a_case_code_in AS x
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
        ELSIF a_script_code_in IS NOT NULL
        THEN
            run_test_script(a_script_code_in => a_script_code_in);
        ELSIF a_case_code_in IS NOT NULL
        THEN
            run_test_case(a_case_code_in => a_case_code_in);
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
        a_suite_name_in         IN VARCHAR2,
        a_style_conventional_in IN BOOLEAN DEFAULT NULL
    ) IS
        l_style_conventional BOOLEAN := a_style_conventional_in;
        l_suite_name         VARCHAR2(255) := a_suite_name_in;
    BEGIN
        --
        IF a_suite_name_in IS NULL
        THEN
            l_style_conventional := TRUE;
            l_suite_name         := USER;
        END IF;
        --
        CASE l_style_conventional
            WHEN TRUE THEN
                petep_convention_runner.run_suite(a_suite_name_in => l_suite_name);
            WHEN FALSE THEN
                petep_configuration_runner.run_suite(a_suite_name_in => l_suite_name);
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
    PROCEDURE run_test_script(a_id_in NUMBER) IS
    BEGIN
        petep_configuration_runner.run_script(p_id => a_id_in);
    END run_test_script;

    --------------------------------------------------------------------------------
    PROCEDURE run_test_script(a_script_code_in IN VARCHAR2) IS
    BEGIN
        petep_configuration_runner.run_script(p_code => a_script_code_in);
    END run_test_script;

    --------------------------------------------------------------------------------
    PROCEDURE run_test_case(a_id_in IN NUMBER) IS
    BEGIN
        petep_configuration_runner.run_case(p_id => a_id_in);
    END run_test_case;

    --------------------------------------------------------------------------------
    PROCEDURE run_test_case(a_case_code_in VARCHAR2) IS
    BEGIN
        petep_configuration_runner.run_script(p_code => a_case_code_in);
    END run_test_case;

    --------------------------------------------------------------------------------
    PROCEDURE run_test_package
    (
        a_package_name_in     IN VARCHAR2,
        a_method_name_like_in IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        petep_convention_runner.run_package(a_package_name_in     => a_package_name_in,
                                            a_method_name_like_in => a_method_name_like_in);
    END run_test_package;

    --------------------------------------------------------------------------------
    PROCEDURE run_all_tests IS
    BEGIN
        raise_application_error(-20000, 'not implemented run');
        --1. run all Configuration scripts
        petep_configuration_runner.run_all_test_scripts;
        --2. run user Conventional suite
        run_test_suite(a_suite_name_in         => USER,
                       a_style_conventional_in => TRUE);
    END run_all_tests;

END;
/
