@&&run_dir_begin

prompt Creating package PETE_CONFIG
@@pete_config.spec.sql

prompt Creating package PETE_LOGGER
@@pete_logger.spec.sql

prompt Creating package PETE_CORE
@@pete_core.spec.sql

prompt Creating package PETE_ASSERT
@@pete_assert.spec.sql

prompt Creating package PETE_CONFIGURATION_RUNNER
@@pete_configuration_runner.spec.sql

prompt Creating package PETE_CONVENTION_RUNNER
@@pete_convention_runner.spec.sql

prompt Creating package PETE_CONFIGURATION_RUNNER_API
@@pete_configuration_runner_api.pks

prompt Creating package PETE
@@pete.spec.sql

prompt Creating package body PETE
@@pete.body.sql

prompt Creating package body PETE_ASSERT
@@pete_assert.body.sql

prompt Creating package body PETE_CONFIG
@@pete_config.body.sql

prompt Creating package body PETE_CONFIGURATION_RUNNER
@@pete_configuration_runner.body.sql

prompt Creating package body PETE_CONVENTION_RUNNER
@@pete_convention_runner.body.sql

prompt Creating package body PETE_CONFIGURATION_RUNNER_API
@@pete_configuration_runner_api.pkb

prompt Creating package body PETE_CORE
@@pete_core.body.sql

prompt Creating package body PETE_LOGGER
@@pete_logger.body.sql



@&&run_dir_end


