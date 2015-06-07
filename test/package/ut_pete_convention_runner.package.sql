CREATE OR REPLACE PACKAGE ut_pete_convention_runner AS

    description pete_core.typ_description := 'Pete Convention Runner';

    PROCEDURE before_each;

    PROCEDURE log_call(a_value_in IN VARCHAR2);

    PROCEDURE run_proc_without_args(d IN VARCHAR2 DEFAULT 'should run procedure without any arguments');

    PROCEDURE run_proc_with_optional_args(d IN VARCHAR2 DEFAULT 'should run procedure with optional arguments');

    PROCEDURE not_run_proc_w_mndtry_args(d IN VARCHAR2 DEFAULT 'should not run procedure with mandatory arguments');

    PROCEDURE not_run_function(d IN VARCHAR2 DEFAULT 'should not run function');

    PROCEDURE pkg_only(d IN VARCHAR2 DEFAULT 'Only package with UT_OO% prefix should be run by run_suite');

    PROCEDURE suite_method_only(d IN VARCHAR2 DEFAULT 'Run suite - if there are any methods with OO prefix, run all hooks and these methods only');

    PROCEDURE package_method_only(d IN VARCHAR2 DEFAULT 'Run package - if there are any methods with OO prefix, run all hooks and these methods only');

    PROCEDURE suite_method_skip(d IN VARCHAR2 DEFAULT 'Methods with XX prefix should by skipped when running suite');

    PROCEDURE package_method_skip(d IN VARCHAR2 DEFAULT 'Methods with XX prefix should by skipped when running package');

    PROCEDURE unknown_package(d IN VARCHAR2 DEFAULT 'Explicitly called package which is not found should throw');

    PROCEDURE after_each;

