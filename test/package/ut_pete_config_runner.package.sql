CREATE OR REPLACE PACKAGE ut_pete_config_runner AS

    description pete_core.typ_description := 'pete_configuration_runner package tests';

    -- run_configruation - test case
    PROCEDURE run_test_case(d VARCHAR2 := 'simple test case should succeed');

    PROCEDURE input_argument_succeeds(d VARCHAR2 := 'Test case succeed with defined input arguments');

    PROCEDURE expected_result_succeeds(d VARCHAR2 := 'PLSQL block in test case should succeed when returns expected result');

    PROCEDURE unexpected_result_fails(d VARCHAR2 := 'PLSQL block in test case should fail when returns unexpected result');

    -- hook methods
    PROCEDURE before_each;

    PROCEDURE after_each;

END ut_pete_config_runner;
/
CREATE OR REPLACE PACKAGE BODY ut_pete_config_runner AS

    pass_through_plblock VARCHAR2(32767) --
    := 'DECLARE' || chr(10) || --
       '    l_xml_in xmltype := :1;' || chr(10) || --
       'BEGIN' || chr(10) || --
       '    :2 := l_xml_in;' || chr(10) || --
       'END;';

    g_block_id                    pete_plsql_block.id%TYPE;
    g_test_case_id                pete_test_case.id%TYPE;
    g_pete_plsql_block_in_case_id pete_plsql_block_in_case.id%TYPE;
    g_input_argument_id           pete_input_argument.id%TYPE;
    g_expected_result_id          pete_expected_result.id%TYPE;

    g_result pete_core.typ_is_success;

    PROCEDURE before_each IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        --create plsql block
        INSERT INTO pete_plsql_block
            (id, NAME, anonymous_block)
        VALUES
            (petes_plsql_block.nextval, 'test', pass_through_plblock)
        RETURNING id INTO g_block_id;
        --create case
        INSERT INTO pete_test_case
            (id, NAME)
        VALUES
            (petes_test_case.nextval, 'test')
        RETURNING id INTO g_test_case_id;
        --add block to case
        INSERT INTO pete_plsql_block_in_case
            (id, test_case_id, plsql_block_id)
        VALUES
            (petes_plsql_block_in_case.nextval, g_test_case_id, g_block_id)
        RETURNING id INTO g_pete_plsql_block_in_case_id;
        --
        COMMIT;
    END;

    PROCEDURE helper_insert_input(a_xml_in IN xmltype) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        --
        INSERT INTO pete_input_argument
            (id, NAME, VALUE)
        VALUES
            (petes_input_argument.nextval, 'test', a_xml_in)
        RETURNING id INTO g_input_argument_id;
        --
        UPDATE pete_plsql_block_in_case bc
           SET bc.input_argument_id = g_input_argument_id
         WHERE bc.test_case_id = g_test_case_id
           AND bc.plsql_block_id = g_block_id;
        --
        COMMIT;
    END;

    PROCEDURE helper_insert_output(a_xml_in IN xmltype) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        --
        INSERT INTO pete_expected_result
            (id, NAME, VALUE)
        VALUES
            (petes_expected_result.nextval, 'test', a_xml_in)
        RETURNING id INTO g_expected_result_id;
        --
        UPDATE pete_plsql_block_in_case bc
           SET bc.expected_result_id = g_expected_result_id
         WHERE bc.test_case_id = g_test_case_id
           AND bc.plsql_block_id = g_block_id;
        --
        COMMIT;
    END;

    PROCEDURE helper_delete_input IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE pete_plsql_block_in_case bc
           SET bc.input_argument_id = NULL
         WHERE bc.test_case_id = g_test_case_id
           AND bc.plsql_block_id = g_block_id;
        --
        DELETE FROM pete_input_argument WHERE id = g_input_argument_id;
        --
        COMMIT;
        --
    END;

    PROCEDURE helper_delete_output IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE pete_plsql_block_in_case bc
           SET bc.expected_result_id = NULL
         WHERE bc.test_case_id = g_test_case_id
           AND bc.plsql_block_id = g_block_id;
        --
        DELETE FROM pete_expected_result WHERE id = g_expected_result_id;
        --
        COMMIT;
        --
    END;

    PROCEDURE run_test_case(d VARCHAR2) IS
    BEGIN
        --log
        pete_logger.log_method_description(d);
        g_result := pete_configuration_runner.run_case(a_case_name_in         => 'test',
                                                       a_parent_run_log_id_in => pete_core.get_last_run_log_id);
        --
    END;

    PROCEDURE input_argument_succeeds(d VARCHAR2) IS
        l_xml xmltype := xmltype.createxml('<message>Hello world!</message>');
    BEGIN
        --log
        pete_logger.log_method_description(d);
        --test
        helper_insert_input(a_xml_in => l_xml);
        --
        g_result := pete_configuration_runner.run_case(a_case_name_in         => 'test',
                                                       a_parent_run_log_id_in => pete_core.get_last_run_log_id);
        --
        helper_delete_input;
        --
    END;

    PROCEDURE expected_result_succeeds(d VARCHAR2) IS
        l_xml xmltype := xmltype.createxml('<message>Hello world!</message>');
    BEGIN
        --log
        pete_logger.log_method_description(d);
        --test
        helper_insert_input(a_xml_in => l_xml);
        helper_insert_output(a_xml_in => l_xml);
        --
        g_result := pete_configuration_runner.run_case(a_case_name_in         => 'test',
                                                       a_parent_run_log_id_in => pete_core.get_last_run_log_id);
        --
        helper_delete_input;
        helper_delete_output;
        --
    END;

    PROCEDURE unexpected_result_fails(d VARCHAR2) IS
        l_xml1 xmltype := xmltype.createxml('<message>Hello world!</message>');
        l_xml2 xmltype := xmltype.createxml('<message>Hello mooon!</message>');
    BEGIN
        --log
        pete_logger.log_method_description(d);
        --test
        helper_insert_input(a_xml_in => l_xml1);
        helper_insert_output(a_xml_in => l_xml2);
        --
        pete_assert.this(NOT
                          pete_configuration_runner.run_case(a_case_name_in         => 'test',
                                                             a_parent_run_log_id_in => pete_core.get_last_run_log_id));
        --
        helper_delete_input;
        helper_delete_output;
        --
    END;

    PROCEDURE after_each IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        DELETE FROM pete_plsql_block_in_case
         WHERE id = g_pete_plsql_block_in_case_id;
        DELETE FROM pete_test_case WHERE id = g_test_case_id;
        DELETE FROM pete_plsql_block WHERE id = g_block_id;
        helper_delete_input;
        helper_delete_output;
        COMMIT;
    END;

END ut_pete_config_runner;
/
