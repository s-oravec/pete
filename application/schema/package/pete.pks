CREATE OR REPLACE PACKAGE pete AS

    VERSION CONSTANT VARCHAR2(100) := '0.2.0';

    /*
    
    Configuration
    pete.run(a_suite_in => 'suite_name');
    
    \a suite
       \a case in order [optional sub-cases]
          \a block in order
             execute immediate block
    Convention
    pete.run(a_suite_in => 'suite_name'
             a_style_in => pete_runner.convention);
    
    \a schema    
        if \e pete_before_all.run
        \a package unordered
            if \e pete_before_each.run
            if \e package.before_all
            \a method in order (subprogram_id)
                if \e package.before_each
                execute immediate method
                if \e package.after_each
            if \e package.after_all
            if \e pete_after_each.run
        if \e pete_after_all.run
    
    run for other optional arguments will run "subset": a_package_in - one package
    a_method_in - one method
    a_case_in   - one test case.
    
    a_style_in is optional, unless it is impossible to decide to which style use, when both are available
    */

    --
    -- Runs test
    -- Universal run procedure. Can be used to run any unit of work of either testing style. 
    -- Other public run procedures call this one. It accepts only 
    -- - configuration arguments (a_suite_name_in, a_case_name_in) or
    -- - conventional arguments (a_suite_name_in, a_package_name_in, a_method_name_in) 
    -- not a combination from both sets
    -- testing style can be explicitly set by a_style_conventional_in argument
    --
    -- %argument a_suite_name_in Runs a suite of tests of a given name. If there are suites of both testing styles
    -- then throws an ge_ambiguous_input exception 
    --
    -- %argument a_package_name_in Runs all tests following convention in a given package 
    -- %argument a_method_name_mask_in Runs only tests of a given mask in a given package. Must be used with argument a_package_in
    -- %argument a_case_name_in Runs a test case of a given name
    -- %argument a_style_conventional_in If true then specified suite is conventional
    -- %argument a_parent_run_log_id_in Specify parent run_log_id for recursive execution - used for testing of Pete
    --
    -- %throws ge_ambiguous_input 
    -- %throws ge_conflicting_input 
    --
    PROCEDURE run
    (
        a_suite_name_in         IN VARCHAR2 DEFAULT NULL,
        a_package_name_in       IN VARCHAR2 DEFAULT NULL,
        a_method_name_in        IN VARCHAR2 DEFAULT NULL,
        a_case_name_in          IN VARCHAR2 DEFAULT NULL,
        a_style_conventional_in IN BOOLEAN DEFAULT NULL,
        a_parent_run_log_id_in  IN INTEGER DEFAULT NULL
    );

    FUNCTION run
    (
        a_suite_name_in         IN VARCHAR2 DEFAULT NULL,
        a_package_name_in       IN VARCHAR2 DEFAULT NULL,
        a_method_name_in        IN VARCHAR2 DEFAULT NULL,
        a_case_name_in          IN VARCHAR2 DEFAULT NULL,
        a_style_conventional_in IN BOOLEAN DEFAULT NULL,
        a_parent_run_log_id_in  IN INTEGER DEFAULT NULL
    ) RETURN pete_types.typ_execution_result;

    -- Thrown if the input can't be clearly interpreted
    ge_ambiguous_input EXCEPTION;
    gc_AMBIGUOUS_INPUT CONSTANT PLS_INTEGER := -20001;
    PRAGMA EXCEPTION_INIT(ge_ambiguous_input, -20001);
    -- Thrown if more conflicting arguments are set
    ge_conflicting_input EXCEPTION;
    gc_CONFLICTING_INPUT CONSTANT PLS_INTEGER := -20002;
    PRAGMA EXCEPTION_INIT(ge_conflicting_input, -20002);

    --
    -- Runs a suite
    --
    -- %argument a_suite_name_in 
    -- %argument a_style_conventional
    -- %argument a_parent_run_log_id_in Specify parent run_log_id for recursive execution - used for testing of Pete
    --
    -- %throws ge_ambiguous_input If the input can't be clearly interpreted
    --
    PROCEDURE run_test_suite
    (
        a_suite_name_in         IN VARCHAR2 DEFAULT NULL,
        a_style_conventional_in IN BOOLEAN DEFAULT TRUE,
        a_parent_run_log_id_in  IN INTEGER DEFAULT NULL
    );

    --
    -- Runs a suite
    --
    -- %argument a_suite_name_in
    -- %argument a_style_conventional
    -- %argument a_parent_run_log_id_in Specify parent run_log_id for recursive execution - used for testing of Pete
    --
    -- %returns pete_types.typ_execution_result execution result
    --
    -- %throws ge_ambiguous_input If the input can't be clearly interpreted
    --
    FUNCTION run_test_suite
    (
        a_suite_name_in         IN VARCHAR2 DEFAULT NULL,
        a_style_conventional_in IN BOOLEAN DEFAULT TRUE,
        a_parent_run_log_id_in  IN INTEGER DEFAULT NULL
    ) RETURN pete_types.typ_execution_result;

    --
    -- Runs a test case identified by name
    --
    -- %argument a_case_name_in name of the test case to be run
    -- %argument a_parent_run_log_id_in Specify parent run_log_id for recursive execution - used for testing of Pete
    --
    PROCEDURE run_test_case
    (
        a_case_name_in         IN VARCHAR2,
        a_parent_run_log_id_in IN INTEGER DEFAULT NULL
    );

    --
    -- Runs a test case identified by name
    --
    -- %argument a_case_name_in name of the test case to be run
    -- %argument a_parent_run_log_id_in Specify parent run_log_id for recursive execution - used for testing of Pete
    --
    -- %returns pete_types.typ_execution_result execution result
    --
    FUNCTION run_test_case
    (
        a_case_name_in         IN VARCHAR2,
        a_parent_run_log_id_in IN INTEGER DEFAULT NULL
    ) RETURN pete_types.typ_execution_result;

    --
    -- Runs tests for a given package. Such tests are in a test package which can be derived from the given one.    
    -- throws tests not found if there are no tests to be run
    --
    -- %argument a_package_in 
    -- %argument a_method_name_like_in 
    -- %argument a_parent_run_log_id_in Specify parent run_log_id for recursive execution - used for testing of Pete
    --
    PROCEDURE run_test_package
    (
        a_package_name_in      IN VARCHAR2,
        a_method_name_like_in  IN VARCHAR2 DEFAULT NULL,
        a_parent_run_log_id_in IN INTEGER DEFAULT NULL
    );

    --
    -- Runs tests for a given package. Such tests are in a test package which can be derived from the given one.    
    -- throws tests not found if there are no tests to be run
    --
    -- %argument a_package_in 
    -- %argument a_method_name_like_in 
    -- %argument a_parent_run_log_id_in Specify parent run_log_id for recursive execution - used for testing of Pete
    --
    -- %returns pete_types.typ_execution_result execution result
    --
    FUNCTION run_test_package
    (
        a_package_name_in      IN VARCHAR2,
        a_method_name_like_in  IN VARCHAR2 DEFAULT NULL,
        a_parent_run_log_id_in IN INTEGER DEFAULT NULL
    ) RETURN pete_types.typ_execution_result;

    --
    -- Runs all availaible tests. That means all configured test suites from table pete_suite and all
    -- test packages conforming convention
    --
    -- %argument a_parent_run_log_id_in Specify parent run_log_id for recursive execution - used for testing of Pete
    --
    PROCEDURE run_all_tests(a_parent_run_log_id_in IN INTEGER DEFAULT NULL);

    --
    -- Runs all availaible tests. That means all configured test suites from table pete_suite and all
    -- test packages conforming convention.
    --
    -- %argument a_parent_run_log_id_in Specify parent run_log_id for recursive execution - used for testing of Pete
    --
    -- %returns pete_types.typ_execution_result execution result
    --
    FUNCTION run_all_tests(a_parent_run_log_id_in IN INTEGER DEFAULT NULL)
        RETURN pete_types.typ_execution_result;

    --
    --set tested method description in test package implementation
    --
    -- %argument a_description_in description
    --
    PROCEDURE set_method_description(a_description_in IN varchar2);

    --
    -- init Pete with suppressed log to DBMS_OUTPUT
    --
    -- %argument a_log_to_dbms_output_in - true - log to DBMS_OUTPUT | false - supress logging to DBMS_OUTPUT
    --
    PROCEDURE init(a_log_to_dbms_output_in IN BOOLEAN DEFAULT TRUE);

END;
/
