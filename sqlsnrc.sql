rem set sqlsn modules path
define g_sqlsn_modules_path = 'oradb_modules/sqlsn/sqlsn_modules'

rem init sqlsn-core module
set verify off
@&&g_sqlsn_modules_path/sqlsn-core/module.sql "&&g_sqlsn_modules_path/sqlsn-core"

rem required sqlsn modules
prompt require sqlsn-run module
@&&sqlsn_require sqlsn-run

rem set SQL*Plus settings
set serveroutput on size unlimited format wrapped
set trimspool on
set feedback off
set echo off
set lines 32767

prompt load package info
@@package.sql

