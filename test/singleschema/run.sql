@&&run_script ../drop_all_test_packages.sql

prompt Recreate all test packages
@&&run_dir function
@&&run_dir package
@&&run_dir type

@&&run_script ../recompile_schema_with_debug.sql
@&&run_script ../run_test_suite_from_user.sql
