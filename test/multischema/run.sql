@&&run_dir_begin

rem TODO: get pete schema from some common config
define g_pete_schema = PETE_010000_DEV
@&&run_script ../../application/api/synonyms.sql

prompt g_run_path &&g_run_path
@&&run_dir package

prompt Run Pete Multischema tests
set serveroutput on size unlimited
exec pete.run_test_suite(a_suite_name_in => user);

@&&run_dir_end
