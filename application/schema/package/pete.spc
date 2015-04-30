CREATE OR REPLACE PACKAGE pete AS

    /*
    
    Configuration
    pete.run(a_suite_in => 'suite_code');
    
    \a suite
        \a script
            \a case in order
                \a block in order
                    execute immediate block
    Convention
    pete.run(a_suite_in => 'suite_code'
             a_style_in => petep_runner.convention);
    
    \a schema    
        if \e petep_before_all.run
        \a package unordered
            if \e petep_before_each.run
            if \e package.before_all
            \a method in order (subprogram_id)
                if \e package.before_each
                execute immediate method
                if \e package.after_each
            if \e package.after_all
            if \e petep_after_each.run
        if \e petep_after_all.run
    Activity
    
    run pro jiný nepovinný parametr by pouštìl "subset" toho výše: a_package_in - jednu package
    a_script in - jeden skript
    a_method_in - jednu metodu
    a_case_in - jeden test case.
    
    Pri vyplnìní a_package_in nebo a_method_in jde o "konvencni" spoustìní a proto budou rovnìž spuštìny všechny before/after metody/package
    
    a_style_in nepovinny, pouze, pokud dle obsahu parametru ke spousteni nepujde rozhodnout, který styl uživatel myslí (budou k dipozici oba)
    */

    --
    -- Runs test
    -- Universal run procedure. Can be used to run any unit of work of either testing style. 
    -- Other public run procedures call this one. It accepts only 
    -- - configuration parameters (a_suite_name_in, a_script_code_in, a_case_code_in) or
    -- - conventional parameters (a_suite_name_in, a_package_name_in, a_method_name_in) 
    -- not a combination from both sets
    -- testing style can be explicitly set by a_style_conventional_in parameter
    --
    -- %param a_suite_name_in Runs a suite of tests of a given name. If there are suites of both testing styles
    -- then throws an ge_ambiguous_input exception 
    --
    -- %param a_package_name_in Runs all tests following convention in a given package 
    -- %param a_method_name_mask_in Runs only tests of a given mask in a given package. Must be used with param a_package_in
    -- %param a_script_code_in Runs a test script of a given code
    -- %param a_case_code_in Runs a test case of a given code
    -- %param a_style_conventional If true
    --
    -- %throws ge_ambiguous_input 
    -- %throws ge_conflicting_input 
    --
    PROCEDURE run
    (
        a_suite_name_in         IN VARCHAR2 DEFAULT NULL,
        a_package_name_in       IN VARCHAR2 DEFAULT NULL,
        a_method_name_in        IN VARCHAR2 DEFAULT NULL,
        a_script_code_in        IN VARCHAR2 DEFAULT NULL,
        a_case_code_in          IN VARCHAR2 DEFAULT NULL,
        a_style_conventional_in IN BOOLEAN DEFAULT NULL
    );

    -- Thrown if the input can't be clearly interpreted
    ge_ambiguous_input EXCEPTION;
    gc_AMBIGUOUS_INPUT CONSTANT PLS_INTEGER := -20001;
    PRAGMA EXCEPTION_INIT(ge_ambiguous_input, -20001);
    -- Thrown if more conflicting parameters are set
    ge_conflicting_input EXCEPTION;
    gc_CONFLICTING_INPUT CONSTANT PLS_INTEGER := -20001;
    PRAGMA EXCEPTION_INIT(ge_ambiguous_input, -20002);

    --
    -- Runs a suite
    --
    -- %param a_suite_name_in 
    -- %param a_style_conventional
    --
    -- %throws ge_ambiguous_input If the input can't be clearly interpreted
    --
    PROCEDURE run_test_suite
    (
        a_suite_name_in         IN VARCHAR2,
        a_style_conventional_in IN BOOLEAN DEFAULT NULL
    );

    --
    -- Runs a script identified by id
    --
    -- %param a_id_in id of the script to be run
    --
    PROCEDURE run_test_script(a_id_in IN NUMBER);

    --
    -- Runs a script identified by code
    --
    -- %param a_script_code_in code of the script to be run
    --
    PROCEDURE run_test_script(a_script_code_in IN VARCHAR2);

    --
    -- Runs a test case identified by id
    --
    -- %param a_id_in id of the script to be run
    --
    PROCEDURE run_test_case(a_id_in IN NUMBER);

    --
    -- Runs a script identified by code
    --
    -- %param a_script_code_in Code of the script to be run
    --
    PROCEDURE run_test_case(a_case_code_in IN VARCHAR2);

    --
    -- Runs tests for a given package. Such tests are in a test package which can be derived from the given one.    
    -- throws tests not found if there are no tests to be run
    --
    -- %param a_package_in 
    -- %param a_method_name_like_in 
    -- %param a_is_test_package_in 
    -- %param a_prefix_in 
    --
    PROCEDURE run_test_package
    (
        a_package_name_in     IN VARCHAR2,
        a_method_name_like_in IN VARCHAR2 DEFAULT NULL
    );

    --
    -- Runs all availaible tests. That means all configured scripts from table pete_scripts and all
    -- test packages conforming convention.
    --
    PROCEDURE run_all_tests;
END;
/
