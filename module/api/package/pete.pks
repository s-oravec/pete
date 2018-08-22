create or replace package pete as

    VERSION constant varchar2(100) := '0.2.0';

    /*
    
    Convention Over Configuration Test Runner

    exec pete.run();
    
    ```sql
    for each <schema>
        run <schema>.pete_before_all.run if exists

        for each <package> unordered; <package>.name like 'UT_%'
            run <schema>.pete_before_each.run if exists
            run <schema>.package.before_all if exists

            for each <schema>.<package>.<method> order by subprogram_id
                run <schema>.<package>.before_each if exists
                run <schema>.<package>.<method>
                run <schema>.<package>.after_each if exists

            run <schema>.package.after_all if exists
            run <schema>.pete_after_each.run if exists

        run <schema>.pete_after_all.run if exists
    ```

    */

    --
    -- Runs tests
    -- Universal run procedure. Can be used to run any unit of work.
    -- Other public run procedures call this one.
    --
    -- %param suite_name Runs a suite of tests of a given name.
    -- %param package_name Runs all tests following convention in a given package
    -- %param method_name Runs only tests of a given mask in a given package. Must be used with argument a_package_in
    -- %param parent_run_log_id Specify parent run_log_id for recursive execution - used for testing of Pete
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
    -- %param suite_name
    -- %param parent_run_log_id Specify parent run_log_id for recursive execution - used for testing of Pete
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
    -- %param suite_name
    -- %param parent_run_log_id Specify parent run_log_id for recursive execution - used for testing of Pete
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
    -- Runs tests for a given package.
    -- Such tests are in a test package which can be derived from the given one.
    --
    -- throws tests not found if there are no tests to be run
    --
    -- %param a_package_in
    -- %param method_name_like
    -- %param parent_run_log_id Specify parent run_log_id for recursive execution - used for testing of Pete
    --
    procedure run_test_package
    (
        package_name      in varchar2,
        method_name_like  in varchar2 default null,
        parent_run_log_id in integer default null
    );

    --
    -- Runs tests for a given package.
    -- Such tests are in a test package which can be derived from the given one.
    --
    -- throws tests not found if there are no tests to be run
    --
    -- %param a_package_in
    -- %param method_name_like
    -- %param parent_run_log_id Specify parent run_log_id for recursive execution - used for testing of Pete
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
    -- Runs all availaible tests - all test packages conforming convention
    --
    -- %param parent_run_log_id Specify parent run_log_id for recursive execution - used for testing of Pete
    --
    procedure run_all_tests(parent_run_log_id in integer default null);

    --
    -- Runs all availaible tests - all test packages conforming convention
    --
    -- %param parent_run_log_id Specify parent run_log_id for recursive execution - used for testing of Pete
    --
    -- %returns execution_result_type execution result
    --
    function run_all_tests(parent_run_log_id in integer default null) return execution_result_type;

    --
    --set tested method description in test package implementation
    --
    -- %param description description
    --
    procedure set_method_description(description in varchar2);

    --
    -- init Pete with suppressed log to DBMS_OUTPUT
    --
    -- %param log_to_dbms_output - true - log to DBMS_OUTPUT | false - supress logging to DBMS_OUTPUT
    --
    procedure init(log_to_dbms_output in boolean default true);

end;
/
