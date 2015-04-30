# SQLSN - stack

Module implements stack. In SQL*Plus. Blah! But we need it, so ...

# Usage

Module name is `sqlsn-stack` so in "applications" written using SQLSN the substitution variables starting with `m_sqlsn_stack` or `g_sqlsn_stack` should not be used.

## Init

Initialize using

````
@&&sqlsn_require sqlsn-stack
````

or

````
@&&sqls_require_from_path "<path>/sqlsn-stack"
````

## Globals

Globals defined by stack module

### g_stack\_`<stack_name>`_head

Variable contains value of the head of the stack `<stack_name>`.

## Module internals

### m_stack\_`<stack_name>`_level

Level of the stack `<stack_name>` as "unary" number ;).

### m_stack\_`<stack_name>`_prev_level

Previous level of the stack `<stack_name>` as "unary" number ;).

## Module command scripts

Command scripts provided by the `stack` module.

### stack_create `<stack_name>`

Creates stack `<stack_name>`

````
--create stack stack1
@&&stack_create stack1
````

### stack_push `<stack_name>` `<value>`

Pushes value `<value>` on stack `<stack_name>`

````
--push literal on stack
@&&stack_push stack1 1
@&&stack_push stack1 "test"

--push value of substitution variable on stack
@&&stack_push stack1 &&variable

--push value of substitution variable on stack, which name is stored in variable
@&&stack_push &&stack_name &&variable
````

### stack_pop `<stack_name>` `<variable>`

Pops value from the head of the stack `<stack_name>` into variable `<variable>`

````
--pop stack into variable
@&&stack_pop stack1 variable

--pop stack into variable which name is stored in substitution variable
@&&stack_pop stack1 &&variable_name

--pop stack, which name is stored in variable, into variable which name is stored in substitution variable
@&&stack_pop &&stack_name &&variable_name
````
---
bump!