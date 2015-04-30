--prompt end of dir
prompt [&&_DATE] path [&&g_run_path]: END

--pop        from stack into path
@&&stack_pop path       l_temp
undefine l_temp

define g_run_path = &&g_stack_path_head
