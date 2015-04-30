CREATE OR REPLACE PACKAGE BODY petep_logger AS

    gc_INDENT_ASSERT  CONSTANT INTEGER := 6;
    gc_INDENT_METHOD  CONSTANT INTEGER := 4;
    gc_INDENT_CASE    CONSTANT INTEGER := 4;
    gc_INDENT_BLOCK   CONSTANT INTEGER := 4;
    gc_INDENT_SCRIPT  CONSTANT INTEGER := 2;
    gc_INDENT_PACAKGE CONSTANT INTEGER := 2;
    gc_INDENT_SCHEMA  CONSTANT INTEGER := 0;
    gc_INDENT_SUITE   CONSTANT INTEGER := 0;
    gc_INDENT_DEFAULT CONSTANT INTEGER := 4;

    g_test_result    BOOLEAN;
    g_asserts_passed NUMBER := 0;
    g_asserts_failed NUMBER := 0;

    g_test_start DATE;
    g_run_id     NUMBER;

    g_test_package VARCHAR2(30); --"currently executed" test package
    g_test_method  VARCHAR2(30); --"currently executed" test method

    g_user VARCHAR2(30) := USER; --cache for performance  todo prevzit z runneru

    /**
    * converts boolean to string representation 'SUCCESS' or 'FAILURE'
    */
    FUNCTION bool2res(a_value_in BOOLEAN) RETURN VARCHAR2 IS
        l_result VARCHAR2(10);
    BEGIN
        IF (a_value_in)
        THEN
            l_result := gc_SUCCESS;
        
        ELSE
            l_result := gc_FAILURE;
        END IF;
        RETURN l_result;
    END;

    /*
     Logs info about a run result
    */
    PROCEDURE log_result IS
        l_result VARCHAR2(30);
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        l_result := bool2res(g_test_result);
        --create table pete_test_run_log (id number, result varchar2(10), asserts_passed number, asserts_failed number, test_start date, test_end date);
        INSERT INTO pete_run_log
            (id, RESULT, asserts_passed, asserts_failed, test_start, test_end)
        VALUES
            (g_run_id,
             l_result,
             g_asserts_passed,
             g_asserts_failed,
             g_test_start,
             SYSDATE);
        COMMIT;
    END;

    /**
    * vytiskne celkovy vysledek v zavislosti na globalni stavove promenne
     todo - do petep_report nebo tak neco
    */
    PROCEDURE print_result IS
        l_result VARCHAR2(10);
    BEGIN
        dbms_output.put_line('==============================');
        l_result := bool2res(g_test_result);
    
        dbms_output.put_line(l_result);
        dbms_output.put_line(g_asserts_passed || ' asserts passed and ' ||
                             g_asserts_failed || ' asserts failed');
        log_result;
    END;

    --todo ucesat, dokumentovat
    PROCEDURE get_assert_caller_info
    (
        a_package_name_out OUT VARCHAR2,
        a_line_number_out  OUT NUMBER
    ) IS
        l_stack VARCHAR2(1000);
        l_part  VARCHAR2(30);
        l_od    NUMBER;
        l_od2   NUMBER;
        l_do    NUMBER;
        ASSERT_PACKAGE CONSTANT VARCHAR2(30) := 'PETEP_ASSERT';
    BEGIN
        --        dbms_output.put_line(dbms_utility.format_call_stack);
        l_stack := dbms_utility.format_call_stack;
    
        a_package_name_out := ASSERT_PACKAGE;
        l_od               := 0;
        WHILE (a_package_name_out = ASSERT_PACKAGE)
        LOOP
            l_od               := instr(l_stack,
                                        'package body ' || g_user || '.' ||
                                        ASSERT_PACKAGE,
                                        l_od + 1);
            l_od2              := regexp_instr(l_stack,
                                               'package body ' || g_user || '.' --||a_package_name_in
                                              ,
                                               position => l_od + 5);
            l_do               := regexp_Instr(l_stack,
                                               'package body ' || g_user ||
                                               '.[a-zA-Z0-9_]*',
                                               l_od2,
                                               1,
                                               1);
            l_od2              := l_od2 +
                                  length('package body ' || g_user || '.');
            a_package_name_out := substr(l_stack, l_od2, l_do - l_od2);
        END LOOP;
        /* bug
        l_part := substr(l_stack,
                         regexp_instr(l_stack,
                                      '[0-9]+ *package body ' || g_user || '.' --||a_package_name_in
                                     ,
                                      position => l_od),
                         4);
        */
        --TODO: fix this
        l_part := regexp_substr(substr(l_stack,
                                       regexp_instr(l_stack,
                                                    '[0-9]+ *package body ' ||
                                                    g_user || '.' --||a_package_name_in
                                                   ,
                                                    position => l_od),
                                       4),
                                '[0-9]+');
        --todo zjistovat package? ze ktere je volan assert
    
        a_line_number_out := to_number(TRIM(l_part));
    END get_assert_caller_info;

    /**
    * formats output of one assert
    */
    FUNCTION format_output
    (
        a_result_in      VARCHAR2,
        a_comment_in     IN VARCHAR2,
        a_package_in     IN VARCHAR2,
        a_method_in      IN VARCHAR2,
        a_line_number_in IN NUMBER
    ) RETURN VARCHAR2 IS
        l_result VARCHAR2(400);
    BEGIN
        l_result := rpad('.', gc_indent_assert, ' ') || a_result_in || ' - ' ||
                    a_comment_in || ' (' || a_package_in || ':' ||
                    a_line_number_in || ', proc-' || a_method_in || ');';
        RETURN l_result;
    END;

    /**
    * logs detailed info about an assert and its result
    */
    PROCEDURE log_detail
    (
        a_result_in      VARCHAR2,
        a_comment_in     VARCHAR2,
        a_line_number_in NUMBER
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO pete_run_log_details
            (id,
             run_id,
             RESULT,
             assert_comment,
             test_package,
             test_procedure,
             line_number,
             run_at)
        VALUES
            (petes_run_log_details.nextval,
             g_run_id,
             a_result_in,
             a_comment_in,
             g_test_package,
             g_test_method,
             a_line_number_in,
             systimestamp);
    
        COMMIT;
    END;

    --
    -- Logs assert package thingies
    --
    -- %param a_result_in assert result
    -- %param a_description_in assert description
    --
    PROCEDURE log_assert
    (
        a_result_in      IN petep_logger.typ_execution_result,
        a_description_in IN petep_logger.typ_description
    ) IS
        l_line_number pete_run_log_details.line_number%TYPE := 3.14;
    BEGIN
        get_assert_caller_info(a_package_name_out => g_test_package,
                               a_line_number_out  => l_line_number);
        --
        IF (a_result_in = gc_SUCCESS)
        THEN
            IF (NOT petep_config.get_show_failures_only)
            THEN
                dbms_output.put_line(format_output(a_result_in,
                                                   a_description_In,
                                                   g_test_package,
                                                   g_test_method,
                                                   l_line_number));
            END IF;
            g_asserts_passed := g_asserts_passed + 1;
        ELSE
            g_test_result    := FALSE;
            g_asserts_failed := g_asserts_failed + 1;
            dbms_output.put_line(format_output(a_result_in,
                                               a_description_In,
                                               g_test_package,
                                               g_test_method,
                                               l_line_number));
        END IF;
        log_detail(a_result_in      => a_result_in,
                   a_comment_in     => a_description_in,
                   a_line_number_in => l_line_number);
    END;

    --------------------------------------------------------------------------------
    FUNCTION get_indent(a_context_in IN petep_logger.typ_log_context)
        RETURN PLS_INTEGER IS
    BEGIN
        --TODO: rewrite
        CASE a_context_in
            WHEN petep_logger.gc_LOG_CONTEXT_ASSERT THEN
                RETURN gc_INDENT_ASSERT;
            WHEN petep_logger.gc_LOG_CONTEXT_BLOCK THEN
                RETURN gc_INDENT_BLOCK;
            WHEN petep_logger.gc_LOG_CONTEXT_CASE THEN
                RETURN gc_INDENT_CASE;
            WHEN petep_logger.gc_LOG_CONTEXT_METHOD THEN
                RETURN gc_INDENT_METHOD;
            WHEN petep_logger.gc_LOG_CONTEXT_PACKAGE THEN
                RETURN gc_INDENT_PACAKGE;
            WHEN petep_logger.gc_LOG_CONTEXT_SCRIPT THEN
                RETURN gc_INDENT_SCRIPT;
            WHEN petep_logger.gc_LOG_CONTEXT_SCHEMA THEN
                RETURN gc_INDENT_SCHEMA;
            WHEN petep_logger.gc_LOG_CONTEXT_SUITE THEN
                RETURN gc_INDENT_SUITE;
            ELSE
                RETURN gc_INDENT_DEFAULT;
        END CASE;
    END get_indent;

    --------------------------------------------------------------------------------     
    PROCEDURE log_method
    (
        a_description_in IN petep_logger.typ_description,
        a_result_in      IN petep_logger.typ_execution_result DEFAULT gc_SUCCESS
    ) IS
    BEGIN
        log_runner(a_description_in => a_description_in,
                   a_context_in     => petep_logger.gc_LOG_CONTEXT_METHOD,
                   a_result_in      => a_result_in);
    END;

    --
    -- Logs runner thingies
    --
    -- %param a_context_in suite / script / CASE / BLOCK | SCHEMA / PACKAGE / method
    -- %param a_result_in logged result
    -- %param a_description_in
    --------------------------------------------------------------------------------
    PROCEDURE log_runner
    (
        a_description_in IN petep_logger.typ_description,
        a_result_in      IN petep_logger.typ_execution_result DEFAULT gc_SUCCESS,
        a_context_in     IN petep_logger.typ_log_context DEFAULT gc_LOG_CONTEXT_METHOD
    ) IS
    BEGIN
        dbms_output.put_line(rpad('.', get_indent(a_context_in), ' ') ||
                             a_description_in);
    END;

    PROCEDURE init IS
    BEGIN
        g_asserts_passed := 0;
        g_asserts_failed := 0;
    
        g_test_start := SYSDATE;
        g_run_id     := petes_run_log.nextval;
    END;

END;
/
