--case
prompt
prompt * case [stack push]
prompt --* @&&stack_push stack1 value1
prompt ----* should push value [value1] onto stack [stack1]

--call
@&&stack_push stack1 value1

--assertions
prompt - value on head [&&g_stack_stack1_head] should be [value1].
prompt - level [&&m_stack_stack1_level] should be [xx].
prompt - previous level [&&m_stack_stack1_prev_level] should be [x].

prompt --* @&&stack_push stack1 value2
prompt ----* should push [value2] onto stack [stack1]

--call
@&&stack_push stack1 value2

--assertions
prompt - value on head [&&g_stack_stack1_head] should be [value2].
prompt - level [&&m_stack_stack1_level] should be [xxx].
prompt - previous level [&&m_stack_stack1_prev_level] should be [xx].
