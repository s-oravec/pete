CREATE OR REPLACE PACKAGE ut_test AS

    description VARCHAR2(255) := 'Test my amazing constraint';

    PROCEDURE before_all;

    PROCEDURE ins_child_without_parent_fails(d VARCHAR2 := 'Insert child without existing parent fails');

    PROCEDURE ins_child_with_parent_succeeds(d VARCHAR2 := 'Insert child with existing parent succeeds');

    PROCEDURE after_all;

END;
/
CREATE OR REPLACE PACKAGE BODY ut_test AS

    PROCEDURE before_all IS
    BEGIN
        EXECUTE IMMEDIATE 'create table x_parent (id integer primary key)';
        EXECUTE IMMEDIATE 'create table x_child (id integer primary key, parent_id integer references x_parent(id))';
    END;

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
                                    q'{It should throw and it doesn't, so fix it!}');
        END IF;
    END ins_child_without_parent_fails;

    PROCEDURE ins_child_with_parent_succeeds(d VARCHAR2) IS
    BEGIN
        --log
        pete_logger.log_method_description(d);
        --assert
        EXECUTE IMMEDIATE 'insert into x_parent values (1)';
        EXECUTE IMMEDIATE 'insert into x_child values (1,1)';
    END;

    PROCEDURE after_all IS
    BEGIN
        EXECUTE IMMEDIATE 'drop table x_child';
        EXECUTE IMMEDIATE 'drop table x_parent';
    END;

END;
/
