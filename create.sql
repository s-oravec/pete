rem
rem Creates Pete schema/schemas
rem
rem Usage
rem     sql @create.sql <environment>
rem
rem Options
rem
rem   environment - development - creates PETE_010000_DEV and PETE_010000_OTH schemas for development and testingf of Pete
rem                             - see schema/create_development.sql
rem               - production  - creates PETE_010000 schema
rem                             - see schema/create_production.sql
rem
set verify off
define g_environment = "&1"

prompt init sqlsn
@sqlsnrc

--we need sqlsn run module to traverse directory tree during install
prompt require sqlsn-run module
@&&sqlsn_require sqlsn-run

prompt define action and script
define g_run_action = create
define g_run_script = create_&&g_environment..sql

prompt install application
@&&run_dir application

show errors

exit
