whenever sqlerror exit 1 rollback

rem Pete 1.0.0
define g_pete_prod_schema_def       = "PETE_010000"
define g_pete_prod_schema_tbspc_def = "USERS"
define g_pete_prod_temp_tbspc_def   = "TEMP"

accept g_pete_prod_schema       prompt "Pete schema [&&g_pete_prod_schema_def] : " default "&&g_pete_prod_schema_def"
accept g_pete_prod_schema_pwd   prompt "Pete schema password : " hide
accept g_pete_prod_schema_tbspc prompt "Pete schema tablespace [&&g_pete_prod_schema_tbspc_def] : " default "&&g_pete_prod_schema_tbspc_def"
accept g_pete_prod_temp_tbspc   prompt "Pete temp tablespace [&&g_pete_prod_temp_tbspc_def] : " default "&&g_pete_prod_temp_tbspc_def"

declare
  lc_error_message constant varchar2(255) := 'ERROR: Zero-length password not permitted.';
begin
  dbms_output.put_line(lc_error_message);
  if '&&g_pete_prod_schema_pwd' is null then
    raise_application_error(-20000, lc_error_message);
  end if;
end;
/

prompt .. Creating Pete schema [&&g_pete_prod_schema] with default tablespace [&&g_pete_prod_schema_tbspc] and temp tablespace [&&g_pete_prod_temp_tbspc]
create user &&g_pete_prod_schema
  identified by "&&g_pete_prod_schema_pwd"
  default tablespace &&g_pete_prod_schema_tbspc
  temporary tablespace &&g_pete_prod_temp_tbspc
  quota unlimited on &&g_pete_prod_schema_tbspc
  account unlock
/

prompt .. Granting privileges to Pete production schema [&&g_pete_prod_schema]

prompt .. Granting CREATE SESSION to &&g_pete_prod_schema
grant create session to &&g_pete_prod_schema;

prompt .. Granting CREATE TABLE to &&g_pete_prod_schema
grant create table to &&g_pete_prod_schema;

prompt .. Granting CREATE PROCEDURE to &&g_pete_prod_schema
grant create procedure to &&g_pete_prod_schema;

prompt .. Granting CREATE TYPE to &&g_pete_prod_schema
grant create type to &&g_pete_prod_schema;

prompt .. Granting CREATE SEQUENCE to &&g_pete_prod_schema
grant create sequence to &&g_pete_prod_schema;

prompt .. Granting CREATE VIEW to &&g_pete_prod_schema
grant create view to &&g_pete_prod_schema;