CREATE OR REPLACE PACKAGE BODY pete_logger AS

    gc_LOG_TO_DBMS_OUTPUT CONSTANT BOOLEAN := TRUE;

    g_log_to_dbms_output BOOLEAN;
    g_trace              BOOLEAN := FALSE;

    --used to update log_run record as method description is available after 
    --log record for method is already created
    g_run_log_id           INTEGER;
    g_output_run_log_id    INTEGER;
    g_parent_run_log_id_in INTEGER;
    g_object_type_in       pete_run_log.object_type%TYPE;
    g_object_name_in       pete_run_log.object_name%TYPE;

    --------------------------------------------------------------------------------
    FUNCTION get_package_description(a_package_name_in IN user_procedures.object_name%TYPE)
        RETURN VARCHAR2 IS
        l_call_template CONSTANT VARCHAR2(255) --
        := 'begin :1 := #PackageName#.description; end;';
        l_result VARCHAR(255);
    BEGIN
        EXECUTE IMMEDIATE REPLACE(l_call_template,
                                  '#PackageName#',
                                  a_package_name_in)
            USING OUT l_result;
        RETURN l_result;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END get_package_description;

    --------------------------------------------------------------------------------  
    FUNCTION get_suite_description(a_suite_name_in IN VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Suite ' || a_suite_name_in;
    END get_suite_description;

    --
    -- package initialization
    --
    --------------------------------------------------------------------------------
    PROCEDURE init(a_log_to_dbms_output_in IN BOOLEAN DEFAULT TRUE) IS
    BEGIN
        g_log_to_dbms_output := nvl(a_log_to_dbms_output_in,
                                    gc_LOG_TO_DBMS_OUTPUT);
    END init;

    --------------------------------------------------------------------------------
    PROCEDURE log_start
    (
        a_run_log_id_in        IN pete_run_log.id%TYPE,
        a_parent_run_log_id_in IN pete_run_log.parent_id%TYPE,
        a_description_in       IN pete_run_log.description%TYPE,
        a_object_type_in       IN pete_run_log.object_type%TYPE,
        a_object_name_in       IN pete_run_log.object_name%TYPE
    ) IS
        lrec_pete_run_log pete_run_log%ROWTYPE;
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        --
        trace('LOG_START: ' || 'a_run_log_id_in:' ||
              NVL(to_char(a_run_log_id_in), 'NULL') || ', ' ||
              'a_parent_run_log_id_in:' ||
              NVL(to_char(a_parent_run_log_id_in), 'NULL') || ', ' ||
              'a_description_in:' || NVL(a_description_in, 'NULL') || ', ' ||
              'a_object_type_in:' || NVL(a_object_type_in, 'NULL') || ', ' ||
              'a_object_name_in:' || NVL(a_object_name_in, 'NULL'));
    
        g_run_log_id           := a_run_log_id_in;
        g_parent_run_log_id_in := a_parent_run_log_id_in;
        g_object_type_in       := a_object_type_in;
        g_object_name_in       := a_object_name_in;
    
        --
        lrec_pete_run_log.id          := a_run_log_id_in;
        lrec_pete_run_log.parent_id   := a_parent_run_log_id_in;
        lrec_pete_run_log.object_type := a_object_type_in;
        lrec_pete_run_log.object_name := a_object_name_in;
        lrec_pete_run_log.test_begin  := systimestamp;
        --
        CASE a_object_type_in
            WHEN pete_core.g_OBJECT_TYPE_PACKAGE THEN
                lrec_pete_run_log.description := get_package_description(a_package_name_in => a_object_name_in) ||
                                                 a_description_in;
            WHEN pete_core.g_OBJECT_TYPE_SUITE THEN
                lrec_pete_run_log.description := get_suite_description(a_suite_name_in => a_object_name_in) ||
                                                 a_description_in;
            ELSE
                lrec_pete_run_log.description := a_description_in;
        END CASE;
        --
        lrec_pete_run_log.description := nvl(lrec_pete_run_log.description,
                                             'Testing ' ||
                                             lower(a_object_type_in) || ' ' ||
                                             upper(a_object_name_in));
        --
        INSERT INTO pete_run_log VALUES lrec_pete_run_log;
        --
        COMMIT;
        --
    END;

    --------------------------------------------------------------------------------
    PROCEDURE log_end
    (
        a_run_log_id_in      IN pete_run_log.id%TYPE,
        a_result_in          IN pete_run_log.result%TYPE,
        a_xml_in_in          IN pete_run_log.xml_in%TYPE,
        a_xml_out_in         IN pete_run_log.xml_out%TYPE,
        a_error_code_in      IN pete_run_log.error_code%TYPE,
        a_error_stack_in     IN pete_run_log.error_stack%TYPE,
        a_error_backtrace_in IN pete_run_log.error_backtrace%TYPE
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        --
        trace('LOG_END: ' || 'a_run_log_id_in:' ||
              NVL(to_char(a_run_log_id_in), 'NULL') || ', ' || 'a_result_in:' ||
              NVL(a_result_in, 'NULL') || ', ' || 'a_error_code_in:' ||
              NVL(to_char(a_error_code_in), 'NULL') || ', ' ||
              'a_error_stack_in:' || NVL(a_error_stack_in, 'NULL') || ', ' ||
              'a_error_backtrace_in:' || NVL(a_error_backtrace_in, 'NULL'));
        UPDATE pete_run_log p
           SET p.result          = a_result_in,
               p.test_end        = systimestamp,
               p.xml_in          = a_xml_in_in,
               p.xml_out         = a_xml_out_in,
               p.error_code      = a_error_code_in,
               p.error_stack     = a_error_stack_in,
               p.error_backtrace = a_error_backtrace_in
         WHERE id = a_run_log_id_in;
        --
        COMMIT;
    END;

    --------------------------------------------------------------------------------
    PROCEDURE log_method_description(a_description_in IN pete_core.typ_description) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        --
        trace('LOG_METHOD_DESCRIPTION: ' || 'a_description_in:' ||
              NVL(a_description_in, 'NULL'));
        UPDATE pete_run_log
           SET description = a_description_in
         WHERE id = g_run_log_id; --set to package session variable on start of method execution
        --
        COMMIT;
        --
    END;

    --------------------------------------------------------------------------------
    PROCEDURE log_assert
    (
        a_result_in  BOOLEAN,
        a_comment_in VARCHAR2
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        lrec_pete_run_log pete_run_log%ROWTYPE;
    BEGIN
    
        --
        lrec_pete_run_log.id          := petes_run_log.nextval;
        lrec_pete_run_log.parent_id   := g_parent_run_log_id_in;
        lrec_pete_run_log.object_type := pete_core.g_OBJECT_TYPE_ASSERT;
        lrec_pete_run_log.object_name := g_object_name_in;
        lrec_pete_run_log.test_begin  := systimestamp;
        lrec_pete_run_log.test_end    := systimestamp;
        lrec_pete_run_log.description := a_comment_in;
        IF (a_result_in)
        THEN
            lrec_pete_run_log.result := pete_core.g_SUCCESS;
        ELSE
            lrec_pete_run_log.result := pete_core.g_FAILURE;
        END IF;
        --
        INSERT INTO pete_run_log VALUES lrec_pete_run_log;
        --
        COMMIT;
    END log_assert;

    --
    --wrapper for trace log 
    --
    --------------------------------------------------------------------------------
    PROCEDURE trace(a_trace_message_in VARCHAR2) IS
    BEGIN
        IF (g_trace)
        THEN
            dbms_output.put_line('TRACE> ' || a_trace_message_in); --enhancement  --konfigurovatelne globalne
        END IF;
    END trace;

    --
    -- trace log settings
    --
    PROCEDURE set_trace(a_value_in IN BOOLEAN) IS
    BEGIN
        g_trace := a_value_in;
    END set_trace;

    --------------------------------------------------------------------------------
    FUNCTION get_output_run_log_id RETURN pete_run_log.id%TYPE IS
    BEGIN
        RETURN g_output_run_log_id;
    END;

    --------------------------------------------------------------------------------
    PROCEDURE print_top_level_result(a_result_in IN BOOLEAN) IS
    BEGIN
        dbms_output.put_line('.');
        IF a_result_in
        THEN
            dbms_output.put_line('.   SSSS   U     U   CCC     CCC   EEEEEEE   SSSS     SSSS   ');
            dbms_output.put_line('.  S    S  U     U  C   C   C   C  E        S    S   S    S  ');
            dbms_output.put_line('. S        U     U C     C C     C E       S        S        ');
            dbms_output.put_line('.  S       U     U C       C       E        S        S       ');
            dbms_output.put_line('.   SSSS   U     U C       C       EEEE      SSSS     SSSS   ');
            dbms_output.put_line('.       S  U     U C       C       E             S        S  ');
            dbms_output.put_line('.        S U     U C     C C     C E              S        S ');
            dbms_output.put_line('.  S    S   U   U   C   C   C   C  E        S    S   S    S  ');
            dbms_output.put_line('.   SSSS     UUU     CCC     CCC   EEEEEEE   SSSS     SSSS   ');
        ELSE
            dbms_output.put_line('. FFFFFFF   AA     III  L      U     U RRRRR   EEEEEEE ');
            dbms_output.put_line('. F        A  A     I   L      U     U R    R  E       ');
            dbms_output.put_line('. F       A    A    I   L      U     U R     R E       ');
            dbms_output.put_line('. F      A      A   I   L      U     U R     R E       ');
            dbms_output.put_line('. FFFF   A      A   I   L      U     U RRRRRR  EEEE    ');
            dbms_output.put_line('. F      AAAAAAAA   I   L      U     U R   R   E       ');
            dbms_output.put_line('. F      A      A   I   L      U     U R    R  E       ');
            dbms_output.put_line('. F      A      A   I   L       U   U  R     R E       ');
            dbms_output.put_line('. F      A      A  III  LLLLLLL  UUU   R     R EEEEEEE ');
        END IF;
    END;

    --------------------------------------------------------------------------------
    PROCEDURE output_log(a_run_log_id_in IN pete_run_log.id%TYPE) IS
        l_print            BOOLEAN;
        l_top_level_result BOOLEAN;
    BEGIN
        trace('OUTPUT_LOG: ' || 'a_run_log_id_in:' ||
              NVL(to_char(a_run_log_id_in), 'NULL'));
        g_output_run_log_id := a_run_log_id_in;
        dbms_output.put_line(chr(10));
        FOR log_line IN (SELECT * FROM petev_output_run_log)
        LOOP
            l_print := TRUE;
            --first record in the view is the top level one
            IF (l_top_level_result IS NULL)
            THEN
                IF (log_line.result = pete_core.g_SUCCESS)
                THEN
                    l_top_level_result := TRUE;
                ELSE
                    l_top_level_result := FALSE;
                END IF;
            END IF;
            IF (NOT pete_config.get_show_hook_methods AND
               log_line.object_type = pete_core.g_OBJECT_TYPE_HOOK)
            THEN
                pete_logger.trace('not printing hook methods - ' ||
                                  log_line.log);
                l_print := FALSE;
            ELSIF log_line.object_type = pete_core.g_OBJECT_TYPE_ASSERT
            THEN
                IF (pete_config.get_show_asserts = pete_config.g_ASSERTS_NONE)
                THEN
                    pete_logger.trace('not printing asserts - ' ||
                                      log_line.log);
                    l_print := FALSE;
                ELSIF (pete_config.get_show_asserts =
                      pete_config.g_ASSERTS_FAILED AND
                      log_line.result = pete_core.g_SUCCESS)
                THEN
                    pete_logger.trace('not printing success asserts - ' ||
                                      log_line.log);
                    l_print := FALSE;
                END IF;
            END IF;
        
            IF (l_print)
            THEN
                IF log_line.object_type IN
                   (pete_core.g_OBJECT_TYPE_PACKAGE,
                    pete_core.g_OBJECT_TYPE_SCRIPT)
                THEN
                    dbms_output.put_line('.');
                END IF;
                dbms_output.put_line('.' || log_line.log);
            END IF;
        END LOOP;
    
        print_top_level_result(l_top_level_result);
        dbms_output.put_line(chr(10) || chr(10));
    END;

    --------------------------------------------------------------------------------                 
    FUNCTION display_log(a_run_log_id_in IN pete_run_log.id%TYPE)
        RETURN petet_log_tab
        PIPELINED IS
    BEGIN
        trace('DISPLAY_LOG: ' || 'a_run_log_id_in:' ||
              NVL(to_char(a_run_log_id_in), 'NULL'));
        g_output_run_log_id := a_run_log_id_in;
        FOR log_line IN (SELECT petet_log(log) text FROM petev_output_run_log)
        LOOP
            PIPE ROW(log_line.text);
        END LOOP;
    END;

BEGIN
    init(a_log_to_dbms_output_in => TRUE);
END;
/
