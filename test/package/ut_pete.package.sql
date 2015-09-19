CREATE OR REPLACE PACKAGE ut_pete AS

    description pete_core.typ_description := 'Pete package tests';

    PROCEDURE log_call(a_value_in IN VARCHAR2);

    -- run_test_package group
    PROCEDURE run_test_package_empty(d VARCHAR2 := 'call with null package name should throw');

    --dummy method to test
    PROCEDURE dummy_method;

    PROCEDURE run_one_method_only(d VARCHAR2 := 'call of one method should pass OK');

END ut_pete;
/
CREATE OR REPLACE PACKAGE BODY ut_pete AS

    g_call_log    VARCHAR2(30);
    gc_CALLED     VARCHAR2(30) := 'CALLED';
    gc_NOT_CALLED VARCHAR2(30) := 'NOT CALLED';

    --------------------------------------------------------------------------------
    PROCEDURE log_call(a_value_in IN VARCHAR2) IS
    BEGIN
        g_call_log := a_value_in;
    END;

    --------------------------------------------------------------------------------
    PROCEDURE run_test_package_empty(d VARCHAR2) IS
        l_failed BOOLEAN;
    BEGIN
        --log
        pete_logger.log_method_description(d);
        --assert
        BEGIN
            pete.run_test_package(a_package_name_in      => NULL,
                                  a_parent_run_log_id_in => pete_core.get_last_run_log_id);
            l_failed := FALSE;
        EXCEPTION
            WHEN OTHERS THEN
                l_failed := TRUE;
        END;
        --
        pete_assert.this(l_failed);
        --
    END;

    --------------------------------------------------------------------------------
    PROCEDURE dummy_method IS
    BEGIN
        log_call('CALLED');
    END;

    --------------------------------------------------------------------------------
    PROCEDURE run_one_method_only(d VARCHAR2) IS
    BEGIN
        --log
        pete_logger.log_method_description(d);
        --test
        pete.run(a_package_name_in      => 'UT_PETE',
                 a_method_name_in       => 'DUMMY_METHOD',
                 a_parent_run_log_id_in => pete_core.get_last_run_log_id);
        --assert
        pete_assert.eq(a_expected_in => gc_CALLED, a_actual_in => g_call_log);
        --
    END;

END ut_pete;
/
