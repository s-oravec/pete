CREATE OR REPLACE PACKAGE BODY petep_convention_runner AS

    -- overall test result
    g_test_result BOOLEAN;
    -- trace setting
    g_trace BOOLEAN;

    --    g_test_id NUMBER; -- test run identifier
    g_test_start DATE;

    --number of passed asserts
    g_asserts_passed NUMBER;
    --number of failed asserts
    g_asserts_failed NUMBER;

    --g_run_id NUMBER;

    --"currently executed" test package
    g_test_package VARCHAR2(30);
    --"currently executed" test method
    g_test_method VARCHAR2(30);

    g_user VARCHAR2(30) := USER; -- cache for performance

    /**
    * wrapper for trace log
    */
    PROCEDURE trace(a_co_in VARCHAR2) IS
    BEGIN
        IF (g_trace)
        THEN
            dbms_output.put_line('TRACE> ' || a_co_in); --enhancement  --konfigurovatelne globalne
        END IF;
    
    END;

    /**
    * trace log settings
    */
    PROCEDURE set_trace(a_value_in IN BOOLEAN) IS
    BEGIN
        g_trace := a_value_in;
    END;

    /**
    * wrapper for dynamic SQL
    */
    PROCEDURE execute_sql(a_sql_in IN VARCHAR2) IS
    BEGIN
        trace('EXEC IMM:' || a_sql_in);
        EXECUTE IMMEDIATE a_sql_in;
    END;

    /**
    * initilization of globals
    */
    PROCEDURE init IS
    BEGIN
        g_test_result := TRUE;
        -- read enhancements  from config
        g_test_start := SYSDATE;
    
        g_asserts_failed := 0;
        g_asserts_passed := 0;
    
        --g_run_id := pete_run_log_seq.nextval;
        petep_logger.init;
    END;

    --------------------------------------------------------------------------------
    FUNCTION package_has_method
    (
        a_package_name_in IN user_procedures.object_name%TYPE,
        a_method_name_in  IN user_procedures.procedure_name%TYPE
    ) RETURN BOOLEAN IS
    BEGIN
        FOR ii IN (SELECT 1
                     FROM user_procedures
                    WHERE object_name = a_package_name_in
                      AND procedure_name = a_method_name_in)
        LOOP
            RETURN TRUE;
        END LOOP;
        RETURN FALSE;
    END package_has_method;

    --------------------------------------------------------------------------------
    PROCEDURE execute_hook_method
    (
        a_package_name_in     IN user_procedures.object_name%TYPE,
        a_hook_method_name_in IN user_procedures.procedure_name%TYPE
    ) IS
    BEGIN
        IF package_has_method(a_package_name_in => a_package_name_in,
                              a_method_name_in  => a_hook_method_name_in)
        THEN
            execute_sql(a_sql_in => 'begin ' || chr(10) || --
                                    a_package_name_in || '.' ||
                                    a_hook_method_name_in || ';' || chr(10) || --
                                    'end;');
        END IF;
        --TODO: REVIEW: else trace?
    END;

    --------------------------------------------------------------------------------
    PROCEDURE log_package_description(a_package_name_in IN user_procedures.object_name%TYPE) IS
        l_call_template CONSTANT VARCHAR2(32767) --
        := 'BEGIN' || chr(10) || --
           '  petep_logger.log_runner(a_context_in     => petep_logger.gc_LOG_CONTEXT_PACKAGE,' ||
           chr(10) || --
           '                          a_description_in => #PackageName#.description);' ||
           chr(10) || --
           'END;';
    BEGIN
        EXECUTE IMMEDIATE REPLACE(l_call_template,
                                  '#PackageName#',
                                  a_package_name_in);
    EXCEPTION
        WHEN OTHERS THEN
            petep_logger.log_runner(a_context_in     => petep_logger.gc_LOG_CONTEXT_PACKAGE,
                                    a_description_in => 'Running tests in ' ||
                                                        a_package_name_in);
    END;

    /**
    * Tests one package
    * %param a_package_name_in package name to be tested
    * %param a_test_package_in if true, then methods of a_package_name_in would be run
    *                          if false, then methods of UT_ || a_package_name_in would be run
    * %param a_method_like_in filter for methods being run - if null, all methods would be run
    */
    PROCEDURE test
    (
        a_package_name_in IN VARCHAR2,
        a_test_package_in IN BOOLEAN DEFAULT FALSE,
        a_method_like_in  IN VARCHAR2 DEFAULT NULL
    ) IS
        l_package_with_tests VARCHAR2(30);
        l_sql                VARCHAR2(500);
    BEGIN
        trace('PROCEDURE TEST a_package_in:' || a_package_name_in);
        --
        init;
        --
        IF (a_test_package_in)
        THEN
            l_package_with_tests := a_package_name_in;
        ELSE
            l_package_with_tests := 'UT_' || upper(a_package_name_in); -- TODO: enhancement - configurable prefix
        END IF;
        --
        log_package_description(a_package_name_in => l_package_with_tests);
        --
        execute_hook_method(a_package_name_in     => l_package_with_tests,
                            a_hook_method_name_in => 'BEFORE_ALL');
        --
        <<tested_methods_loop>>
        FOR r_method IN (SELECT procedure_name
                           FROM user_procedures up
                          WHERE object_name = l_package_with_tests
                            AND procedure_name NOT IN
                                ('BEFORE_ALL',
                                 'BEFORE_EACH',
                                 'AFTER_ALL',
                                 'AFTER_EACH')
                            AND (a_method_like_in IS NULL OR
                                procedure_name LIKE a_method_like_in)
                          ORDER BY up.subprogram_id)
        
        LOOP
            execute_hook_method(a_package_name_in     => l_package_with_tests,
                                a_hook_method_name_in => 'BEFORE_EACH');
            --
            l_sql          := 'begin ' || --
                              l_package_with_tests || '.' ||
                              r_method.procedure_name || '; ' || --
                              ' end;';
            g_test_package := l_package_with_tests;
            g_test_method  := r_method.procedure_name;
            --
            execute_sql(a_sql_in => l_sql);
            --
            execute_hook_method(a_package_name_in     => l_package_with_tests,
                                a_hook_method_name_in => 'AFTER_EACH');
        
        END LOOP tested_methods_loop;
        --
        execute_hook_method(a_package_name_in     => l_package_with_tests,
                            a_hook_method_name_in => 'AFTER_ALL');
        --
        petep_logger.print_result;
    END;

    /**
    * returns line number from which was called an assert procedure
    */
    FUNCTION get_call_line(a_package_name_in IN VARCHAR2) RETURN NUMBER IS
        l_stack VARCHAR2(1000);
        l_part  VARCHAR2(30);
    BEGIN
        l_stack := dbms_utility.format_call_stack;
        l_part  := substr(l_stack,
                          regexp_instr(l_stack,
                                       '[0-9]* *package body ' || g_user || '.' ||
                                       a_package_name_in),
                          4);
    
        RETURN to_number(TRIM(l_part));
    END;
    /**
    * logs detailed info about an assert and its result
    */
    /*    PROCEDURE log_detail
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
                (ut_run_log_details_seq.nextval,
                 g_run_id,
                 a_result_in,
                 a_comment_in,
                 g_test_package,
                 g_test_method,
                 a_line_number_in,
                 systimestamp);
    
            COMMIT;
        END;
    */
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
        l_result := a_result_in || '-' || a_comment_in || ' (' || a_package_in || ':' ||
                    a_line_number_in || ', proc-' || a_method_in || ');';
        RETURN l_result;
    END;

    /**
    * API used to set execution result - for pete framework testing
    */
    PROCEDURE set_test_result(a_value_in BOOLEAN) IS
    BEGIN
        g_test_result := a_value_in;
    END;

BEGIN
    init;
END;
/
