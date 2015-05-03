@&&run_dir_begin

set serveroutput on size unlimited

prompt
prompt Install test package UT_PETE
prompt ==================================
@@ut_pete.pck
prompt
prompt Run test package UT_PETE
prompt ===============================
exec pete.run(a_package_name_in => 'UT_PETE');
prompt
prompt
prompt Install test package UT_PETE_CONFIG_RUNNER
prompt ==================================
@@ut_pete_config_runner.pck
prompt
prompt Run test package UT_PETE
prompt ===============================
exec pete.run(a_package_name_in => 'UT_PETE_CONFIG_RUNNER');
prompt

@&&run_dir_end
