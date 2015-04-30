--init sqlsn
@sqlsnrc.sql

--case
prompt
prompt * case [required module should load]

prompt require module foo
@&&sqlsn_require foo

--assertions
prompt - command foo_bar [&&foo_bar] should be defined 

--case
undefine foo_bar
prompt
prompt * case [require module from path]
prompt require module sqlsn_modules/foo
@&&sqlsn_require_from_path "sqlsn_modules/foo"

prompt - command foo_bar [&&foo_bar] should be defined

--case
prompt
prompt * case [require of nonexistent module should fail]

--assertions
prompt skipped
--x prompt try to load module bar which does not exist
--x prompt should exit SQL*Plus with rollback
--x @&&sqlsn_require bar

exit
