rem
rem Drops Pete schema/schemas
rem
rem Usage
rem     sql @drop.sql <environment>
rem
set verify off
define g_environment = "&1"

prompt init sqlsn
@sqlsnrc

prompt define action and script
define g_run_action = drop
define g_run_script = drop_&&g_environment..sql

prompt drop module schema 
@&&run_dir module

show errors

exit
