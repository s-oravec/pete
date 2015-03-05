prompt drop pete_test user
drop user pete_test cascade;

prompt create new pete_test user
create user pete_test identified by pete_test
  default tablespace users temporary tablespace temp
  quota unlimited on users;
  
grant dba to pete_test;

connect pete_test/pete_test@local

prompt install pete application
@install

exit