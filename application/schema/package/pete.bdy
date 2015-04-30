CREATE OR REPLACE PACKAGE BODY pete AS

    --------------------------------------------------------------------------------
    PROCEDURE run
    (
        a_suite_name_in      IN VARCHAR2 DEFAULT NULL,
        a_package_name_in    IN VARCHAR2 DEFAULT NULL,
        a_method_name_in     IN VARCHAR2 DEFAULT NULL,
        a_script_code_in     IN VARCHAR2 DEFAULT NULL,
        a_procedure_name_in  IN VARCHAR2 DEFAULT NULL,
        a_case_code_in       IN VARCHAR2 DEFAULT NULL,
        a_style_conventional IN BOOLEAN DEFAULT NULL
    ) IS
    BEGIN
        raise_application_error(-20000, 'not implemented run');
    END run;

    --------------------------------------------------------------------------------
    PROCEDURE run_suite
    (
        a_suite_name_in      IN VARCHAR2,
        a_style_conventional IN BOOLEAN DEFAULT NULL
    ) IS
    BEGIN
        raise_application_error(-20000, 'not implemented run_suite');
    END run_suite;

    --------------------------------------------------------------------------------
    PROCEDURE run_test_script(a_id_in NUMBER) IS
    BEGIN
        petep_configuration_runner.run_test_script(p_id => a_id_in);
    END;

    --------------------------------------------------------------------------------
    PROCEDURE run_test_script(a_script_code_in IN VARCHAR2) IS
    BEGIN
        petep_configuration_runner.run_test_script(p_code => a_script_code_in);
    END run_test_script;

    --------------------------------------------------------------------------------
    PROCEDURE run_test_case(a_id_in IN NUMBER) IS
    BEGIN
        petep_configuration_runner.run_test_case(p_id => a_id_in);
    END run_test_case;

    --------------------------------------------------------------------------------
    PROCEDURE run_test_case(a_test_case_code_in VARCHAR2) IS
    BEGIN
        petep_configuration_runner.run_test_script(p_code => a_test_case_code_in);
    END run_test_case;

    --------------------------------------------------------------------------------
    PROCEDURE test
    (
        a_package_name_in     IN VARCHAR2,
        a_method_name_mask_in IN VARCHAR2 DEFAULT NULL,
        a_same_package_in     IN BOOLEAN DEFAULT FALSE,
        a_prefix_in           VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        petep_convention_runner.test(a_package_name_in => a_package_name_in,
                                     a_test_package_in => a_same_package_in, --TODO: cleanup param name
                                     a_method_like_in  => a_method_name_mask_in); --TODO: cleanup param name
    END test;

    --------------------------------------------------------------------------------
    PROCEDURE run_all_tests IS
    BEGIN
        raise_application_error(-20000, 'not implemented run');
    END run_all_tests;

END;
/
