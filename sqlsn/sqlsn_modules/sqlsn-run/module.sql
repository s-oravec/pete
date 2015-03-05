--module name and path
define l_path = "&1"

--save run module path to module_config
spool "&&l_path/lib/command/module_config.sql"
set termout off
prompt define run_module_path = "&&l_path"
set termout on
spool off

--module commands
define run_dir_begin = &&l_path/lib/command/run_dir_begin.sql
define run_dir       = &&l_path/lib/command/run_dir.sql
define run_dir_end   = &&l_path/lib/command/run_dir_end.sql
define run_script    = &&l_path/lib/command/run_script.sql

--define globals defined by module
define g_run_path   = "."
define g_run_action = "run"
define g_run_script = "run.sql"

--require stack module
@&&sqlsn_require sqlsn-stack

--create stack path and push . on stack
@&&stack_create path
@&&stack_push   path  "&&g_run_path"

undef l_path

