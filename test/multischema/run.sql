@&&run_dir_begin

@&&run_script ../../application/example/synonyms.sql

prompt g_run_path &&g_run_path
@&&run_dir package

prompt Run Pete Multischema tests
set serveroutput on size unlimited
exec pete.run_test_suite(a_suite_name_in => user);

@&&run_dir_end
