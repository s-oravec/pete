@&&run_dir_begin

@&&run_dir function
@&&run_dir package

set serveroutput on size unlimited
exec pete.run_test_suite;

@&&run_dir_end
