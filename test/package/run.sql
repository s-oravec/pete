@&&run_dir_begin

prompt Install test package UT_PETE
@@ut_pete.package.sql

rem prompt Run test package UT_PETE
rem exec pete.run(a_package_name_in => 'UT_PETE');

prompt Install test package UT_PETE_CONFIG_RUNNER
@@ut_pete_config_runner.package.sql

rem prompt Run test package UT_PETE
rem exec pete.run(a_package_name_in => 'UT_PETE_CONFIG_RUNNER');

prompt Install test package UT_PETE_ASSERT
@@ut_pete_assert.package.sql

rem prompt Run test package UT_PETE_ASSERT
rem exec pete.run(a_package_name_in => 'UT_PETE_ASSERT');

prompt Install test package UT_PETE_SAVEPOINT
@@ut_pete_savepoint.package.sql

rem prompt Run test package UT_PETE_SAVEPOINT
rem exec pete.run(a_package_name_in => 'UT_PETE_SAVEPOINT');

prompt Install test package UT_PETE_LOGGER
@@ut_pete_logger.package.sql

rem prompt Run test package UT_PETE_SAVEPOINT
rem exec pete.run(a_package_name_in => 'UT_PETE_LOGGER');

@&&run_dir_end
