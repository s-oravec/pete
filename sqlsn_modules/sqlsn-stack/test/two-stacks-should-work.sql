--case
prompt
prompt * case [two stacks should work]

prompt --* create stack2 values aaa bbb ccc
@&&stack_create stack2
@&&stack_push stack2 aaa
@&&stack_push stack2 bbb
@&&stack_push stack2 ccc

prompt --* push on stack1 values 1 2 3
@&&stack_push stack1 1
@&&stack_push stack1 2
@&&stack_push stack1 3

prompt --* pop 2 values from stack1
@&&stack_pop stack1 l_tmp
prompt [&&l_tmp] should be [3]
@&&stack_pop stack1 l_tmp
prompt [&&l_tmp] should be [2]

prompt --* pop 2 values from stack2
@&&stack_pop stack2 l_tmp
prompt [&&l_tmp] should be [ccc]
@&&stack_pop stack2 l_tmp
prompt [&&l_tmp] should be [bbb]

prompt --* push on stack1 values 4 5 6 
@&&stack_push stack1 4
@&&stack_push stack1 5
@&&stack_push stack1 6

prompt --* push on stack2 values ddd eee
@&&stack_push stack2 ddd
@&&stack_push stack2 eee

prompt --* pop 4 values
@&&stack_pop stack1 l_tmp
prompt [&&l_tmp] should be [6]
@&&stack_pop stack1 l_tmp
prompt [&&l_tmp] should be [5]
@&&stack_pop stack1 l_tmp
prompt [&&l_tmp] should be [4]
@&&stack_pop stack1 l_tmp
prompt [&&l_tmp] should be [1]

prompt --* pop 3 values from stack2
@&&stack_pop stack2 l_tmp
prompt [&&l_tmp] should be [eee]
@&&stack_pop stack2 l_tmp
prompt [&&l_tmp] should be [ddd]
@&&stack_pop stack2 l_tmp
prompt [&&l_tmp] should be [aaa]

undefine l_tmp