rem
rem Creates Pete schema/schemas
rem
rem Usage
rem     sql @create.sql <environment>
rem
rem Options
rem
rem   environment - development - creates PETE_<version>_DEV and PETE_<version>_OTH schemas for development and testing of Pete
rem                             - see schema/create_development.sql
rem               - production  - creates PETE_<version> schema
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

prompt create module schema
@&&run_dir module

show errors

exit
