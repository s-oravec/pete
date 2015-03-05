--case
prompt
prompt * case [push and pop should work]

prompt --* push on stack1 values 1 2 3
@&&stack_push stack1 1
@&&stack_push stack1 2
@&&stack_push stack1 3

prompt --* pop 2 values
@&&stack_pop stack1 l_tmp
prompt [&&l_tmp] should be [3]
@&&stack_pop stack1 l_tmp
prompt [&&l_tmp] should be [2]

prompt --* push on stack1 values 4 5 6 
@&&stack_push stack1 4
@&&stack_push stack1 5
@&&stack_push stack1 6

prompt --* pop 4 values
@&&stack_pop stack1 l_tmp
prompt [&&l_tmp] should be [6]
@&&stack_pop stack1 l_tmp
prompt [&&l_tmp] should be [5]
@&&stack_pop stack1 l_tmp
prompt [&&l_tmp] should be [4]
@&&stack_pop stack1 l_tmp
prompt [&&l_tmp] should be [1]

undefine l_tmp