--load required module

--define locals
define l_module_name = "&1"

prompt Loading required module [&&l_module_name]
whenever oserror exit rollback
@&&g_sqlsn_modules_path./&&l_module_name./module.sql "&&g_sqlsn_modules_path./&&l_module_name"
whenever oserror continue

--undefine locals
undefine l_module_name