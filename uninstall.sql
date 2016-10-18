rem
rem Uninstalls Pete objects
rem
rem Usage
rem     sql @uninstall.sql
rem
prompt init sqlsn
@sqlsnrc

prompt define action and script
define g_run_action = uninstall
define g_run_script = uninstall

prompt uninstall module
@&&run_dir module

purge recyclebin;

show errors

exit
