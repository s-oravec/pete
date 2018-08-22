accept l_schema_name  prompt "Package [&&g_package_name] schema [&&g_schema_name] : " default "&&g_schema_name"
accept l_schema_pwd   prompt "Package [&&g_package_name] schema password : " hide

define l_schema_name_oth = &&l_schema_name._OTH

connect &&l_schema_name/&&g_schema_pwd@local
set serveroutput on size unlimited
set trimspool on
exec pete.run_test_suite(suite_name => user);

connect &&l_schema_name_oth/&&g_schema_pwd@local
set serveroutput on size unlimited
set trimspool on
exec pete.run_test_suite(suite_name => user);

