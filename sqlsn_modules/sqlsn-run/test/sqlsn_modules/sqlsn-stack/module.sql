--module name and path
define l_path = "&1"

--save stack module path to module_config
spool "&&l_path./lib/command/module_config.sql"
set termout off
prompt define stack_module_path = "&&l_path"
set termout on
spool off

--module commands
define stack_create = "&&l_path./lib/command/create.sql"
define stack_push   = "&&l_path./lib/command/push.sql"
define stack_pop    = "&&l_path./lib/command/pop.sql"

undef l_path
