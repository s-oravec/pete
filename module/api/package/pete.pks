create or replace package pete as

    VERSION constant varchar2(100) := '0.2.0';

    /*
    
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
    
    a_style_in is optional, unless it is impossible to decide to which style use, when both are available
    */

    --
    -- Runs test
    -- Universal run procedure. Can be used to run any unit of work of either testing style. 
    -- Other public run procedures call this one.
    --
    -- %argument suite_name Runs a suite of tests of a given name.
    --
    -- %argument package_name Runs all tests following convention in a given package 
    -- %argument a_method_name_mask_in Runs only tests of a given mask in a given package. Must be used with argument a_package_in
    -- %argument parent_run_log_id Specify parent run_log_id for recursive execution - used for testing of Pete
    --
    -- %throws ge_ambiguous_input 
    -- %throws ge_conflicting_input 
    --
    procedure run
    (
        suite_name        in varchar2 default null,
        package_name      in varchar2 default null,
        method_name       in varchar2 default null,
        parent_run_log_id in integer default null
    );

    subtype execution_result_type is pls_integer;

    function run
    (
        suite_name        in varchar2 default null,
        package_name      in varchar2 default null,
        method_name       in varchar2 default null,
        parent_run_log_id in integer default null
    ) return execution_result_type;

    -- Thrown if the input can't be clearly interpreted
    ge_ambiguous_input exception;
    gc_AMBIGUOUS_INPUT constant pls_integer := -20001;
    pragma exception_init(ge_ambiguous_input, -20001);
    -- Thrown if more conflicting arguments are set
    ge_conflicting_input exception;
    gc_CONFLICTING_INPUT constant pls_integer := -20002;
    pragma exception_init(ge_conflicting_input, -20002);

    --
    -- Runs a suite
    --
    -- %argument suite_name 
    -- %argument parent_run_log_id Specify parent run_log_id for recursive execution - used for testing of Pete
    --
    -- %throws ge_ambiguous_input If the input can't be clearly interpreted
    --
    procedure run_test_suite
    (
        suite_name        in varchar2 default null,
        parent_run_log_id in integer default null
    );

    --
    -- Runs a suite
    --
    -- %argument suite_name
    -- %argument parent_run_log_id Specify parent run_log_id for recursive execution - used for testing of Pete
    --
    -- %returns execution_result_type execution result
    --
    -- %throws ge_ambiguous_input If the input can't be clearly interpreted
    --
    function run_test_suite
    (
        suite_name        in varchar2 default null,
        parent_run_log_id in integer default null
    ) return execution_result_type;

    --
    -- Runs tests for a given package. Such tests are in a test package which can be derived from the given one.    
    -- throws tests not found if there are no tests to be run
    --
    -- %argument a_package_in 
    -- %argument method_name_like 
    -- %argument parent_run_log_id Specify parent run_log_id for recursive execution - used for testing of Pete
    --
    procedure run_test_package
    (
        package_name      in varchar2,
        method_name_like  in varchar2 default null,
        parent_run_log_id in integer default null
    );

    --
    -- Runs tests for a given package. Such tests are in a test package which can be derived from the given one.    
    -- throws tests not found if there are no tests to be run
    --
    -- %argument a_package_in 
    -- %argument method_name_like 
    -- %argument parent_run_log_id Specify parent run_log_id for recursive execution - used for testing of Pete
    --
    -- %returns execution_result_type execution result
    --
    function run_test_package
    (
        package_name      in varchar2,
        method_name_like  in varchar2 default null,
        parent_run_log_id in integer default null
    ) return execution_result_type;

    --
    -- Runs all availaible tests. That means all configured test suites from table pete_suite and all
    -- test packages conforming convention
    --
    -- %argument parent_run_log_id Specify parent run_log_id for recursive execution - used for testing of Pete
    --
    procedure run_all_tests(parent_run_log_id in integer default null);

    --
    -- Runs all availaible tests. That means all configured test suites from table pete_suite and all
    -- test packages conforming convention.
    --
    -- %argument parent_run_log_id Specify parent run_log_id for recursive execution - used for testing of Pete
    --
    -- %returns execution_result_type execution result
    --
    function run_all_tests(parent_run_log_id in integer default null) return execution_result_type;

    --
    --set tested method description in test package implementation
    --
    -- %argument description description
    --
    procedure set_method_description(description in varchar2);

    --
    -- init Pete with suppressed log to DBMS_OUTPUT
    --
    -- %argument log_to_dbms_output - true - log to DBMS_OUTPUT | false - supress logging to DBMS_OUTPUT
    --
    procedure init(log_to_dbms_output in boolean default true);

end;
/