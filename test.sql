rem
rem Test package
rem
rem Usage
rem     SQL> @test.sql <configuration>
rem
rem Options
rem
rem     configuration - manual     - asks for configuration parameters
rem                   - configured - supplied configuration is used
rem
set verify off
define l_configuration = "&1"

undefine 1

rem Load package
@package.sql

set serveroutput on size unlimited

clear screen

prompt .. Resetting packages
exec dbms_session.reset_package;

prompt .. Re-enabling DBMS_OUTPUT
exec dbms_output.enable;

prompt .. Executing all test in current schema
@test/run_&&l_configuration..sql

prompt done
