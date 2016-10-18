rem
rem Installs Pete module into connected schema
rem
rem Usage
rem     sql @install.sql <privileges>
rem
rem Options
rem
rem   privileges - public - grant execute/select privileges on packages/views, so Pete can be used from different schemas
rem              - peer   - don't grant anything, use Pete as peer dependency
rem
set verify off
define g_privileges = "&1"

prompt init sqlsn
@sqlsnrc

prompt define action and script
define g_run_action = install
define g_run_script = install

prompt install module
@&&run_dir module

show errors

exit