END ut_pete_convention_runner;
/
CREATE OR REPLACE PACKAGE BODY ut_pete_convention_runner AS

    g_is_recursive_call BOOLEAN := FALSE;
    g_call_log          VARCHAR2(30);
    gc_CALLED           VARCHAR2(30) := 'CALLED';
    gc_NOT_CALLED       VARCHAR2(30) := 'NOT CALLED';

    --------------------------------------------------------------------------------  
    PROCEDURE before_each IS
    BEGIN
        g_call_log := gc_NOT_CALLED;
    END;

    --------------------------------------------------------------------------------  
    PROCEDURE after_each IS
    BEGIN
        BEGIN
            EXECUTE IMMEDIATE 'drop package ut_oopete_test_cnv_runner';
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
        BEGIN
            EXECUTE IMMEDIATE 'drop package ut_pete_test_cnv_runner';
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
    END;

    --------------------------------------------------------------------------------  
    PROCEDURE log_call(a_value_in IN VARCHAR2) IS
    BEGIN
        g_call_log := a_value_in;
    END;

    --------------------------------------------------------------------------------
    PROCEDURE run_proc_without_args(d IN VARCHAR2 DEFAULT 'should run procedure without any arguments') IS
        -- NoFormat Start
        l_package_spec VARCHAR2(32767) :=
        'CREATE OR REPLACE PACKAGE ut_pete_test_cnv_runner AS' || chr(10) ||
        '    PROCEDURE this_should_be_called;' || chr(10) ||
        'END;';
        
        l_package_body VARCHAR2(32767) :=
        'CREATE OR REPLACE PACKAGE BODY ut_pete_test_cnv_runner AS' || chr(10) ||
        '    PROCEDURE this_should_be_called IS' || chr(10) ||
        '    BEGIN' || chr(10) ||
        '        pete_logger.log_method_description(''This method should be called'');' || chr(10) ||
        '        ut_pete_convention_runner.log_call(''CALLED'');' || chr(10) ||
        '    END;' || chr(10) ||
        'END;';
        -- NoFormat End
        l_result pete_core.typ_is_success;
    BEGIN
        --log
        pete_logger.log_method_description(d);
        --prepare
        EXECUTE IMMEDIATE l_package_spec;
        EXECUTE IMMEDIATE l_package_body;
        --test and assert
        l_result := pete_convention_runner.run_package(a_package_name_in      => 'UT_PETE_TEST_CNV_RUNNER',
                                                       a_parent_run_log_id_in => pete_core.get_last_run_log_id);
        --assert
        pete_assert.this(a_value_in   => l_result,
                         a_comment_in => 'Expecting result to be SUCCESS');
        pete_assert.eq(a_expected_in => gc_CALLED, a_actual_in => g_call_log);
    END;

    --------------------------------------------------------------------------------
    PROCEDURE run_proc_with_optional_args(d IN VARCHAR2 DEFAULT 'should run procedure with optional arguments') IS
        -- NoFormat Start
        l_package_spec VARCHAR2(32767) :=
        'CREATE OR REPLACE PACKAGE ut_pete_test_cnv_runner AS' || chr(10) ||
        '    PROCEDURE this_should_be_called(a in integer default 0, b in integer default 1);' || chr(10) ||
        'END;';
        
        l_package_body VARCHAR2(32767) :=
        'CREATE OR REPLACE PACKAGE BODY ut_pete_test_cnv_runner AS' || chr(10) ||
        '    PROCEDURE this_should_be_called(a in integer default 0, b in integer default 1) IS' || chr(10) ||
        '    BEGIN' || chr(10) ||
        '        pete_logger.log_method_description(''This method should be called'');' || chr(10) ||
        '        ut_pete_convention_runner.log_call(''CALLED'');' || chr(10) ||
        '    END;' || chr(10) ||
        'END;';
        -- NoFormat End
        l_result pete_core.typ_is_success;
    BEGIN
        --log
        pete_logger.log_method_description(d);
        --prepare
        EXECUTE IMMEDIATE l_package_spec;
        EXECUTE IMMEDIATE l_package_body;
        --test
        l_result := pete_convention_runner.run_package(a_package_name_in      => 'UT_PETE_TEST_CNV_RUNNER',
                                                       a_parent_run_log_id_in => pete_core.get_last_run_log_id);
        --assert
        pete_assert.this(a_value_in   => l_result,
                         a_comment_in => 'Expecting result to be SUCCESS');
        pete_assert.eq(a_expected_in => gc_CALLED, a_actual_in => g_call_log);
    END;

    --------------------------------------------------------------------------------
    PROCEDURE not_run_proc_w_mndtry_args(d IN VARCHAR2 DEFAULT 'should not run procedure with mandatory arguments') IS
        -- NoFormat Start
        l_package_spec VARCHAR2(32767) :=
        'CREATE OR REPLACE PACKAGE ut_pete_test_cnv_runner AS' || chr(10) ||
        '    PROCEDURE this_should_not_be_called(a in integer);' || chr(10) ||
        'END;';
        
        l_package_body VARCHAR2(32767) :=
        'CREATE OR REPLACE PACKAGE BODY ut_pete_test_cnv_runner AS' || chr(10) ||
        '    PROCEDURE this_should_not_be_called(a in integer) IS' || chr(10) ||
        '    BEGIN' || chr(10) ||
        '        pete_logger.log_method_description(''This method should not be called'');' || chr(10) ||
        '    END;' || chr(10) ||
        'END;';
        -- NoFormat End
        l_result pete_core.typ_is_success;
    BEGIN
        --log
        pete_logger.log_method_description(d);
        --prepare
        EXECUTE IMMEDIATE l_package_spec;
        EXECUTE IMMEDIATE l_package_body;
        --test
        l_result := pete_convention_runner.run_package(a_package_name_in      => 'UT_PETE_TEST_CNV_RUNNER',
                                                       a_parent_run_log_id_in => pete_core.get_last_run_log_id);
        --assert
        pete_assert.this(a_value_in   => l_result,
                         a_comment_in => 'Expecting result to be SUCCESS');
    END;

    --------------------------------------------------------------------------------
    PROCEDURE not_run_function(d IN VARCHAR2 DEFAULT 'should not run function') IS
        -- NoFormat Start
        l_package_spec VARCHAR2(32767) :=
        'CREATE OR REPLACE PACKAGE ut_pete_test_cnv_runner AS' || chr(10) ||
        '    FUNCTION this_should_not_be_called return integer;' || chr(10) ||
        'END;';
        
        l_package_body VARCHAR2(32767) :=
        'CREATE OR REPLACE PACKAGE BODY ut_pete_test_cnv_runner AS' || chr(10) ||
        '    FUNCTION this_should_not_be_called return integer IS' || chr(10) ||
        '    BEGIN' || chr(10) ||
        '        pete_logger.log_method_description(''This method should not be called'');' || chr(10) ||
        '        pete_assert.fail;' || chr(10) ||
        '    END;' || chr(10) ||
        'END;'; --
        -- NoFormat End
        l_result pete_core.typ_is_success;
    BEGIN

        --log
        pete_logger.log_method_description(d);
        --prepare
        EXECUTE IMMEDIATE l_package_spec;
        EXECUTE IMMEDIATE l_package_body;
        --test
        l_result := pete_convention_runner.run_package(a_package_name_in      => 'UT_PETE_TEST_CNV_RUNNER',
                                                       a_parent_run_log_id_in => pete_core.get_last_run_log_id);
        --assert
        pete_assert.this(a_value_in   => l_result,
                         a_comment_in => 'Expecting result to be SUCCESS');
    END;

    --------------------------------------------------------------------------------
    PROCEDURE pkg_only(d IN VARCHAR2 DEFAULT 'Only package with UT_OO% prefix should be run by run_suite') IS
        -- NoFormat Start
        l_package_spec1 VARCHAR2(32767) :=
        'CREATE OR REPLACE PACKAGE ut_oopete_test_cnv_runner AS' || chr(10) ||
        '    PROCEDURE this_should_be_called;' || chr(10) ||
        'END;';
        
        l_package_body1 VARCHAR2(32767) :=
        'CREATE OR REPLACE PACKAGE BODY ut_oopete_test_cnv_runner AS' || chr(10) ||
        '    PROCEDURE this_should_be_called IS' || chr(10) ||
        '    BEGIN' || chr(10) ||
        '        pete_logger.log_method_description(''This method should be called'');' || chr(10) ||
        '        ut_pete_convention_runner.log_call(''CALLED'');' || chr(10) ||
        '    END;' || chr(10) ||
        'END;'; --
        
        l_package_spec2 VARCHAR2(32767) :=
        'CREATE OR REPLACE PACKAGE ut_pete_test_cnv_runner AS' || chr(10) ||
        '    PROCEDURE this_should_not_be_called;' || chr(10) ||
        'END;';
        
        l_package_body2 VARCHAR2(32767) :=
        'CREATE OR REPLACE PACKAGE BODY ut_pete_test_cnv_runner AS' || chr(10) ||
        '    PROCEDURE this_should_not_be_called IS' || chr(10) ||
        '    BEGIN' || chr(10) ||
        '        pete_logger.log_method_description(''This method should not be called'');' || chr(10) ||
        '        pete_assert.fail;' || chr(10) ||
        '    END;' || chr(10) ||
        'END;';
        -- NoFormat End
        l_result pete_core.typ_is_success;
    BEGIN
        --log
        pete_logger.log_method_description(d);
        --prepare
        EXECUTE IMMEDIATE l_package_spec1;
        EXECUTE IMMEDIATE l_package_body1;
        EXECUTE IMMEDIATE l_package_spec2;
        EXECUTE IMMEDIATE l_package_body2;
        --test
        IF NOT g_is_recursive_call
        THEN
            g_is_recursive_call := TRUE;
            l_result            := pete_convention_runner.run_suite(a_suite_name_in        => USER,
                                                                    a_parent_run_log_id_in => pete_core.get_last_run_log_id);
        
            --assert
            pete_assert.this(a_value_in   => l_result,
                             a_comment_in => 'Expecting result to be SUCCESS');
            pete_assert.eq(a_expected_in => gc_CALLED,
                           a_actual_in   => g_call_log);
            --
            g_is_recursive_call := FALSE;
        END IF;
        --
    END;

    --------------------------------------------------------------------------------
    PROCEDURE suite_method_only(d IN VARCHAR2) IS
        -- NoFormat Start
        l_package_spec VARCHAR2(32767) :=
        'CREATE OR REPLACE PACKAGE ut_pete_test_cnv_runner AS' || chr(10) ||
        '    PROCEDURE oothis_should_be_called;' || chr(10) ||
        '    PROCEDURE this_should_not_be_called;' || chr(10) || 
        'END;';
        
        l_package_body VARCHAR2(32767) :=
        'CREATE OR REPLACE PACKAGE BODY ut_pete_test_cnv_runner AS' || chr(10) ||
        '    PROCEDURE oothis_should_be_called IS' || chr(10) ||
        '    BEGIN' || chr(10) ||
        '        pete_logger.log_method_description(''This method should be called'');' || chr(10) ||
        '        ut_pete_convention_runner.log_call(''CALLED'');' || chr(10) ||
        '    END;' || chr(10) ||
        '' || chr(10) ||
        '    PROCEDURE this_should_not_be_called IS' || chr(10) ||
        '    BEGIN' || chr(10) ||
        '        pete_logger.log_method_description(''This method should not be called'');' || chr(10) ||
        '        pete_assert.fail;' || chr(10) ||
        '    END;' || chr(10) ||
        'END;'; --
        -- NoFormat End
        l_result pete_core.typ_is_success;
    BEGIN
        --log
        pete_logger.log_method_description(d);
        --prepare
        EXECUTE IMMEDIATE l_package_spec;
        EXECUTE IMMEDIATE l_package_body;
        --test
        IF NOT g_is_recursive_call
        THEN
            g_is_recursive_call := TRUE;
            l_result            := pete_convention_runner.run_suite(a_suite_name_in        => USER,
                                                                    a_parent_run_log_id_in => pete_core.get_last_run_log_id);
            --assert
            pete_assert.this(a_value_in   => l_result,
                             a_comment_in => 'Expecting result to be SUCCESS');
            pete_assert.eq(a_expected_in => gc_CALLED,
                           a_actual_in   => g_call_log);
            --
            g_is_recursive_call := FALSE;
        END IF;
        --
    END;

    --------------------------------------------------------------------------------
    PROCEDURE package_method_only(d IN VARCHAR2) IS
        -- NoFormat Start
        l_package_spec VARCHAR2(32767) :=
        'CREATE OR REPLACE PACKAGE ut_pete_test_cnv_runner AS' || chr(10) ||
        '    PROCEDURE oothis_should_be_called;' || chr(10) ||
        '    PROCEDURE this_should_not_be_called;' || chr(10) || 
        'END;';
        
        l_package_body VARCHAR2(32767) :=
        'CREATE OR REPLACE PACKAGE BODY ut_pete_test_cnv_runner AS' || chr(10) ||
        '    PROCEDURE oothis_should_be_called IS' || chr(10) ||
        '    BEGIN' || chr(10) ||
        '        pete_logger.log_method_description(''This method should be called'');' || chr(10) ||
        '        ut_pete_convention_runner.log_call(''CALLED'');' || chr(10) ||
        '    END;' || chr(10) ||
        '' || chr(10) ||
        '    PROCEDURE this_should_not_be_called IS' || chr(10) ||
        '    BEGIN' || chr(10) ||
        '        pete_logger.log_method_description(''This method should not be called'');' || chr(10) ||
        '        pete_assert.fail;' || chr(10) ||
        '    END;' || chr(10) ||
        'END;'; --
        -- NoFormat End
        l_result pete_core.typ_is_success;
    BEGIN
        --log
        pete_logger.log_method_description(d);
        --prepare
        EXECUTE IMMEDIATE l_package_spec;
        EXECUTE IMMEDIATE l_package_body;
        --test
        IF NOT g_is_recursive_call
        THEN
            g_is_recursive_call := TRUE;
            l_result            := pete_convention_runner.run_package(a_package_name_in      => 'UT_PETE_TEST_CNV_RUNNER',
                                                                      a_parent_run_log_id_in => pete_core.get_last_run_log_id);
            --assert
            pete_assert.this(a_value_in   => l_result,
                             a_comment_in => 'Expecting result to be SUCCESS');
            pete_assert.eq(a_expected_in => gc_CALLED,
                           a_actual_in   => g_call_log);
            --
            g_is_recursive_call := FALSE;
        END IF;
        --
    END;

    --------------------------------------------------------------------------------
    PROCEDURE suite_method_skip(d IN VARCHAR2) IS
        -- NoFormat Start
        l_package_spec VARCHAR2(32767) :=
        'CREATE OR REPLACE PACKAGE ut_oopete_test_cnv_runner AS' || chr(10) ||
        '    PROCEDURE this_should_be_called;' || chr(10) ||
        '    PROCEDURE xxthis_should_not_be_called;' || chr(10) ||
        'END;';
        
        l_package_body VARCHAR2(32767) :=
        'CREATE OR REPLACE PACKAGE BODY ut_oopete_test_cnv_runner AS' || chr(10) ||
        '    PROCEDURE this_should_be_called IS' || chr(10) ||
        '    BEGIN' || chr(10) ||
        '        pete_logger.log_method_description(''This method should be called'');' || chr(10) ||
        '        ut_pete_convention_runner.log_call(''CALLED'');' || chr(10) ||
        '    END;' || chr(10) ||
        '' || chr(10) ||
        '    PROCEDURE xxthis_should_not_be_called IS' || chr(10) ||
        '    BEGIN' || chr(10) ||
        '        pete_logger.log_method_description(''This method should not be called as it is marked as skipped'');' || chr(10) ||
        '        pete_assert.fail;' || chr(10) ||
        '    END;' || chr(10) ||
        'END;'; --
        -- NoFormat End
        l_result pete_core.typ_is_success;
    BEGIN
        --log
        pete_logger.log_method_description(d);
        --prepare
        EXECUTE IMMEDIATE l_package_spec;
        EXECUTE IMMEDIATE l_package_body;
        --test
        IF NOT g_is_recursive_call
        THEN
            g_is_recursive_call := TRUE;
            l_result            := pete_convention_runner.run_suite(a_suite_name_in        => USER,
                                                                    a_parent_run_log_id_in => pete_core.get_last_run_log_id);
            --assert
            pete_assert.this(a_value_in   => l_result,
                             a_comment_in => 'Expecting result to be SUCCESS');
            pete_assert.eq(a_expected_in => gc_CALLED,
                           a_actual_in   => g_call_log);
            --
            g_is_recursive_call := FALSE;
        END IF;
        --
    END;

    --------------------------------------------------------------------------------
    PROCEDURE package_method_skip(d IN VARCHAR2) IS
        -- NoFormat Start
        l_package_spec VARCHAR2(32767) :=
        'CREATE OR REPLACE PACKAGE ut_pete_test_cnv_runner AS' || chr(10) ||
        '    PROCEDURE this_should_be_called;' || chr(10) ||
        '    PROCEDURE xxthis_should_not_be_called;' || chr(10) ||
        'END;';
        
        l_package_body VARCHAR2(32767) :=
        'CREATE OR REPLACE PACKAGE BODY ut_pete_test_cnv_runner AS' || chr(10) ||
        '    PROCEDURE this_should_be_called IS' || chr(10) ||
        '    BEGIN' || chr(10) ||
        '        pete_logger.log_method_description(''This method should be called'');' || chr(10) ||
        '        ut_pete_convention_runner.log_call(''CALLED'');' || chr(10) ||
        '    END;' || chr(10) ||
        '' || chr(10) ||
        '    PROCEDURE xxthis_should_not_be_called IS' || chr(10) ||
        '    BEGIN' || chr(10) ||
        '        pete_logger.log_method_description(''This method should not be called as it is marked as skipped'');' || chr(10) ||
        '        pete_assert.fail;' || chr(10) ||
        '    END;' || chr(10) ||
        'END;'; --
        -- NoFormat End
        l_result pete_core.typ_is_success;
    BEGIN
        --log
        pete_logger.log_method_description(d);
        --prepare
        EXECUTE IMMEDIATE l_package_spec;
        EXECUTE IMMEDIATE l_package_body;
        --test
        IF NOT g_is_recursive_call
        THEN
            g_is_recursive_call := TRUE;
            l_result            := pete_convention_runner.run_package(a_package_name_in      => 'UT_PETE_TEST_CNV_RUNNER',
                                                                      a_parent_run_log_id_in => pete_core.get_last_run_log_id);
            --assert
            pete_assert.this(a_value_in   => l_result,
                             a_comment_in => 'Expecting result to be SUCCESS');
            pete_assert.eq(a_expected_in => gc_CALLED,
                           a_actual_in   => g_call_log);
            --
            g_is_recursive_call := FALSE;
        END IF;
        --
    END;

    PROCEDURE unknown_package(d IN VARCHAR2 DEFAULT 'Explicitly called package which is not found should throw') IS
        l_result pete_core.typ_is_success;
    BEGIN
        pete_logger.log_method_description(d);
        --prepare
    
        --test
        l_result := pete_convention_runner.run_package(a_package_name_in      => 'Non_exIsting_package',
                                                       a_parent_run_log_id_in => pete_core.get_last_run_log_id);
        --assert
        pete_assert.this(a_value_in   => NOT l_result,
                         a_comment_in => 'Expecting result to be FAILURE');
    END unknown_package;

END ut_pete_convention_runner;
/
