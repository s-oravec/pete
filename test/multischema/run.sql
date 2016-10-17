@&&run_dir_begin

rem connected as PETE_<version>_OTH

define g_pete_schema = PETE_&&g_version._DEV

prompt Create synonyms for Pete objects in PETE_&&g_version._OTH
@&&run_script ../../application/api/synonyms.sql

@&&run_script ../drop_all_test_packages.sql

prompt Create test packages for granted package
@&&run_dir package

@&&run_script ../recompile_schema_with_debug.sql
@&&run_Script ../run_test_suite_from_user.sql

@&&run_dir_end
