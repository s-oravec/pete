CREATE OR REPLACE PACKAGE ut_pete AS

    description pete_core.typ_description := 'Pete package tests';

    -- run_test_package group    
    PROCEDURE run_test_package_empty(d VARCHAR2 := 'call with null package name should throw');

END ut_pete;
/
CREATE OR REPLACE PACKAGE BODY ut_pete AS

    PROCEDURE run_test_package_empty(d VARCHAR2) IS
        l_failed BOOLEAN;
    begin
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

END ut_pete;
/
