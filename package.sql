rem default SQL*Plus settings
set serveroutput on size unlimited
set trimspool on
set verify   off
set define   on
set lines    4000
set feedback off

rem Package name
define g_package_name="PETE"

rem SQL name compatible version string
define g_sql_version = "000200"

rem full semver version string
define g_semver_version = "0.2.0"

rem get current schema
define g_current_schema = "&&_USER"
column current_schema new_value g_current_schema
set termout off
select sys_context('userenv','current_schema') as current_schema from dual;
set termout on

rem overwrite config to change configured values
@config.sql

rem prompt config
prompt
prompt Loaded package
prompt .. package name      = "&&g_package_name"
prompt .. sql version       = "&&g_sql_version"
prompt .. semver version    = "&&g_semver_version"
prompt .. current user      = "&&_USER"
prompt .. current schema    = "&&g_current_schema"
prompt .. schema password   = "********"
prompt .. schema tablespace = "&&g_schema_tbspc"
prompt .. temp tablespace   = "&&g_temp_tbspc"
prompt
