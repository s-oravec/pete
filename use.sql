rem
rem Run from your schema to use specific Pete installation (schema)
rem
rem Usage
rem     sql @use.sql <Pete schema>
rem
set verify off
define g_pete_schema = "&1"

prompt init sqlsn
@sqlsnrc

--we need sqlsn run module to traverse directory tree during install
prompt require sqlsn-run module
@&&sqlsn_require sqlsn-run

prompt define action and script
define g_run_action = use
define g_run_script = use

prompt Use Pete schema
@&&run_dir application

show errors

exit
