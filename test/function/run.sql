@&&run_dir_begin



prompt Install test package UT_PETE_FUNCTIONS
@@ut_pete_functions.package.sql

rem prompt Run test package UT_PETE_FUNCTIONS
rem exec pete.run(a_package_name_in => 'UT_PETE_FUNCTIONS');

@&&run_dir_end
