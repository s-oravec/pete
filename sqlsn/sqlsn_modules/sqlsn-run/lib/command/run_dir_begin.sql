define l_path_change = "&1"

--pause logging
@&&log_pause

--define new path
define g_run_path = "&&g_run_path./&&l_path_change"

--push         on stack new path
@&&stack_push  path     "&&g_run_path"

--continue logging
@&&log_continue

--prompt begin of dir
prompt [&&_DATE] path [&&g_run_path]:BEGIN

--undefine locals
undefine l_path_change
