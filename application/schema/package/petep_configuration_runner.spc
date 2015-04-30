CREATE OR REPLACE PACKAGE petep_configuration_runner is

    /* Package for running unit tests defined by configuration
    */

    /* Subtype for boolean stored as Y/N
    */
    SUBTYPE gtyp_string_boolean IS CHAR(1);
    -- Yes, true
    gc_true CONSTANT gtyp_string_boolean := 'Y';
    -- No, false
    gc_false CONSTANT gtyp_string_boolean := 'N';

    /* Run test case identified by test case id
    
    %param p_id Test case identifier - pete_test_case.id
    */
    PROCEDURE run_test_case(p_id IN pete_test_case.id%TYPE);

    /* Run test case identified by test case code - pete_test_case.code
    
    %param p_code Test case code - pete_test_case.code
    */
    PROCEDURE run_test_case(p_code pete_test_case.code%TYPE);

    /* Run test script identified by test script identifier - pete_test_script.id
    
    %param p_id test script identifier - pete_test_script.id
    */
    PROCEDURE run_test_script(p_id pete_test_script.id%TYPE);

    /* Run test script identified by test script code - pete_test_script.code
    
    %param p_code  test script code - pete_test_script.code
    */
    PROCEDURE run_test_script(p_code pete_test_script.code%TYPE);

    /* Run all test scripts
    
    %param p_catch_exception  boolean - ('Y','N') 'Y' - continue executing scripts after exception
    */
    PROCEDURE run_all_test_scripts(p_catch_exception IN gtyp_string_boolean DEFAULT gc_true);

END petep_configuration_runner;
/
