--begin 
prompt Loading module [foo] at path "&1"
define l_module_path = "&1"

--define commands
define foo_bar = '&&l_module_path/lib/bar.sql'
prompt .. Command foo_bar defined

--done
prompt .. done
undefine l_module_path