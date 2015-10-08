--set sqlsn modules path
set verify off
define g_sqlsn_modules_path = 'sqlsn/sqlsn_modules'

--init sqlsn-core module
@&&g_sqlsn_modules_path/sqlsn-core/module.sql "&&g_sqlsn_modules_path/sqlsn-core" 
