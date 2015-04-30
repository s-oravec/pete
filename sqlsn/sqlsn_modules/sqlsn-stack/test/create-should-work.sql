--case
prompt
prompt * case [stack_create]
prompt --* stack_create stack1 should create empty stack

--call
@&&stack_create stack1

--assertions
prompt - stack head [&&g_stack_stack1_head] should be [terminator].
prompt - stack level [&&m_stack_stack1_level] should be [x].
prompt - previous level [&&m_stack_stack1_prev_level] should be [].