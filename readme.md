![alt text](assets/logo/Pete.png "Pete")

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Pete](#pete)
    - [Convention over Configuration](#convention-over-configuration)
    - [Configuration over Convention](#configuration-over-convention)
- [Installation](#installation)
- [Convention over Configuration](#convention-over-configuration-1)
  - [Convention over Configuration tutorial](#convention-over-configuration-tutorial)
    - [1. Create test package with description](#1-create-test-package-with-description)
    - [2. Declare hooks - before and after each or all methods](#2-declare-hooks---before-and-after-each-or-all-methods)
    - [3. Declare testing methods](#3-declare-testing-methods)
    - [4. Implement hooks and testing methods](#4-implement-hooks-and-testing-methods)
    - [5. Run test package](#5-run-test-package)
      - [SQL*Plus](#sqlplus)
- [Configuration over Convention](#configuration-over-convention-1)
  - [Configuration over Convention tutorial](#configuration-over-convention-tutorial)
    - [1. Create tested function](#1-create-tested-function)
    - [2. Create testing procedure](#2-create-testing-procedure)
    - [2. Configure test](#2-configure-test)
      - [2.1 PL/SQL block definition](#21-plsql-block-definition)
      - [2.2 Test case definition](#22-test-case-definition)
      - [2.3 Input argument](#23-input-argument)
      - [2.4 PL/SQL Block in Test Case](#24-plsql-block-in-test-case)
    - [3. Execute Test Case](#3-execute-test-case)
    - [4. Fix error in function](#4-fix-error-in-function)
    - [5. Execute Test Case again](#5-execute-test-case-again)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Pete

Pete is simple, yet powerful PL/SQL testing suite. Pete allows you to choose the right approach for your PL/SQL  code testing needs

With Pete you can choose from 2 different approaches

### Convention over Configuration

when you want

* quick learning curve
* almost human language for describing tests
* selfcontained tests
     
### Configuration over Convention

when you want

* run test on different data sets - reusable test cases/scripts
* split responsibilities for creation of data and code

# Installation

**1. Download required Oracle DB modules**

````
$ git clone https://github.com/s-oravec/sqlsn.git oradb_modules/sqlsn
````

**2. Grant required privileges to target schema**

````
grant connect to <pete_schema>;  
grant create table to <pete_schema>;
grant create procedure to <pete_schema>;
grant create type to <pete_schema>;
grant create sequence to <pete_schema>;
grant create view to <pete_schema>;
````

> Optionally create dedicated schema for Pete using supplied [create.sql](create.sql) script
>
> * first connect to database using privileged user (for granted privileges see `[application/create_production.sql](application/create_production.sql)`)
> * then run `@create.sql production` script 


**3. Connect to target schema and install Pete objects**

````
SQL> @install
````

# Convention over Configuration

You don't need to configure anything, just write your testing packages using simple convention and Pete will run your tests automagically.

## Convention over Configuration tutorial

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

````
CREATE OR REPLACE PACKAGE ut_test AS

    description VARCHAR2(255) := 'Test my amazing constraint';

END;
/
````

### 2. Declare hooks - before and after each or all methods

* `before_all` - executed once before all other methods
* `before_each` - executed before each method - except hooks
* `after_each` - execute after each method - except hooks
* `after_all` - execute once after all other methods

All hook methods are optional. You choose whether to implement them or not.

````
CREATE OR REPLACE PACKAGE ut_test AS

    description VARCHAR2(255) := 'Test my amazing constraint';

    -- hook method
    PROCEDURE before_all;

    -- hook method
    PROCEDURE after_all;

END;
/
````

### 3. Declare testing methods

* a testing method has to be a procedure with zero mandatory arguments
* there is no restriction on name of the method except hook method names - `before_all`, `before_each`, `after_each`, `after_all` which are reserved
* methods are executed in order, in which they are defined in package specification
    * just reorder methods in package specification to change execution order    
* it is best practice to describe what method does (or Pete makes up something generic like *"Executing method ut_test.method_1"*)
    * it is even better to describe it using `default` value of some input argument (as you can use it in implementation, as you will see later)
    * describe test only in package specification = do not repeat the default value in package body

````
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
````

### 4. Implement hooks and testing methods

* in package body implement `before_all` hook method

````
CREATE OR REPLACE PACKAGE BODY ut_test AS

    PROCEDURE before_all IS
    BEGIN
        EXECUTE IMMEDIATE 'create table x_parent (id integer primary key)';
        EXECUTE IMMEDIATE 'create table x_child (id integer primary key, parent_id integer references x_parent(id))';
    END;

````

* implement first test method
    * call `pete.set_method_description(d)` to set method description
    * implement test, that inserts into child table without existence of a referenced parent - it should fail
    
````
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
````

* implement second test method
    * again, set method description
    * insert parent and then child record

````
    PROCEDURE ins_child_with_parent_succeeds(d VARCHAR2) IS
    BEGIN
        --log
        pete.set_method_description(d);
        --assert
        EXECUTE IMMEDIATE 'insert into x_parent values (1)';
        EXECUTE IMMEDIATE 'insert into x_child values (1,1)';
    END;
````

* implement `after_all` hook method to cleanup after tests

````
    PROCEDURE after_all IS
    BEGIN
        EXECUTE IMMEDIATE 'drop table x_child';
        EXECUTE IMMEDIATE 'drop table x_parent';
    END;

END;
/
````

### 5. Run test package

Running tests in Pete is supereasy.

#### SQL*Plus

````
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

````

# Configuration over Convention

Use Pete's Configuration over Convention mode when you want

* run test on different data sets - reusable test cases/scripts
* split responsibilities for creation of data and code

# Configuration over Convention tutorial

## Prereq

[Install](Installation) Pete in Oracle's sample SCOTT schema.

### 1. Create tested function

Create some function to test and make at least my favourite error and forget to return result from function
  
````
CREATE OR REPLACE FUNCTION get_salary(a_deptno_in IN emp.sal%TYPE)
    RETURN NUMBER AS
    l_result NUMBER;
BEGIN
    SELECT SUM(sal) INTO l_result FROM emp WHERE deptno = a_deptno_in;
END;
/
````

### 2. Create testing procedure

All testing procedures have to be able to be called using arguments `a_xml_in` - input XML and `a_xml_out` - output XML. All other arguments have to be optional.
Testing procedure is just wrapper, that provides required interface to Pete. 
From Pete's point of view, testing procedure succeeds if it finishes without raising an exception.

````
CREATE OR REPLACE PROCEDURE test_get_salary
(
    a_xml_in  IN xmltype,
    a_xml_out OUT xmltype
) IS
    l_result emp.sal%TYPE;
BEGIN
    --yuk!!!
    l_result  := get_salary(a_deptno_in => to_number(a_xml_in.extract('/DEPTNO/text()').getStringVal));
    a_xml_out := xmltype.createxml('<TOTAL_SAL>' || l_result || '</TOTAL_SAL>');
END;

/
````

### 2. Configure test

#### 2.1 PL/SQL block definition

Create PL/SQL block definition in Pete repository.

* id - get it from sequence
* name - provide some nice name
* description - describe test implemented by PLSQL block
* method - in our case we have stored procedure, so only method argument will be specified, no owner, no package

````
INSERT INTO pete_plsql_block
    (id, name, description, method)
VALUES
    (petes_plsql_block.nextval,
     'get_salary',
     'generic get_salary test',
     'TEST_GET_SALARY');
````

----

**The rest of the columns**

* test_script_id - identifier of TEST_SCRIPT entity. Use it when you want to "bind" PL/SQL block to specific test script only
* owner, package, method - specify method to be executed
* anonymous_block - specify anonymous PL/SQL block instead of stored procedure

#### 2.2 Test case definition

Create test case definition in Pete repository.

* id - get it from sequence
* name - test case name - give it a good name
* description - describe test case

````
INSERT INTO pete_test_case
    (id, NAME, description)
VALUES
    (petes_test_case.nextval, 'get_salary', 'get_salary should work as expected');
````

----

**The rest of the columns**

* test_script_id - identifier of TEST_SCRIPT entity. Use it when you want to "bind" test case to specific test script only

#### 2.3 Input argument

Create input argument

* id - surrogate identifier, get it from sequence
* name - name it well, it would help with reusing 
* value - value as XML

````
INSERT INTO pete_input_argument
    (id, name, value)
VALUES
    (petes_input_argument.nextval, 'Accounting Department Identifier', '<DEPTNO>10</DEPTNO>');
````

----

**The rest of the columns**

* test_script_id - identifier of TEST_SCRIPT entity. Use it when you want to "bind" test case to specific test script only

#### 2.4 PL/SQL Block in Test Case

Now glue everything together - map a given PL/SQL block with a given input argument to a predefined test case.

* id - surrogate identifier, get it from sequence
* test_case_id - identifier of our Test Case
* pslql_block_id - identifier of our PL/SQL block
* input_argument_id - identifier of Input argument
* description - describe instance of PL/SQL block
* block_order - sort blocks in test case
    
````
INSERT INTO pete_plsql_block_in_case
    (id,
     test_case_id,
     plsql_block_id,
     input_argument_id,
     block_order,
     description)
VALUES
    (petes_plsql_block_in_case.nextval,
     petes_test_case.currval,
     petes_plsql_block.currval,
     petes_input_argument.currval,
     1,
     'should not fail');
````

**The rest of the columns**

* expected_result_id - identifier of expected result, if there is one

----

and commit;

````
commit;
````

### 3. Execute Test Case

Now execute Test Case

````
begin
  pete.run(a_case_name_in => 'get_salary');
end;
/
````

aaaaand ... it fails

````
.Pete run @ 23-APR-15 02.53.52.755920000 PM +02:00 - FAILURE
.  get_salary should work as expected - FAILURE
.    get_salary - FAILURE

ORA-06503: PL/SQL: Function returned without value
 --------------------------------------------------------------
ORA-06512: at "SCOTT.GET_SALARY", line 11
ORA-06512: at "SCOTT.TEST_GET_SALARY", line 9
ORA-06512: at line 2
ORA-06512: at "SCOTT.PETE_CONFIGURATION_RUNNER", line 86
````

### 4. Fix error in function

Add a missing return from function.

````
CREATE OR REPLACE FUNCTION get_salary(a_deptno_in IN emp.sal%TYPE)
    RETURN NUMBER AS
    l_result NUMBER;
BEGIN
    SELECT SUM(sal) INTO l_result FROM emp WHERE deptno = a_deptno_in;
    return l_result;
END;
/
````

### 5. Execute Test Case again

Execute the Test Case again and now it succeeds!!!

````

.Pete run @ 23-APR-15 03.03.06.171390000 PM +02:00 - SUCCESS
.  get_salary should work as expected - SUCCESS
.    get_salary - SUCCESS


````
