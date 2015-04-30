define l_stack = "&1"

define m_stack_&&l_stack._prev_level = ""
define m_stack_&&l_stack._level      = ""
define g_stack_&&l_stack._head       = ""

@&&stack_push &&l_stack "terminator"

undefine l_stack
