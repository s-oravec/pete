@&&run_dir_begin

set serveroutput on size unlimited

prompt
prompt Install test package UT_PETE_FUNCTIONS
prompt ==================================
@@ut_pete_functions.pck
prompt
prompt Run test package UT_PETE_FUNCTIONS
prompt ===============================
exec pete.run(a_package_name_in => 'UT_PETE_FUNCTIONS');
prompt

@&&run_dir_end
