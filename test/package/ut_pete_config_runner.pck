CREATE OR REPLACE PACKAGE ut_pete_config_runner AS

    description pete_core.typ_description := 'pete_configuration_runner package tests';

    -- run_configruation - test case
    PROCEDURE run_test_case(d VARCHAR2 := 'simple test case should succeed');

    PROCEDURE input_parameter_succeeds(d VARCHAR2 := 'Test case succeed with defined input parameters');

    PROCEDURE expected_out_param_succeeds(d VARCHAR2 := 'PLSQL block in test case should succeed when returns expected output');

    PROCEDURE unexpected_out_param_fails(d VARCHAR2 := 'PLSQL block in test case should fail when returns unexpected output');

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
    g_input_param_id              pete_input_param.id%TYPE;
    g_output_param_id             pete_output_param.id%TYPE;

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
        INSERT INTO pete_input_param
            (id, NAME, VALUE)
        VALUES
            (petes_input_param.nextval, 'test', a_xml_in)
        RETURNING id INTO g_input_param_id;
        --
        UPDATE pete_plsql_block_in_case bc
           SET bc.input_param_id = g_input_param_id
         WHERE bc.test_case_id = g_test_case_id
           AND bc.plsql_block_id = g_block_id;
        --
        COMMIT;
    END;

    PROCEDURE helper_insert_output(a_xml_in IN xmltype) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        --
        INSERT INTO pete_output_param
            (id, NAME, VALUE)
        VALUES
            (petes_output_param.nextval, 'test', a_xml_in)
        RETURNING id INTO g_output_param_id;
        --
        UPDATE pete_plsql_block_in_case bc
           SET bc.output_param_id = g_output_param_id
         WHERE bc.test_case_id = g_test_case_id
           AND bc.plsql_block_id = g_block_id;
        --
        COMMIT;
    END;

    PROCEDURE helper_delete_input IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE pete_plsql_block_in_case bc
           SET bc.input_param_id = NULL
         WHERE bc.test_case_id = g_test_case_id
           AND bc.plsql_block_id = g_block_id;
        --
        DELETE FROM pete_input_param WHERE id = g_input_param_id;
        --
        COMMIT;
        --
    END;

    PROCEDURE helper_delete_output IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE pete_plsql_block_in_case bc
           SET bc.output_param_id = NULL
         WHERE bc.test_case_id = g_test_case_id
           AND bc.plsql_block_id = g_block_id;
        --
        DELETE FROM pete_input_param WHERE id = g_output_param_id;
        --
        COMMIT;
        --
    END;

    PROCEDURE run_test_case(d VARCHAR2) IS
    BEGIN
        --log
        pete_logger.log_method_description(d);
        pete.run_test_case(a_case_name_in => 'test');
        --
    END;

    PROCEDURE input_parameter_succeeds(d VARCHAR2) IS
        l_xml xmltype := xmltype.createxml('<message>Hello world!</message>');
    BEGIN
        --log
        pete_logger.log_method_description(d);
        --test
        helper_insert_input(a_xml_in => l_xml);
        --
        pete.run_test_case(a_case_name_in => 'test');
        --
        helper_delete_input;
        --
    END;

    PROCEDURE expected_out_param_succeeds(d VARCHAR2) IS
        l_xml xmltype := xmltype.createxml('<message>Hello world!</message>');
    BEGIN
        --log
        pete_logger.log_method_description(d);
        --test
        helper_insert_input(a_xml_in => l_xml);
        helper_insert_output(a_xml_in => l_xml);
        --
        pete.run_test_case(a_case_name_in => 'test');
        --
        helper_delete_input;
        helper_delete_output;
        --
    END;

    PROCEDURE unexpected_out_param_fails(d VARCHAR2) IS
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
                          pete_configuration_runner.run_case(a_case_name_in => 'test'));
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
        COMMIT;
    END;

END ut_pete_config_runner;
/
