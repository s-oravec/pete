CREATE OR REPLACE PACKAGE petep_configuration_runner IS

    --
    -- Package for running unit tests defined by configuration
    --

    --
    -- Subtype for boolean stored as Y/N
    --
    SUBTYPE gtyp_string_boolean IS CHAR(1);
    -- Yes, true
    gc_true CONSTANT gtyp_string_boolean := 'Y';
    -- No, false
    gc_false CONSTANT gtyp_string_boolean := 'N';

    --
    -- runs test suite
    -- %param a_suite_name_in suite name
    --
    PROCEDURE run_suite(a_suite_name_in IN VARCHAR2);

    --
    -- Run test case identified by test case id    
    -- %param p_id Test case identifier - pete_test_case.id
    --
    PROCEDURE run_case(p_id IN pete_test_case.id%TYPE);

    --
    -- Run test case identified by test case code - pete_test_case.code
    --
    --%param p_code Test case code - pete_test_case.code
    --
    PROCEDURE run_case(p_code pete_test_case.code%TYPE);

    --
    -- Run test script identified by test script identifier - pete_test_script.id
    --
    --%param p_id test script identifier - pete_test_script.id
    --
    PROCEDURE run_script(p_id pete_test_script.id%TYPE);

    --
    -- Run test script identified by test script code - pete_test_script.code
    --
    --%param p_code test script code - pete_test_script.code
    --
    PROCEDURE run_script(p_code pete_test_script.code%TYPE);

    --
    -- Run all test scripts
    --
    --%param p_catch_exception BOOLEAN -('Y', 'N') 'Y' - continue executing scripts AFTER EXCEPTION
    --
    PROCEDURE run_all_test_scripts(p_catch_exception IN gtyp_string_boolean DEFAULT gc_true);

END petep_configuration_runner;
/
