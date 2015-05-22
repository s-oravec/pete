CREATE OR REPLACE PACKAGE ut_pete_convention_runner AS

    description pete_core.typ_description := 'Pete Convention Runner';

    PROCEDURE before_each;

    PROCEDURE log_call(a_value_in IN VARCHAR2);

    PROCEDURE run_proc_without_args(d IN VARCHAR2 DEFAULT 'should run procedure without any arguments');

    PROCEDURE run_proc_with_optional_args(d IN VARCHAR2 DEFAULT 'should run procedure with optional arguments');

    PROCEDURE not_run_proc_w_mndtry_args(d IN VARCHAR2 DEFAULT 'should not run procedure with mandatory arguments');

    PROCEDURE not_run_function(d IN VARCHAR2 DEFAULT 'should not run function');

--PROCEDURE run_suite_pkg_oo_infix(d IN VARCHAR2 DEFAULT 'Only package with UT_OO% prefix should be run');

END ut_pete_convention_runner;
/
CREATE OR REPLACE PACKAGE BODY ut_pete_convention_runner AS

    g_call_log    VARCHAR2(30);
    gc_CALLED     VARCHAR2(30) := 'CALLED';
    gc_NOT_CALLED VARCHAR2(30) := 'NOT CALLED';

    --------------------------------------------------------------------------------  
    PROCEDURE before_each IS
    BEGIN
        g_call_log := gc_NOT_CALLED;
    END;

    --------------------------------------------------------------------------------  
    PROCEDURE log_call(a_value_in IN VARCHAR2) IS
    BEGIN
        g_call_log := a_value_in;
    END;

    --------------------------------------------------------------------------------
    PROCEDURE run_proc_without_args(d IN VARCHAR2 DEFAULT 'should run procedure without any arguments') IS
        -- NoFormat Start
        l_package_spec VARCHAR2(32767) --
        := 'CREATE OR REPLACE PACKAGE ut_pete_test_cnv_runner AS' || chr(10) || --
           '' || chr(10) || --
           '    PROCEDURE this_should_be_called;' || chr(10) ||
           '' || chr(10) || --
           'END ut_pete_test_cnv_runner;';
        
        l_package_body VARCHAR2(32767) --
        := 'CREATE OR REPLACE PACKAGE BODY ut_pete_test_cnv_runner AS' || chr(10) || --
           '' || chr(10) || --
           '    PROCEDURE this_should_be_called IS' || chr(10) || --
           '    BEGIN' || chr(10) || --
           '        pete_logger.log_method_description(''This method should be called'');' || chr(10) || --
           '        ut_pete_convention_runner.log_call(''CALLED'');' || chr(10) || -- 
           '    END;' || chr(10) || --
           '' || chr(10) || --
           'END ut_pete_test_cnv_runner;'; --
        -- NoFormat End
        l_result pete_core.typ_is_success;
    BEGIN
        --log
        pete_logger.log_method_description(d);
        --prepare
        EXECUTE IMMEDIATE l_package_spec;
        EXECUTE IMMEDIATE l_package_body;
        --test & assert
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
        l_package_spec VARCHAR2(32767) --
        := 'CREATE OR REPLACE PACKAGE ut_pete_test_cnv_runner AS' || chr(10) || --
           '' || chr(10) || --
           '    PROCEDURE this_should_be_called(a in integer default 0, b in integer default 1);' || chr(10) ||
           '' || chr(10) || --
           'END ut_pete_test_cnv_runner;';
        
        l_package_body VARCHAR2(32767) --
        := 'CREATE OR REPLACE PACKAGE BODY ut_pete_test_cnv_runner AS' || chr(10) || --
           '' || chr(10) || --
           '    PROCEDURE this_should_be_called(a in integer default 0, b in integer default 1) IS' || chr(10) || --
           '    BEGIN' || chr(10) || --
           '        pete_logger.log_method_description(''This method should be called'');' || chr(10) || --
           '        ut_pete_convention_runner.log_call(''CALLED'');' || chr(10) || -- 
           '    END;' || chr(10) || --
           '' || chr(10) || --
           'END ut_pete_test_cnv_runner;'; --
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
        l_package_spec VARCHAR2(32767) --
        := 'CREATE OR REPLACE PACKAGE ut_pete_test_cnv_runner AS' || chr(10) || --
           '' || chr(10) || --
           '    PROCEDURE this_should_not_be_called(a in integer);' || chr(10) ||
           '' || chr(10) || --
           'END ut_pete_test_cnv_runner;';
        
        l_package_body VARCHAR2(32767) --
        := 'CREATE OR REPLACE PACKAGE BODY ut_pete_test_cnv_runner AS' || chr(10) || --
           '' || chr(10) || --
           '    PROCEDURE this_should_not_be_called(a in integer) IS' || chr(10) || --
           '    BEGIN' || chr(10) || --
           '        pete_logger.log_method_description(''This method should not be called'');' || chr(10) || --
           '    END;' || chr(10) || --
           '' || chr(10) || --
           'END ut_pete_test_cnv_runner;'; --
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
            l_package_spec VARCHAR2(32767) --
            := 'CREATE OR REPLACE PACKAGE ut_pete_test_cnv_runner AS' || chr(10) || --
               '' || chr(10) || --
               '    FUNCTION this_should_not_be_called return integer;' || chr(10) ||
               '' || chr(10) || --
               'END ut_pete_test_cnv_runner;';
            
            l_package_body VARCHAR2(32767) --
            := 'CREATE OR REPLACE PACKAGE BODY ut_pete_test_cnv_runner AS' || chr(10) || --
               '' || chr(10) || --
               '    FUNCTION this_should_not_be_called return integer IS' || chr(10) || --
               '    BEGIN' || chr(10) || --
               '        pete_logger.log_method_description(''This method should not be called'');' || chr(10) || --
               '        pete_assert.fail;' || chr(10) || --
               '    END;' || chr(10) || --
               '' || chr(10) || --
               'END ut_pete_test_cnv_runner;'; --
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

/*PROCEDURE run_suite_pkg_oo_infix(d IN VARCHAR2) IS
        -- NoFormat Start
        l_package_spec VARCHAR2(32767) --
        := 'CREATE OR REPLACE PACKAGE ut_pete_test_cnv_runner AS' || chr(10) || --
           '' || chr(10) || --
           '    PROCEDURE this_should_be_called(d IN VARCHAR2 DEFAULT ''This method should be called'');' || chr(10) ||
           '' || chr(10) || --
           'END ut_pete_test_cnv_runner;';
        
        l_package_body VARCHAR2(32767) --
        := 'CREATE OR REPLACE PACKAGE BODY ut_pete_test_cnv_runner AS' || chr(10) || --
           '' || chr(10) || --
           '    PROCEDURE run_suite_pkg_oo_infix(d IN VARCHAR2) IS' || chr(10) || --
           '    BEGIN' || chr(10) || --
           '        pete_logger.log_method_description(d);' || chr(10) || --
           '    END;' || chr(10) || --
           '' || chr(10) || --
           'END ut_pete_test_cnv_runner;'; --
        -- NoFormat End
    BEGIN
        --log
        pete_logger.log_method_description(d);
        --test
        pete_assert.fail;
        --create package
    END;*/

END ut_pete_convention_runner;
/
