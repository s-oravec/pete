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

    PROCEDURE skip_all_if_skip_on_hook_fail(d IN VARCHAR2 DEFAULT 'Skip all methods in package if "before all" hook fails and "skip test if before hook fails" option is set');

    PROCEDURE skip_next_if_skip_on_hook_fail(d IN VARCHAR2 DEFAULT 'Skip next method in package if "before each" hook fails and "skip test if before hook fails" option is set');

    PROCEDURE cntna_if_not_skip_on_hook_fail(d IN VARCHAR2 DEFAULT 'Continue with next method if "before each" hook fails and "skip test if before hook fails" option is not set');

    PROCEDURE cntnn_if_not_skip_on_hook_fail(d IN VARCHAR2 DEFAULT 'Continue with next method if "before each" hook fails and "skip test if before hook fails" option is not set');

    PROCEDURE unknown_package(d IN VARCHAR2 DEFAULT 'Explicitly called package which is not found should throw');

    PROCEDURE caseInSensitiVe(d IN VARCHAR2 DEFAULT 'Calls should work case insensitive');

    PROCEDURE unknown_method(d IN VARCHAR2 DEFAULT 'Explicitly called method which is not found should fail');

    PROCEDURE after_all_is_always_called(d in varchar2 := 'After all is always called');

    PROCEDURE after_each;

