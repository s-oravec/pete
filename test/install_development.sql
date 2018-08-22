define l_schema_name     = &&g_schema_name
define l_schema_name_oth = &&g_schema_name._OTH
define l_schema_pwd      = &&g_schema_pwd

prompt .. Connecting to schema &&l_schema_name
connect &&l_schema_name/&&g_schema_pwd@local

prompt .. Installing test packages in &&l_schema_name
@test/singleschema/function/ut_pete_functions.pkg
@test/singleschema/package/ut_pete.pkg
@test/singleschema/package/ut_pete_assert.pkg
@test/singleschema/package/ut_pete_camelcase.pkg
@test/singleschema/package/ut_pete_config.pkg
@test/singleschema/package/ut_pete_convention_runner.pkg
@test/singleschema/package/ut_pete_logger.pkg
@test/singleschema/package/ut_pete_savepoint.pkg
@test/singleschema/package/ut_pete_utils.pkg
@test/singleschema/package/ut_test.pkg

prompt .. Connecting to schema &&l_schema_name_oth
connect &&l_schema_name_oth/&&g_schema_pwd@local

prompt .. Set dependency of &&l_schema_name_oth on Pete installed in &&l_schema_name
@module/api/set_dependency_ref_owner.sql

prompt .. Installing test packages in &&l_schema_name_oth
@test/multischema/package/ut_pete.pkg

prompt .. Connecting to schema &&l_schema_name
connect &&l_schema_name/&&g_schema_pwd@local
