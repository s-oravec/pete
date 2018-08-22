define l_schema_name     = &&g_schema_name
define l_schema_name_oth = &&g_schema_name._OTH
define l_schema_pwd      = &&g_schema_pwd

connect &&l_schema_name/&&g_schema_pwd@local
set trimspool on
set serveroutput on size unlimited
exec pete.run_test_suite(suite_name => user);

connect &&l_schema_name_oth/&&g_schema_pwd@local
set trimspool on
set serveroutput on size unlimited
exec pete.run_test_suite(suite_name => user);
