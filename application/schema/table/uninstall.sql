@&&run_dir_begin

drop table pete_test_script cascade constraints purge;
drop table pete_input_param cascade constraints purge;
drop table pete_plsql_block cascade constraints purge;
drop table pete_test_case cascade constraints purge;
drop table pete_plsql_block_in_case cascade constraints purge;
drop table pete_test_case_in_script cascade constraints purge;
drop table pete_configuration cascade constraints purge;
drop table pete_run_log cascade constraints purge;
drop table pete_run_log_detail cascade constraints purge;
drop table pete_output_param cascade constraints purge;

@&&run_dir_end
