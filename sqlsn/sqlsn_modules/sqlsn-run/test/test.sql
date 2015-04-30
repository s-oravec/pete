--init sqlsn
@sqlsnrc

--test init and load
@@sqlsn-should-init

--test
--require module from path
@&&sqlsn_require_from_path ".."

--stack should be loaded by run module
@@stack-module-should-load
--test run module load
@@run-module-should-load

--run scripts stored in directory tree
--walk tree up and down
@&&run_dir test_application

prompt
exit