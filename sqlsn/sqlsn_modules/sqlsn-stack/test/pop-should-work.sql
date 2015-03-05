--case
prompt
prompt * case [stack pop]
prompt --* stack_pop stack1 variable1 
prompt ----* should pop head of the stack [stack1] into variable [variable1]

--call
@&&stack_pop stack1 variable1

--assertions
prompt - variable1 value [&&variable1] should be [value2].
prompt - level [&&m_stack_stack1_level] should be [xx].
prompt - previous level [&&m_stack_stack1_prev_level] should be [x].


prompt --* stack_pop stack1 variable1
prompt ----* should pop head of the stack [stack1] into variable [variable1]

--call
@&&stack_pop stack1 variable1

--assertions
prompt - variable1 value [&&variable1] should be [value1].
prompt - level [&&m_stack_stack1_level] should be [x].
prompt - previous level [&&m_stack_stack1_prev_level] should be [].