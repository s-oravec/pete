@&&run_dir_begin

rem prompt Creating view PETEV_TEST_CASE_RUN
rem @@petev_test_case_run.sql

rem prompt Creating view PETEV_TEST_SCRIPT_RUN
rem @@petev_test_script_run.sql

prompt Creating view PETEV_OUTPUT_RUN_LOG
@@petev_output_run_log.sql

rem Pete Configuration Runner API Views
prompt Creating view PETEV_PLSQL_BLOCK
@@petev_plsql_block.vw

prompt Creating view PETEV_TEST_CASE
@@petev_test_case.vw

prompt Creating view PETEV_EXPECTED_RESULT
@@petev_expected_result.vw

prompt Creating view PETEV_INPUT_ARGUMENT
@@petev_input_argument.vw

prompt Creating view PETEV_PLSQL_BLOCK_IN_CASE
@@petev_plsql_block_in_case.vw

prompt Creating view PETEV_TEST_CASE_IN_SUITE
@@petev_test_case_in_suite.vw

@&&run_dir_end