END ut_pete_convention_runner;
/
CREATE OR REPLACE PACKAGE BODY ut_pete_convention_runner AS

    g_is_recursive_call BOOLEAN := FALSE;
    g_call_log          VARCHAR2(30);
    gc_CALLED           VARCHAR2(30) := 'CALLED';
    gc_NOT_CALLED       VARCHAR2(30) := 'NOT CALLED';

    --
    TYPE typ_call_log_tab IS TABLE OF INTEGER INDEX BY VARCHAR2(30);
    gtab_call_log typ_call_log_tab;

    --------------------------------------------------------------------------------  
    PROCEDURE before_each IS
    BEGIN
        g_call_log := gc_NOT_CALLED;
        gtab_call_log.delete;
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
        pete_Logger.trace('log_call: a_value_in ' || a_value_in);
        g_call_log := a_value_in;
        gtab_call_log(a_value_in) := 1;
    END;

    --------------------------------------------------------------------------------
    FUNCTION has_been_called(a_value_in IN VARCHAR2) RETURN BOOLEAN IS
      l_result boolean;
    BEGIN
        pete_Logger.trace('has_been_called : a_value_in ' || a_value_in);
        l_result := gtab_call_log.exists(a_value_in);
        pete_logger.trace('returns ' || case l_result when true then 'TRUE' when false then 'FALSE' else null end);
        RETURN l_result;
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

    --------------------------------------------------------------------------------
    PROCEDURE skip_all_if_skip_on_hook_fail(d IN VARCHAR2) IS
        -- NoFormat Start
        l_package_spec VARCHAR2(32767) :=
        'CREATE OR REPLACE PACKAGE ut_pete_test_cnv_runner AS' || chr(10) ||
        '    PROCEDURE before_all;' || chr(10) ||
        '    PROCEDURE this_should_not_be_called;' || chr(10) ||
        'END;';
        
        l_package_body VARCHAR2(32767) :=
        'CREATE OR REPLACE PACKAGE BODY ut_pete_test_cnv_runner AS' || chr(10) ||
        '    PROCEDURE before_all IS' || chr(10) ||
        '    BEGIN' || chr(10) ||
        '        raise_application_error(-20000, ''Expected exception'');' || chr(10) ||
        '    END;' || chr(10) ||
        '' || chr(10) ||
        '    PROCEDURE this_should_not_be_called IS' || chr(10) ||
        '    BEGIN' || chr(10) ||
        '        pete_logger.log_method_description(''This method should not be called as before_all has failed'');' || chr(10) ||
        '        ut_pete_convention_runner.log_call(''CALLED'');' || chr(10) ||
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
        --set config
        pete_config.set_skip_if_before_hook_fails(a_value_in => TRUE);
        --run test
        pete_assert.eq(a_expected_in => gc_NOT_CALLED,
                       a_actual_in   => g_call_log);
    
        l_result := pete_convention_runner.run_package(a_package_name_in      => 'UT_PETE_TEST_CNV_RUNNER',
                                                       a_parent_run_log_id_in => pete_core.get_last_run_log_id);
        --assert
        pete_assert.eq(a_expected_in => FALSE,
                       a_actual_in   => l_result,
                       a_comment_in  => 'Expecting result to be FAILURE');
        pete_assert.eq(a_expected_in => gc_NOT_CALLED,
                       a_actual_in   => g_call_log);
    END;

    --------------------------------------------------------------------------------
    PROCEDURE skip_next_if_skip_on_hook_fail(d IN VARCHAR2) IS
        -- NoFormat Start
        l_package_spec VARCHAR2(32767) :=
        'CREATE OR REPLACE PACKAGE ut_pete_test_cnv_runner AS' || chr(10) ||
        '    PROCEDURE before_each;' || chr(10) ||
        '    PROCEDURE this_should_not_be_called;' || chr(10) ||
        '    PROCEDURE this_should_be_called;' || chr(10) ||
        '    PROCEDURE after_each;' || chr(10) ||
        'END;';
        
        l_package_body VARCHAR2(32767) :=
        'CREATE OR REPLACE PACKAGE BODY ut_pete_test_cnv_runner AS' || chr(10) ||
        '    g_do_fail boolean := true;' || chr(10) ||
        '    PROCEDURE before_each IS' || chr(10) ||
        '    BEGIN' || chr(10) ||
        '        IF g_do_fail then ' || chr(10) ||
        '            raise_application_error(-20000, ''Expected exception'');' || chr(10) ||
        '        END IF;' || chr(10) ||
        '    END;' || chr(10) ||
        '' || chr(10) ||
        '    PROCEDURE this_should_not_be_called IS' || chr(10) ||
        '    BEGIN' || chr(10) ||
        '        pete_logger.log_method_description(''This method should not be called as before_each has failed'');' || chr(10) ||
        '        ut_pete_convention_runner.log_call(''CALLED1'');' || chr(10) ||
        '        pete_assert.fail;' || chr(10) ||
        '    END;' || chr(10) ||
        '' || chr(10) ||
        '    PROCEDURE this_should_be_called IS' || chr(10) ||
        '    BEGIN' || chr(10) ||
        '        pete_logger.log_method_description(''This method should be called as before_each has succeeded'');' || chr(10) ||
        '        ut_pete_convention_runner.log_call(''CALLED2'');' || chr(10) ||
        '    END;' || chr(10) ||
        '' || chr(10) ||
        '    PROCEDURE after_each IS' || chr(10) ||
        '    BEGIN' || chr(10) ||
        '        g_do_fail := false;' || chr(10) ||
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
        --set config
        pete_config.set_skip_if_before_hook_fails(a_value_in => TRUE);
        --run test
        l_result := pete_convention_runner.run_package(a_package_name_in      => 'UT_PETE_TEST_CNV_RUNNER',
                                                       a_parent_run_log_id_in => pete_core.get_last_run_log_id);
        --assert
        pete_assert.eq(a_expected_in => FALSE,
                       a_actual_in   => l_result,
                       a_comment_in  => 'Expecting result to be FAILURE');
        pete_assert.this(a_value_in   => NOT has_been_called('CALLED1'),
                         a_comment_in => 'Method should not be called after before_each failed');
        pete_assert.this(a_value_in   => has_been_called('CALLED2'),
                         a_comment_in => 'Method should be called after before_each succeeds');
    END;

    --------------------------------------------------------------------------------
    PROCEDURE cntna_if_not_skip_on_hook_fail(d IN VARCHAR2) IS
        -- NoFormat Start
        l_package_spec VARCHAR2(32767) :=
        'CREATE OR REPLACE PACKAGE ut_pete_test_cnv_runner AS' || chr(10) ||
        '    PROCEDURE before_all;' || chr(10) ||
        '    PROCEDURE this_should_be_called;' || chr(10) ||
        'END;';
        
        l_package_body VARCHAR2(32767) :=
        'CREATE OR REPLACE PACKAGE BODY ut_pete_test_cnv_runner AS' || chr(10) ||
        '    PROCEDURE before_all IS' || chr(10) ||
        '    BEGIN' || chr(10) ||
        '        raise_application_error(-20000, ''Expected exception'');' || chr(10) ||
        '    END;' || chr(10) ||
        '' || chr(10) ||
        '    PROCEDURE this_should_be_called IS' || chr(10) ||
        '    BEGIN' || chr(10) ||
        '        pete_logger.log_method_description(''This method should be called even after before_all has failed because pete_config overrides it'');' || chr(10) ||
        '        ut_pete_convention_runner.log_call(''CALLED'');' || chr(10) ||
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
        --set config
        pete_config.set_skip_if_before_hook_fails(a_value_in => FALSE);
        --run test
        l_result := pete_convention_runner.run_package(a_package_name_in      => 'UT_PETE_TEST_CNV_RUNNER',
                                                       a_parent_run_log_id_in => pete_core.get_last_run_log_id);
        --assert
        pete_assert.eq(a_expected_in => FALSE,
                       a_actual_in   => l_result,
                       a_comment_in  => 'Expecting result to be FAILURE');
        pete_assert.eq(a_expected_in => gc_CALLED, a_actual_in => g_call_log);
    END;

    --------------------------------------------------------------------------------
    PROCEDURE cntnn_if_not_skip_on_hook_fail(d IN VARCHAR2) IS
        -- NoFormat Start
        l_package_spec VARCHAR2(32767) :=
        'CREATE OR REPLACE PACKAGE ut_pete_test_cnv_runner AS' || chr(10) ||
        '    PROCEDURE before_each;' || chr(10) ||
        '    PROCEDURE this_should_be_called1;' || chr(10) ||
        '    PROCEDURE this_should_be_called2;' || chr(10) ||
        '    PROCEDURE after_each;' || chr(10) ||
        'END;';
        
        l_package_body VARCHAR2(32767) :=
        'CREATE OR REPLACE PACKAGE BODY ut_pete_test_cnv_runner AS' || chr(10) ||
        '    g_do_fail boolean := true;' || chr(10) ||
        '    PROCEDURE before_each IS' || chr(10) ||
        '    BEGIN' || chr(10) ||
        '        IF g_do_fail then ' || chr(10) ||
        '            raise_application_error(-20000, ''Expected exception'');' || chr(10) ||
        '        END IF;' || chr(10) ||
        '    END;' || chr(10) ||
        '' || chr(10) ||
        '    PROCEDURE this_should_be_called1 IS' || chr(10) ||
        '    BEGIN' || chr(10) ||
        '        pete_logger.log_method_description(''This method should be called even after before_each has failed because pete_config overrides it'');' || chr(10) ||
        '        ut_pete_convention_runner.log_call(''CALLED1'');' || chr(10) ||
        '    END;' || chr(10) ||
        '' || chr(10) ||
        '    PROCEDURE this_should_be_called2 IS' || chr(10) ||
        '    BEGIN' || chr(10) ||
        '        pete_logger.log_method_description(''This method should be called as before_each has succeeded'');' || chr(10) ||
        '        ut_pete_convention_runner.log_call(''CALLED2'');' || chr(10) ||
        '    END;' || chr(10) ||
        '' || chr(10) ||
        '    PROCEDURE after_each IS' || chr(10) ||
        '    BEGIN' || chr(10) ||
        '        g_do_fail := false;' || chr(10) ||
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
        --set config
        pete_config.set_skip_if_before_hook_fails(a_value_in => FALSE);
        --run test
        l_result := pete_convention_runner.run_package(a_package_name_in      => 'UT_PETE_TEST_CNV_RUNNER',
                                                       a_parent_run_log_id_in => pete_core.get_last_run_log_id);
        --assert
        pete_assert.eq(a_expected_in => FALSE,
                       a_actual_in   => l_result,
                       a_comment_in  => 'Expecting result to be FAILURE');
        pete_assert.this(a_value_in   => has_been_called('CALLED1'),
                         a_comment_in => 'Method should be called event after before_each failed');
        pete_assert.this(a_value_in   => has_been_called('CALLED2'),
                         a_comment_in => 'Method should be called after before_each succeeds');
    END;

    --------------------------------------------------------------------------------
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

    --------------------------------------------------------------------------------
    PROCEDURE caseInSensitiVe(d IN VARCHAR2 DEFAULT 'Calls should work case insensitive') IS
        l_package_spec VARCHAR2(32767) := 'CREATE OR REPLACE PACKAGE ut_pete_test_cnv_runner AS' ||
                                          chr(10) || '    PROCEDURE method;' ||
                                          chr(10) || 'END;';
    
        l_package_body VARCHAR2(32767) := 'CREATE OR REPLACE PACKAGE BODY ut_pete_test_cnv_runner AS' ||
                                          chr(10) || '    PROCEDURE method IS' ||
                                          chr(10) || '    BEGIN' || chr(10) ||
                                          '        pete_logger.log_method_description(''This method should be called even if case is mismatched'');' ||
                                          chr(10) ||
                                          '        ut_pete_convention_runner.log_call(''CALLED1'');' ||
                                          chr(10) || '    END;' || chr(10) ||
                                          'END;'; --
        -- NoFormat End
        l_result pete_core.typ_is_success;
    BEGIN
        --log
        pete_logger.log_method_description(d);
        --prepare
        EXECUTE IMMEDIATE l_package_spec;
        EXECUTE IMMEDIATE l_package_body;
        --run test
        l_result := pete_convention_runner.run_package(a_package_name_in      => 'UT_PETE_TEST_CNV_Runner',
                                                       a_parent_run_log_id_in => pete_core.get_last_run_log_id);
        --assert
        pete_assert.this(a_value_in   => has_been_called('CALLED1') and l_result,
                         a_comment_in => 'Method should be called even if case is mismatched');
    END;

    --------------------------------------------------------------------------------
    PROCEDURE unknown_method(d IN VARCHAR2 DEFAULT 'Explicitly called method which is not found should fail') IS
        l_package_spec VARCHAR2(32767) := 'CREATE OR REPLACE PACKAGE ut_pete_test_cnv_runner AS' ||
                                          chr(10) || '    PROCEDURE method;' ||
                                          chr(10) || 'END;';
    
        l_package_body VARCHAR2(32767) := 'CREATE OR REPLACE PACKAGE BODY ut_pete_test_cnv_runner AS' ||
                                          chr(10) || '    PROCEDURE method IS' ||
                                          chr(10) || '    BEGIN' || chr(10) ||
                                          '        pete_logger.log_method_description(''This method should be called even if case is mismatched'');' ||
                                          chr(10) ||
                                          '        ut_pete_convention_runner.log_call(''CALLED1'');' ||
                                          chr(10) || '    END;' || chr(10) ||
                                          'END;'; --
        -- NoFormat End
        l_result pete_core.typ_is_success;
