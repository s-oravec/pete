@&&run_dir_begin

prompt Install test package UT_PETE
@@ut_pete.package.sql

prompt Install test package UT_PETE_CONFIG_RUNNER
@@ut_pete_config_runner.package.sql

prompt Install test package UT_PETE_CONVENTION_RUNNER
@@ut_pete_convention_runner.package.sql

prompt Install test package UT_PETE_ASSERT
@@ut_pete_assert.package.sql

prompt Install test package UT_PETE_SAVEPOINT
@@ut_pete_savepoint.package.sql

prompt Install test package UT_PETE_LOGGER
@@ut_pete_logger.package.sql

prompt Install test package UT_PETE_CONFIG
@@ut_pete_config.package.sql

prompt Install test package UT_PETE_CONFIG_RUNNER_API
@@ut_pete_config_runner_api.pkg

@&&run_dir_end
