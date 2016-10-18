rem
rem Tests Pete, using Pete
rem
rem Usage
rem     sql @test.sql
rem
prompt init sqlsn
@sqlsnrc

prompt define test action and script
define g_run_action = run
define g_run_script = run

@&&run_dir test

exit