--        l_exception boolean;
    BEGIN
        --log
        pete_logger.log_method_description(d);
        --prepare
        EXECUTE IMMEDIATE l_package_spec;
        EXECUTE IMMEDIATE l_package_body;
        --run test
            l_result := pete_convention_runner.run_package(a_package_name_in      => 'UT_PETE_TEST_CNV_Runner',
                                                           a_method_name_like_in => 'non_existing_method',
                                                           a_parent_run_log_id_in => pete_core.get_last_run_log_id);
        --assert
        pete_assert.this(a_value_in   => not l_result,
                         a_comment_in => 'Non existing method call should fail');
    END;

    --------------------------------------------------------------------------------
    PROCEDURE after_all_is_always_called(d in varchar2 := 'After all is always called') is
        -- NoFormat Start
        l_package_spec VARCHAR2(32767) :=
        'CREATE OR REPLACE PACKAGE ut_pete_test_cnv_runner AS' || chr(10) ||
        '    PROCEDURE after_all;' || chr(10) ||
        'END;';

        l_package_body VARCHAR2(32767) :=
        'CREATE OR REPLACE PACKAGE BODY ut_pete_test_cnv_runner AS' || chr(10) ||
        '    PROCEDURE after_all IS' || chr(10) ||
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

END ut_pete_convention_runner;
/
