CREATE OR REPLACE PACKAGE ut_pete AS

    description pete_core.typ_description := 'Pete package tests';

    -- run_test_package group    
    PROCEDURE run_test_package_empty(d VARCHAR2 := 'call with null package name should throw');

    --dummy method to test
    PROCEDURE empty_method;

    PROCEDURE run_one_method_only(d VARCHAR2 := 'call of one method should pass OK');
END ut_pete;
/
CREATE OR REPLACE PACKAGE BODY ut_pete AS

    PROCEDURE run_test_package_empty(d VARCHAR2) IS
        l_failed BOOLEAN;
    BEGIN
        --log
        pete_logger.log_method_description(d);
        --assert
        BEGIN
            pete.run_test_package(a_package_name_in => NULL);
            l_failed := FALSE;
        EXCEPTION
            WHEN OTHERS THEN
                l_failed := TRUE;
        END;
        --
        pete_assert.this(l_failed);
        --
    END;

    PROCEDURE empty_method IS
    BEGIN
        NULL;
    END;
    PROCEDURE run_one_method_only(d VARCHAR2 := 'call of one method should pass OK') IS
    BEGIN
        --log
        pete_logger.log_method_description(d);
        --assert
        pete.run(a_package_name_in => 'UT_PETE',
                 a_method_name_in  => 'EMPTY_METHOD');
    END;

END ut_pete;
/
