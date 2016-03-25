CREATE OR REPLACE PACKAGE pete_configuration_runner IS

    --
    -- Package for running unit tests defined by configuration
    -- do not call these methods directly - use Pete package instead
    --

    --
    -- runs test suite
    -- %argument a_suite_name_in suite name
    -- %argument a_parent_run_log_id_in Specify parent run_log_id for recursive execution - used for testing of Pete
    --
    FUNCTION run_suite
    (
        a_suite_name_in        IN pete_types.typ_object_name,
        a_parent_run_log_id_in IN pete_run_log.parent_id%TYPE DEFAULT NULL
    ) RETURN pete_types.typ_execution_result;

    --
    -- Run test case identified by test case name - pete_test_case.name
    --
    -- %argument p_name Test case name - pete_test_case.name
    -- %argument a_parent_run_log_id_in Specify parent run_log_id for recursive execution - used for testing of Pete
    --
    FUNCTION run_case
    (
        a_case_name_in         IN pete_types.typ_object_name,
        a_parent_run_log_id_in IN pete_run_log.parent_id%TYPE DEFAULT NULL
    ) RETURN pete_types.typ_execution_result;

    --
    -- Run all test suites
    --
    FUNCTION run_all_test_suites(a_parent_run_log_id_in IN pete_run_log.parent_id%TYPE DEFAULT NULL)
        RETURN pete_types.typ_execution_result;

END pete_configuration_runner;
/
