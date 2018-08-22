define l_schema_name     = &&g_schema_name
define l_schema_name_oth = &&g_schema_name._OTH
define l_schema_pwd      = &&g_schema_pwd

prompt .. Connecting to schema &&l_schema_name
connect &&l_schema_name/&&g_schema_pwd@local

prompt .. Uninstalling test packages in &&l_schema_name
drop package ut_pete_functions;
drop package ut_pete;
drop package ut_pete_assert;
drop package ut_pete_camelcase;
drop package ut_pete_config;
drop package ut_pete_convention_runner;
drop package ut_pete_logger;
drop package ut_pete_savepoint;
drop package ut_pete_utils;
drop package ut_test;

prompt .. Connecting to schema &&l_schema_name_oth
connect &&l_schema_name_oth/&&g_schema_pwd@local

prompt .. Uninstalling test packages in &&l_schema_name_oth
drop package ut_pete;

prompt .. Connecting to schema &&l_schema_name
connect &&l_schema_name/&&g_schema_pwd@local
