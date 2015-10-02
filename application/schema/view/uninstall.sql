@&&run_dir_begin

rem drop view petev_test_case_run;
rem drop view petev_test_script_run;

prompt Dropping view PETEV_OUTPUT_RUN_LOG
drop view petev_output_run_log;

rem Pete Configuration Runner API Views
prompt Dropping view PETEV_PLSQL_BLOCK
drop view petev_plsql_block;

prompt Dropping view PETEV_EXPECTED_RESULT
drop view petev_expected_result;

prompt Dropping view PETEV_INPUT_ARGUMENT
drop view petev_input_argument;

prompt Dropping view PETEV_PLSQL_BLOCK_IN_CASE
drop view petev_plsql_block_in_case;

prompt Dropping view PETEV_TEST_CASE
drop view petev_test_case;

prompt Dropping view PETEV_TEST_CASE_IN_SUITE
drop view petev_test_case_in_suite;

prompt Dropping view PETEV_TEST_SUITE
drop view petev_test_suite;

@&&run_dir_end
