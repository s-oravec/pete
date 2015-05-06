# [Pete](id:Pete)

Pete is simple, yet powerful PL/SQL testing suite. Pete allows you to choose the right approach for your PL/SQL  code testing needs

### [TOC](id:TOC)

* [Pete](#Pete)
* [1 Convention over Configuration](#Convention)
    * [1.1 Installation](#ConventionInstallation) 
    * [1.2 Tutorial](#ConventionTutorial)
        * [1.2.1 Create test package with description](#CT1)
        * [1.2.2 Declare hooks - before and after each | all methods](#CT2)
        * [1.2.3 Declare testing methods](#CT3)
        * [1.2.4 Implement hooks and testing methods](#CT4)
        * [1.2.5 Run test package](#CT5)
 

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

# [1 Convention over Configuration](id:Convention)

You don't need to configure anything, just write your testing packages using simple convention and Pete will run your tests automagically.

## [1.1 Installation](id:ConventionInstallation)

**1. Grant required privileges to target schema**

````
grant connect to <pete_schema>;  
grant create table to <pete_schema>;
grant create procedure to <pete_schema>;
grant create type to <pete_schema>;
grant create sequence to <pete_schema>;
grant create view to <pete_schema>;
````

**2. Connect to target schema and install Pete objects**

````
SQL> @install
````

## [1.2 Convention over Configuration tutorial](id:ConventionTutorial)

Follow up this simple tutorial which will guide you through.

1. Create test package specification and describe your test
2. Declare hooks
3. Declare testing methods
3. Implement hooks and testing methods
5. Run test package

### [1.2.1 Create test package with description](id:CT1)

* package name has to have prefix `UT_`
* package description has to be defined in `description` variable of package
* variable have to be either `pete_core.typ_description` or some `varchar2` with less than `4000 bytes`

````
CREATE OR REPLACE PACKAGE ut_test AS

    description VARCHAR2(255) := 'Test my amazing constraint';

END;
/
````

### [1.2.2 Declare hooks - before and after each | all methods](id:CT2)

* `before_all` - executed once before all other methods
* `before_each` - executed before each method - except hooks
* `after_each` - execute after each method - except hooks
* `after_all` - execute once after all other methods

All hook methods are optional. You choose whether to use them or not.

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

### [1.2.3 Declare testing methods](id:CT3)

* a testing method has to be a procedure with zero mandatory arguments
* there is no restriction on name of the method except hook method names - `before_all`, `before_each`, `after_each`, `after_all` which are reserved
* methods are executed in order, in which they are defined in package specification
    * just reorder methods in package specification to change execution order
* it is best practice to describe what method does (or Pete makes up something generic like *"Executing method ut_test.method_1"*)
    * it is even better to describe it using `default` value of some input argument (as you can use it in implementation, as you will see later)

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

### [1.2.4 Implement hooks and testing methods](id:CT4)

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
    * call `pete_logger.log_method_description(d)` to set method description
    * implement test, that inserts into child table without existence of a referenced parent - it should fail
    
````
    PROCEDURE ins_child_without_parent_fails(d VARCHAR2) IS
        l_thrown BOOLEAN := FALSE;
    BEGIN
        --log
        pete_logger.log_method_description(d);
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
        pete_logger.log_method_description(d);
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

### [1.2.5 Run test package](id:CT5)
Running tests in Pete is supereasy.

#### SQL*Plus

````
SQL> set serveroutput on size unlimited
SQL> set linesize 255
SQL> set pages 0
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

