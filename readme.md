![alt text](assets/logo/Pete.png "Pete")

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Intro](#intro)
- [Quick User Guide](#quick-user-guide)
  - [Installation](#installation)
  - [Tutorial](#tutorial)
    - [1. Create test package with description](#1-create-test-package-with-description)
    - [2. Declare hooks - before and after each or all methods](#2-declare-hooks---before-and-after-each-or-all-methods)
    - [3. Declare testing methods](#3-declare-testing-methods)
    - [4. Implement hooks and testing methods](#4-implement-hooks-and-testing-methods)
    - [5. Run test package](#5-run-test-package)
  - [Configuration](#configuration)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Intro

Pete is simple, yet powerful PL/SQL testing suite. Pete implements **Convention over Configuration** approach to test organization allowing

* quick learning curve
* almost human language for describing tests
* selfcontained tests
     
# Quick User Guide

## Installation 

**1. Grant required privileges schema**

```sql
@grant <schema name> production
```

> Optionally create dedicated schema for Pete using supplied [create.sql](create.sql) script
>
> * first connect to database using privileged user (for granted privileges see `[module/dba/grant_schema_production.sql](module/dba/grant_schema_production.sql)`)
> * then run `@create manual production` script

**2. Connect to target schema and install Pete objects**

- **in public mode** - Pete can be used by other schemas - execute on API is granted to PUBLIC

```sql
SQL> @install public production
```

- **in peer mode** - Pete may only be used by `current_schema`

```sql
SQL> @install peer production
```

## Tutorial

You don't need to configure anything, just write your testing packages using simple convention and Pete will run your tests automagically.

Follow up this simple tutorial which will guide you through.

1. Create test package specification and describe your test
2. Declare hooks
3. Declare testing methods
3. Implement hooks and testing methods
4. Optionaly grant Pete privilege to execute your test package
5. Run test package

### 1. Create test package with description

* package name has to have prefix `UT_` (this is configurable using `pete_config.set_test_package_prefix` method)
* package description has to be defined in `description` variable in package specification
* variable have to be either `pete_types.typ_description` or some `varchar2` with less than `4000 bytes`

```sql
CREATE OR REPLACE PACKAGE ut_test AS

    description VARCHAR2(255) := 'Test my amazing constraint';

END;
/
```

### 2. Declare hooks - before and after each or all methods

* `before_all` - executed once before all other methods
* `before_each` - executed before each method - except hooks
* `after_each` - execute after each method - except hooks
* `after_all` - execute once after all other methods

All hook methods are optional. You choose whether to implement them or not.

```sql
CREATE OR REPLACE PACKAGE ut_test AS

    description VARCHAR2(255) := 'Test my amazing constraint';

    -- hook method
    PROCEDURE before_all;

    -- hook method
    PROCEDURE after_all;

END;
/
```

### 3. Declare testing methods

* a testing method has to be a procedure with zero mandatory arguments
* there is no restriction on name of the method except hook method names - `before_all`, `before_each`, `after_each`, `after_all` which are reserved
* methods are executed in order, in which they are defined in package specification
    * just reorder methods in package specification to change execution order    
* it is best practice to describe what method does (or Pete makes up something generic like *"Executing method ut_test.method_1"*)
    * it is even better to describe it using `default` value of some input argument (as you can use it in implementation, as you will see later)
    * describe test only in package specification = do not repeat the default value in package body

```sql
CREATE OR REPLACE PACKAGE ut_test AS

    description VARCHAR2(255) := 'Test my amazing constraint';

    -- hook method
    PROCEDURE before_all;

    PROCEDURE ins_child_without_parent_fails(d VARCHAR2 := 'Insert child without existing parent fails');

    PROCEDURE ins_child_with_parent_succeeds(d VARCHAR2 := 'Insert child with existing parent succeeds');

    -- hook method
    PROCEDURE after_all;

END;

/
```

### 4. Implement hooks and testing methods

* in package body implement `before_all` hook method

```sql
CREATE OR REPLACE PACKAGE BODY ut_test AS

    PROCEDURE before_all IS
    BEGIN
        EXECUTE IMMEDIATE 'create table x_parent (id integer primary key)';
        EXECUTE IMMEDIATE 'create table x_child (id integer primary key, parent_id integer references x_parent(id))';
    END;

```

* implement first test method
    * call `pete.set_method_description(d)` to set method description
    * implement test, that inserts into child table without existence of a referenced parent - it should fail
    
```sql
    PROCEDURE ins_child_without_parent_fails(d VARCHAR2) IS
        l_thrown BOOLEAN := FALSE;
    BEGIN
        --log
        pete.set_method_description(d);
        --test
        BEGIN
            EXECUTE IMMEDIATE 'insert into x_child values (1,1)';
            l_thrown := FALSE;
        EXCEPTION
            WHEN OTHERS THEN
                l_thrown := TRUE;
        END;
        --assert
        IF NOT l_thrown
        THEN
            raise_application_error(-20000,
                                    q'{It should throw and it doesn't, so fix it!}'); --TODO: add description
        END IF;
    END ins_child_without_parent_fails;
```

* implement second test method
    * again, set method description
    * insert parent and then child record

```sql
    PROCEDURE ins_child_with_parent_succeeds(d VARCHAR2) IS
    BEGIN
        --log
        pete.set_method_description(d);
        --assert
        EXECUTE IMMEDIATE 'insert into x_parent values (1)';
        EXECUTE IMMEDIATE 'insert into x_child values (1,1)';
    END;
```

* implement `after_all` hook method to cleanup after tests

```sql
    PROCEDURE after_all IS
    BEGIN
        EXECUTE IMMEDIATE 'drop table x_child';
        EXECUTE IMMEDIATE 'drop table x_parent';
    END;

END;
/
```

### 5. Run test package

Running tests in Pete is supereasy.

#### SQL*Plus

```sql
SQL> set serveroutput on size unlimited
SQL> set linesize 255
SQL> set pagesize 0
SQL> 
SQL> exec pete.run(a_package_name_in => 'UT_TEST');

.Pete run @ 21-APR-15 02.42.52.753627000 PM +02:00 - SUCCESS
.  Test my amazing constraint - SUCCESS
.    BEFORE_ALL - SUCCESS
.    Insert child without existing parent fails - SUCCESS
.    Insert child with existing parent succeeds - SUCCESS
.    AFTER_ALL - SUCCESS

PL/SQL procedure successfully completed.

```

## Configuration

You can change default Pete behaviour using `pete_config` package

- `set_show_asserts` - change level of information of `pete_assert` call results in log displayed - all, failed or none (all assert results are stored, but using config you can change what you see by default)
- `set_show_hook_methods` - changes whether result of hook method calls is displayed in log
- `set_show_failures_only` - enables/disables display of success calls
- `set_skip_if_before_hook_fails` - enable/disable skip of method call if before hook fails
- `set_test_package_prefix` - change test package prefix - for some reason you may not want default `UT_` prefix
- `set_date_format` - set date format used by Pete in reports

