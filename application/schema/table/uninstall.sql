@&&run_dir_begin

prompt dropping table pete_test_suite
drop table pete_test_suite cascade constraints purge;

prompt dropping table pete_input_argument
drop table pete_input_argument cascade constraints purge;

prompt dropping table pete_plsql_block
drop table pete_plsql_block cascade constraints purge;

prompt dropping table pete_test_case
drop table pete_test_case cascade constraints purge;

prompt dropping table pete_plsql_block_in_case
drop table pete_plsql_block_in_case cascade constraints purge;

prompt dropping table pete_test_case_in_suite
drop table pete_test_case_in_suite cascade constraints purge;

prompt dropping table pete_test_case_in_case
drop table pete_test_case_in_case cascade constraints purge;

prompt dropping table pete_configuration
drop table pete_configuration cascade constraints purge;

prompt dropping table pete_run_log
drop table pete_run_log cascade constraints purge;

prompt dropping table pete_run_log_detail
drop table pete_run_log_detail cascade constraints purge;

prompt dropping table pete_expected_result
drop table pete_expected_result cascade constraints purge;

@&&run_dir_end
