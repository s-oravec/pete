CREATE OR REPLACE PACKAGE pete AS

    VERSION CONSTANT VARCHAR2(100) := '0.1.1';

    /*
    
    Configuration
    pete.run(a_suite_in => 'suite_name');
    
    \a suite
        \a script
            \a case in order
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
    
    run for other optional arguments will run "subset": a_package_in - jednu package
    a_script in - jeden skript
    a_method_in - jednu metodu
    a_case_in - jeden test case.
    
    a_style_in is optional, unless it is impossible to decide to which style use, when both are available
    */

    --
    -- Runs test
    -- Universal run procedure. Can be used to run any unit of work of either testing style. 
    -- Other public run procedures call this one. It accepts only 
    -- - configuration arguments (a_suite_name_in, a_script_name_in, a_case_name_in) or
    -- - conventional arguments (a_suite_name_in, a_package_name_in, a_method_name_in) 
    -- not a combination from both sets
    -- testing style can be explicitly set by a_style_conventional_in argument
    --
    -- %argument a_suite_name_in Runs a suite of tests of a given name. If there are suites of both testing styles
    -- then throws an ge_ambiguous_input exception 
    --
    -- %argument a_package_name_in Runs all tests following convention in a given package 
    -- %argument a_method_name_mask_in Runs only tests of a given mask in a given package. Must be used with argument a_package_in
    -- %argument a_script_name_in Runs a test script of a given name
    -- %argument a_case_name_in Runs a test case of a given name
    -- %argument a_style_conventional If true
    --
    -- %throws ge_ambiguous_input 
    -- %throws ge_conflicting_input 
    --
    PROCEDURE run
    (
        a_suite_name_in         IN VARCHAR2 DEFAULT NULL,
        a_package_name_in       IN VARCHAR2 DEFAULT NULL,
        a_method_name_in        IN VARCHAR2 DEFAULT NULL,
        a_script_name_in        IN VARCHAR2 DEFAULT NULL,
        a_case_name_in          IN VARCHAR2 DEFAULT NULL,
        a_style_conventional_in IN BOOLEAN DEFAULT NULL,
        a_parent_run_log_id_in  IN INTEGER DEFAULT NULL
    );

    -- Thrown if the input can't be clearly interpreted
    ge_ambiguous_input EXCEPTION;
    gc_AMBIGUOUS_INPUT CONSTANT PLS_INTEGER := -20001;
    PRAGMA EXCEPTION_INIT(ge_ambiguous_input, -20001);
    -- Thrown if more conflicting arguments are set
    ge_conflicting_input EXCEPTION;
    gc_CONFLICTING_INPUT CONSTANT PLS_INTEGER := -20001;
    PRAGMA EXCEPTION_INIT(ge_ambiguous_input, -20002);

    --
    -- Runs a suite
    --
    -- %argument a_suite_name_in 
    -- %argument a_style_conventional
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
    -- Runs a script identified by name
    --
    -- %argument a_script_name_in name of the script to be run
    --
    PROCEDURE run_test_script
    (
        a_script_name_in       IN VARCHAR2,
        a_parent_run_log_id_in IN INTEGER DEFAULT NULL
    );

    --
    -- Runs a script identified by name
    --
    -- %argument a_script_name_in name of the script to be run
    --
    PROCEDURE run_test_case
    (
        a_case_name_in         IN VARCHAR2,
        a_parent_run_log_id_in IN INTEGER DEFAULT NULL
    );

    --
    -- Runs tests for a given package. Such tests are in a test package which can be derived from the given one.    
    -- throws tests not found if there are no tests to be run
    --
    -- %argument a_package_in 
    -- %argument a_method_name_like_in 
    -- %argument a_is_test_package_in 
    -- %argument a_prefix_in 
    --
    PROCEDURE run_test_package
    (
        a_package_name_in      IN VARCHAR2,
        a_method_name_like_in  IN VARCHAR2 DEFAULT NULL,
        a_parent_run_log_id_in IN INTEGER DEFAULT NULL
    );

    --
    -- Runs all availaible tests. That means all configured scripts from table pete_scripts and all
    -- test packages conforming convention.
    --
    PROCEDURE run_all_tests(a_parent_run_log_id_in IN INTEGER DEFAULT NULL);

    --
    -- core --------------------------------------------------------------------------------
    --
    PROCEDURE init(a_log_to_dbms_output_in IN BOOLEAN DEFAULT TRUE);

END;
/
