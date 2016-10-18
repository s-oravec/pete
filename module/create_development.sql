define g_pete_dev_schema       = "PETE_&&g_sql_version._DEV"
define g_pete_dev_other_schema = "PETE_&&g_sql_version._OTH"

rem Pete Development Schema
prompt create new &&g_pete_dev_schema user
create user &&g_pete_dev_schema identified by &&g_pete_dev_schema
  default tablespace users temporary tablespace temp
  quota unlimited on users;

grant connect to &&g_pete_dev_schema;
grant create table to &&g_pete_dev_schema;
grant create procedure to &&g_pete_dev_schema;
grant create type to &&g_pete_dev_schema;
grant create sequence to &&g_pete_dev_schema;
grant create view to &&g_pete_dev_schema;

--testing only
grant debug connect session to &&g_pete_dev_schema;

rem Pete Development Other Schema - for Multischema Dev/Test
prompt create new &&g_pete_dev_other_schema user
create user &&g_pete_dev_other_schema identified by &&g_pete_dev_other_schema
  default tablespace users temporary tablespace temp
  quota unlimited on users;

grant connect to &&g_pete_dev_other_schema;
grant create table to &&g_pete_dev_other_schema;
grant create procedure to &&g_pete_dev_other_schema;
grant create type to &&g_pete_dev_other_schema;
grant create sequence to &&g_pete_dev_other_schema;
grant create view to &&g_pete_dev_other_schema;
grant create synonym to &&g_pete_dev_other_schema;

--testing only
grant debug connect session to &&g_pete_dev_other_schema;


