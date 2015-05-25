CREATE OR REPLACE PACKAGE ut_pete_config AS

    description pete_core.typ_description := 'Pete config';

    PROCEDURE show_failures_only_works(d IN VARCHAR2 := 'Show only failures when show_failures_only is set to true');

    PROCEDURE after_each;

END ut_pete_config;
/
CREATE OR REPLACE PACKAGE BODY ut_pete_config AS

    --------------------------------------------------------------------------------
    PROCEDURE after_each IS
    BEGIN
        EXECUTE IMMEDIATE 'drop package ut_pete_test_cnv_runner';
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END;

    --------------------------------------------------------------------------------
    PROCEDURE show_failures_only_works(d IN VARCHAR2) IS
        -- NoFormat Start
        l_package_spec        VARCHAR2(32767) :=
        'CREATE OR REPLACE PACKAGE ut_pete_test_cnv_runner AS' || chr(10) ||
        '    PROCEDURE this_should_succeed;' || chr(10) ||
        '    PROCEDURE this_should_fail;' || chr(10) ||
        'END;';
        
        l_package_body VARCHAR2(32767) :=
        'CREATE OR REPLACE PACKAGE BODY ut_pete_test_cnv_runner AS' || chr(10) ||
        '    PROCEDURE this_should_succeed IS' || chr(10) ||
        '    BEGIN' || chr(10) ||
        '        pete_logger.log_method_description(''This method succeedes'');' || chr(10) ||
        '        pete_assert.pass;' || chr(10) ||
        '    END;' || chr(10) ||
        '' || chr(10) ||
        '    PROCEDURE this_should_fail IS' || chr(10) ||
        '    BEGIN' || chr(10) ||
        '        pete_logger.log_method_description(''This method fails'');' || chr(10) ||
        '        pete_assert.fail(''It expected to fail'');' || chr(10) ||
        '    END;' || chr(10) ||
        'END;'; --
        -- NoFormat End
        l_result     pete_core.typ_is_success;
        l_run_log_id pete_run_log.id%TYPE;
        l_cnt        INTEGER;
        --
    BEGIN
        --log
        pete_logger.log_method_description(d);
        --prepare
        EXECUTE IMMEDIATE l_package_spec;
        EXECUTE IMMEDIATE l_package_body;
        --set
        pete_config.set_show_failures_only(a_value_in => TRUE);
        --test
        pete_assert.this(a_value_in   => pete_config.get_show_failures_only,
                         a_comment_in => 'Show failures only has to be set to TRUE');
        --
        l_run_log_id := pete_core.get_last_run_log_id;
        l_result     := pete_convention_runner.run_package(a_package_name_in      => 'UT_PETE_TEST_CNV_RUNNER',
                                                           a_parent_run_log_id_in => l_run_log_id);
        --
        SELECT COUNT(*)
          INTO l_cnt
          FROM TABLE(pete_logger.display_log(a_run_log_id_in => l_run_log_id))
         WHERE log LIKE '%SUCCESS%';
        --assert
        pete_assert.eq(a_expected_in => 0,
                       a_actual_in   => l_cnt,
                       a_comment_in  => 'Count of showed SUCCESSes should be 0');
        --
        --unset
        pete_config.set_show_failures_only;
        --
        pete_assert.this(a_value_in   => NOT pete_config.get_show_failures_only,
                         a_comment_in => 'Show failures only has to be set to FALSE');
    
    EXCEPTION
        WHEN OTHERS THEN
            pete_config.set_show_failures_only;
            raise_application_error(-20000,
                                    'Unexpected error:' ||
                                    dbms_utility.format_error_stack || chr(10) ||
                                    dbms_utility.format_error_backtrace,
                                    TRUE);
    END;

END ut_pete_config;
/
