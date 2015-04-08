prompt drop pete_test user
drop user pete_test cascade;

prompt create new pete_test user
create user pete_test identified by pete_test
  default tablespace users temporary tablespace temp
  quota unlimited on users;

grant connect to pete_test;  
grant create table to pete_test;
grant create procedure to pete_test;
grant create type to pete_test;
grant create sequence to pete_test;
grant create view to pete_test;
grant create materialized view to pete_test;

connect pete_test/pete_test@local

prompt install pete application
@install

prompt define action and script
define g_run_action = run
define g_run_script = run

@&&run_dir test

exit