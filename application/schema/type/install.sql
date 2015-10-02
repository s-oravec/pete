@&&run_dir_begin

rem Pete logging
prompt Creating type petet_log
@@petet_log.spec.sql

prompt Creating type petet_log_tab
@@petet_log_tab.spec.sql

rem Sum interval
prompt Creating type petet_sum_interval
@@petet_sum_interval.spec.sql

prompt Creating type body petet_sum_interval
@@petet_sum_interval.body.sql

rem Pete Configuration Runner API types
prompt Creating type petet_plsql_block
@@petet_plsql_block.tps

prompt Creating type body petet_plsql_block
@@petet_plsql_block.tpb

prompt Creating type petet_expected_result
@@petet_expected_result.tps

prompt Creating type body petet_expected_result
@@petet_expected_result.tpb

prompt Creating type petet_input_argument
@@petet_input_argument.tps

prompt Creating type body petet_input_argument
@@petet_input_argument.tpb

prompt Creating type petet_plsql_block_in_case
@@petet_plsql_block_in_case.tps

prompt Creating type body petet_plsql_block_in_case
@@petet_plsql_block_in_case.tpb

prompt Creating type petet_plsql_blocks_in_case
@@petet_plsql_blocks_in_case.tps

prompt Creating type petet_test_case
@@petet_test_case.tps

prompt Creating type body petet_test_case
@@petet_test_case.tpb

prompt Creating type petet_test_case_in_suite
@@petet_test_case_in_suite.tps

prompt Creating type body petet_test_case_in_suite
@@petet_test_case_in_suite.tpb

prompt Creating type petet_test_cases_in_suite
@@petet_test_cases_in_suite.tps

prompt Creating type petet_test_suite
@@petet_test_suite.tps

prompt Creating type body petet_test_suite
@@petet_test_suite.tpb

@&&run_dir_end
