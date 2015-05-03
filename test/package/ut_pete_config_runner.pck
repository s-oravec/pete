CREATE OR REPLACE PACKAGE ut_pete_config_runner AS

    description pete_core.typ_description := 'pete_configuration_runner package tests';

    -- run_test_package group    
    PROCEDURE run_test_case(d VARCHAR2 := 'simple test case should work');

    PROCEDURE before_each;

    PROCEDURE after_each;

END ut_pete_config_runner;
/
CREATE OR REPLACE PACKAGE BODY ut_pete_config_runner AS

    hello_world_plblock VARCHAR2(32767) --
    := 'DECLARE' || chr(10) || --
       '    l_xml_in xmltype := :1;' || chr(10) || --
       'BEGIN' || chr(10) || --
       '    :2 := xmltype.createxml(''<message>Hello World!</message>'');' ||
       chr(10) || --
       'END;';

    g_block_id                    pete_plsql_block.id%TYPE;
    g_test_case_id                pete_test_case.id%TYPE;
    g_pete_plsql_block_in_case_id pete_plsql_block_in_case.id%TYPE;

    PROCEDURE before_each IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        --create plsql block
        INSERT INTO pete_plsql_block
            (id, NAME, anonymous_block)
        VALUES
            (petes_plsql_block.nextval, 'test', hello_world_plblock)
        RETURNING id INTO g_block_id;
        --create case
        INSERT INTO pete_test_case
            (id, NAME)
        VALUES
            (petes_test_case.nextval, 'test')
        RETURNING id INTO g_test_case_id;
        /*--create input param
        INSERT INTO pete_input_param
            (id, NAME, VALUE)
        VALUES
            (petes_input_param.nextval,
             'test',
             xmltype.createxml('<message>Ahoj svete!</message>'));*/
        --add block to case
        INSERT INTO pete_plsql_block_in_case
            (id, test_case_id, plsql_block_id)
        VALUES
            (petes_plsql_block_in_case.nextval, g_test_case_id, g_block_id)
        RETURNING id INTO g_pete_plsql_block_in_case_id;
        --
        COMMIT;
    END;

    PROCEDURE run_test_case(d VARCHAR2) IS
    BEGIN
        --log
        pete_logger.log_method_description(d);
        pete.run_test_case(a_case_name_in => 'test');
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
