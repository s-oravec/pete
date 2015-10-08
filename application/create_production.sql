rem Pete 1.0.0
define g_pete_production_schema = "PETE_010000"

--TODO: configurable tablespaces
prompt Create Pete schema [&&g_pete_production_schema]
create user &&g_pete_production_schema identified by &&g_pete_production_schema
  default tablespace users temporary tablespace temp
  quota unlimited on users;

prompt Grant privileges to Pete schema
grant connect to &&g_pete_production_schema;
grant create table to &&g_pete_production_schema;
grant create procedure to &&g_pete_production_schema;
grant create type to &&g_pete_production_schema;
grant create sequence to &&g_pete_production_schema;
grant create view to &&g_pete_production_schema;