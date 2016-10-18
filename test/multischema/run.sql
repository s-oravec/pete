define g_pete_schema = PETE_&&g_sql_version._DEV

prompt Create synonyms for Pete objects in PETE_&&g_sql_version._OTH
@&&run_script ../../module/api/synonyms.sql

@&&run_script ../drop_all_test_packages.sql

prompt Create test packages for granted package
@&&run_dir package

@&&run_script ../recompile_schema_with_debug.sql
@&&run_script ../run_test_suite_from_user.sql

