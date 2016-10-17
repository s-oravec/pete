CREATE OR REPLACE PACKAGE BODY pete_assert IS

    gc_null     CONSTANT VARCHAR2(4) := 'NULL';
    gc_not_null CONSTANT VARCHAR2(10) := 'NOT NULL';

    gc_diff_window_size CONSTANT NUMBER := 20;
    --
    -- converts a boolean value to a string representation - 'TRUE', 'FALSE', 'NULL'
    --------------------------------------------------------------------------------
    FUNCTION bool2char(a_bool_in IN BOOLEAN) RETURN VARCHAR2 IS
    BEGIN
        IF (a_bool_in) THEN
            RETURN 'TRUE';
        ELSIF (NOT a_bool_in) THEN
            RETURN 'FALSE';
        ELSE
            RETURN 'NULL';
        END IF;
    END;

    --
    -- parse formated call stack and get stack before call of assert package
    --------------------------------------------------------------------------------  
    FUNCTION get_call_stack_before_assert RETURN VARCHAR2 IS
        l_stack    VARCHAR2(32767);
        l_from_pos NUMBER;
        --TODO: use precompiler directives here to get package name or set as literal during installation      
        lc_ASSERT_PACKAGE CONSTANT VARCHAR2(61) := USER || '.PETE_ASSERT';
        l_Result VARCHAR2(32767);
    BEGIN
        pete_logger.trace('GET_CALL_STACK_BEFORE_ASSERT');
        --
        l_stack := dbms_utility.format_call_stack;
        pete_logger.trace('stack: ' || chr(10) || l_stack);
        -- find las occurence of lc_ASSERT_PACKAGE in stack
        l_from_pos := 1;
        WHILE INSTR(l_stack, lc_ASSERT_PACKAGE, l_from_pos) > 0 LOOP
            l_from_pos := INSTR(l_stack, lc_ASSERT_PACKAGE, l_from_pos) + LENGTH(lc_ASSERT_PACKAGE) + 1;
        END LOOP;
        --
        l_Result := TRIM(SUBSTR(l_stack, l_from_pos));
        pete_logger.trace('GET_CALL_STACK_BEFORE_ASSERT> ' || chr(10) || l_Result);
        RETURN l_Result;
        --
    END;

    --
    --TODO: review: what is use for this?
    --TODO: reviewed: it was used to display package and linenumber of an assert - to locate it easily. This feature was killed during the refactoring
    --------------------------------------------------------------------------------
    PROCEDURE get_assert_caller_info
    (
        a_object_name_out OUT VARCHAR2,
        a_plsq_line_out   OUT NUMBER
    ) IS
        l_stack VARCHAR2(32767);
    BEGIN
        pete_logger.trace('GET_ASSERT_CALLER_INFO');
        l_stack           := get_call_stack_before_assert;
        a_object_name_out := TRIM(REGEXP_SUBSTR(l_stack, '([xa-f0-9]+[ ]+)([0-9]+)(.*)', 1, 1, 'i', 3));
        a_plsq_line_out   := TO_NUMBER(REGEXP_SUBSTR(l_stack, '([xa-f0-9]+[ ]+)([0-9]+)(.*)', 1, 1, 'i', 2));
        pete_logger.trace('GET_ASSERT_CALLER_INFO> a_object_name_out:' || a_object_name_out || ', a_plsq_line_out:' || a_plsq_line_out);
    END;

    --------------------------------------------------------------------------------
    PROCEDURE this
    (
        a_value_in      IN BOOLEAN,
        a_comment_in    IN VARCHAR2,
        a_expected_in   IN VARCHAR2,
        a_actual_in     IN VARCHAR2,
        a_plsql_unit_in IN VARCHAR2,
        a_plsql_line_in  IN INTEGER
    ) IS
        l_plsql_unit VARCHAR2(255);
        l_plsql_line INTEGER;
    BEGIN
        -- NoFormat Start
        pete_logger.trace('THIS: ' ||
                          'a_value_in:' || NVL(CASE WHEN a_value_in THEN 'TRUE' WHEN NOT a_value_in THEN 'FALSE' ELSE NULL END, 'NULL') || ', ' ||
                          'a_comment_in:' || NVL(a_comment_in, 'NULL') || ', ' ||
                          'a_expected_in:' || NVL(a_expected_in, 'NULL') || ', ' ||
                          'a_actual_in:' || NVL(a_actual_in, 'NULL'));
        -- NoFormat End
        IF a_value_in THEN
            pete_logger.trace('assert this - true');
            --
            --log assert only when running in test
            IF pete_core.get_last_run_log_id IS NOT NULL THEN
                IF a_plsql_unit_in IS NULL THEN
                    get_assert_caller_info(a_object_name_out => l_plsql_unit, a_plsq_line_out => l_plsql_line);
                END IF;
                pete_logger.log_assert(a_result_in     => TRUE,
                                       a_comment_in    => a_comment_in,
                                       a_plsql_unit_in => nvl(a_plsql_unit_in, l_plsql_unit),
                                       a_plsql_line_in  => nvl(a_plsql_line_in, l_plsql_line));
            END IF;
        
        ELSE
            pete_logger.trace('assert this - false');
            --
            --log assert only when running in test
            IF pete_core.get_last_run_log_id IS NOT NULL THEN
                IF a_plsql_unit_in IS NULL THEN
                    get_assert_caller_info(a_object_name_out => l_plsql_unit, a_plsq_line_out => l_plsql_line);
                END IF;
                pete_logger.log_assert(a_result_in     => FALSE,
                                       a_comment_in    => a_comment_in,
                                       a_plsql_unit_in => nvl(a_plsql_unit_in, l_plsql_unit),
                                       a_plsql_line_in  => nvl(a_plsql_line_in, l_plsql_line));
            END IF;
            --
            raise_application_error(-20000,
                                    'Assertion failed: ' || a_comment_in || CHR(10) || --
                                    'Expected:' || a_expected_in || CHR(10) || --
                                    'Actual:  ' || a_actual_in);
        END IF;
    END;

    PROCEDURE this
    (
        a_value_in      IN BOOLEAN,
        a_comment_in    IN VARCHAR2 DEFAULT NULL,
        a_plsql_unit_in IN VARCHAR2 DEFAULT NULL,
        a_plsql_line_in  INTEGER DEFAULT NULL
    ) IS
    BEGIN
        this(a_value_in      => a_value_in,
             a_comment_in    => NVL(a_comment_in, 'Expected value to be true'),
             a_expected_in   => 'TRUE',
             a_actual_in     => bool2char(a_value_in),
             a_plsql_unit_in => a_plsql_unit_in,
             a_plsql_line_in  => a_plsql_line_in);
    END;

    -- 
    -- Group of assert procedure for testing null values
    --------------------------------------------------------------------------------
    FUNCTION is_null(a_value_in IN NUMBER) RETURN BOOLEAN IS
    BEGIN
        RETURN a_value_in IS NULL;
    END;

    --------------------------------------------------------------------------------
    PROCEDURE is_null
    (
        a_value_in      IN NUMBER,
        a_comment_in    IN VARCHAR2 DEFAULT NULL,
        a_plsql_unit_in IN VARCHAR2 DEFAULT NULL,
        a_plsql_line_in  INTEGER DEFAULT NULL
        
    ) IS
    BEGIN
        this(is_null(a_value_in => a_value_in),
             NVL(a_comment_in, a_value_in || ' is expected to be null.'),
             gc_null,
             TO_CHAR(a_value_in),
             a_plsql_unit_in,
             a_plsql_line_in);
    END;

    --------------------------------------------------------------------------------
    FUNCTION is_null(a_value_in IN VARCHAR2) RETURN BOOLEAN IS
    BEGIN
        RETURN a_value_in IS NULL;
    END;

    --------------------------------------------------------------------------------
    PROCEDURE is_null
    (
        a_value_in      IN VARCHAR2,
        a_comment_in    IN VARCHAR2 DEFAULT NULL,
        a_plsql_unit_in IN VARCHAR2 DEFAULT NULL,
        a_plsql_line_in  INTEGER DEFAULT NULL
    ) IS
    BEGIN
        this(is_null(a_value_in => a_value_in),
             NVL(a_comment_in, a_value_in || ' is expected to be null.'),
             gc_null,
             a_value_in,
             a_plsql_unit_in,
             a_plsql_line_in);
    END;

    --------------------------------------------------------------------------------
    FUNCTION is_null(a_value_in IN DATE) RETURN BOOLEAN IS
    BEGIN
        RETURN a_value_in IS NULL;
    END;

    --------------------------------------------------------------------------------
    PROCEDURE is_null
    (
        a_value_in      IN DATE,
        a_comment_in    IN VARCHAR2 DEFAULT NULL,
        a_plsql_unit_in IN VARCHAR2 DEFAULT NULL,
        a_plsql_line_in  INTEGER DEFAULT NULL
    ) IS
    BEGIN
        this(is_null(a_value_in => a_value_in),
             NVL(a_comment_in, a_value_in || ' is expected to be null.'),
             gc_null,
             TO_CHAR(a_value_in, pete_config.get_date_format),
             a_plsql_unit_in,
             a_plsql_line_in);
    END;

    -- 
    -- Group of assert procedure for testing null values
    --------------------------------------------------------------------------------
    FUNCTION is_not_null(a_value_in IN NUMBER) RETURN BOOLEAN IS
    BEGIN
        RETURN a_value_in IS NOT NULL;
    END;

    PROCEDURE is_not_null
    (
        a_value_in      IN NUMBER,
        a_comment_in    IN VARCHAR2 DEFAULT NULL,
        a_plsql_unit_in IN VARCHAR2 DEFAULT NULL,
        a_plsql_line_in  INTEGER DEFAULT NULL
    ) IS
    BEGIN
        this(is_not_null(a_value_in => a_value_in),
             NVL(a_comment_in, a_value_in || ' is expected to be not null.'),
             gc_not_null,
             TO_CHAR(a_value_in),
             a_plsql_unit_in,
             a_plsql_line_in);
    END;

    --------------------------------------------------------------------------------
    FUNCTION is_not_null(a_value_in IN VARCHAR2) RETURN BOOLEAN IS
    BEGIN
        RETURN a_value_in IS NOT NULL;
    END;

    --------------------------------------------------------------------------------
    PROCEDURE is_not_null
    (
        a_value_in      IN VARCHAR2,
        a_comment_in    IN VARCHAR2 DEFAULT NULL,
        a_plsql_unit_in IN VARCHAR2 DEFAULT NULL,
        a_plsql_line_in  INTEGER DEFAULT NULL
    ) IS
    BEGIN
        this(is_not_null(a_value_in => a_value_in),
             NVL(a_comment_in, a_value_in || ' is expected to be not null.'),
             gc_not_null,
             a_value_in,
             a_plsql_unit_in,
             a_plsql_line_in);
    END;

    --------------------------------------------------------------------------------
    FUNCTION is_not_null(a_value_in IN DATE) RETURN BOOLEAN IS
    BEGIN
        RETURN a_value_in IS NOT NULL;
    END;

    --------------------------------------------------------------------------------
    PROCEDURE is_not_null
    (
        a_value_in      IN DATE,
        a_comment_in    IN VARCHAR2 DEFAULT NULL,
        a_plsql_unit_in IN VARCHAR2 DEFAULT NULL,
        a_plsql_line_in  INTEGER DEFAULT NULL
    ) IS
    BEGIN
        this(is_not_null(a_value_in => a_value_in),
             NVL(a_comment_in, a_value_in || ' is expected to be not null.'),
             gc_not_null,
             TO_CHAR(a_value_in, pete_config.get_date_format),
             a_plsql_unit_in,
             a_plsql_line_in);
    END;

    --
    -- This assert procedure always succeeds. It's usefull to log, that something has
    -- happened if it is difficult to test it's value
    --------------------------------------------------------------------------------
    FUNCTION pass RETURN BOOLEAN IS
    BEGIN
        RETURN TRUE;
    END;

    --------------------------------------------------------------------------------
    PROCEDURE pass
    (
        a_comment_in    IN VARCHAR2 DEFAULT NULL,
        a_plsql_unit_in IN VARCHAR2 DEFAULT NULL,
        a_plsql_line_in  INTEGER DEFAULT NULL
    ) IS
    BEGIN
        this(pass, NVL(a_comment_in, 'Passed!!!'), NULL, NULL, a_plsql_unit_in, a_plsql_line_in);
    END;

    --
    -- This assert procedure always fails. It's usefull in a branch of code where the
    -- program should never enter. E.g. in an exception block
    --------------------------------------------------------------------------------
    FUNCTION fail RETURN BOOLEAN IS
    BEGIN
        RETURN FALSE;
    END;

    --------------------------------------------------------------------------------
    PROCEDURE fail
    (
        a_comment_in    IN VARCHAR2 DEFAULT NULL,
        a_plsql_unit_in IN VARCHAR2 DEFAULT NULL,
        a_plsql_line_in  INTEGER DEFAULT NULL
    ) IS
    BEGIN
        this(fail, NVL(a_comment_in, 'You shall not pass!!!'), 'FAIL', 'FAIL!!!', a_plsql_unit_in, a_plsql_line_in);
    END;

    --
    -- Group of assert procedures for testing equality of input arguments
    -- Nulls are considered equal
    --------------------------------------------------------------------------------
    FUNCTION eq
    (
        a_expected_in NUMBER,
        a_actual_in   NUMBER
    ) RETURN BOOLEAN IS
    BEGIN
        RETURN a_expected_in = a_actual_in OR(a_expected_in IS NULL AND a_actual_in IS NULL);
    END;

    --------------------------------------------------------------------------------
    PROCEDURE eq
    (
        a_expected_in   NUMBER,
        a_actual_in     NUMBER,
        a_comment_in    VARCHAR2 DEFAULT NULL,
        a_plsql_unit_in IN VARCHAR2 DEFAULT NULL,
        a_plsql_line_in  INTEGER DEFAULT NULL
    ) IS
    BEGIN
        -- NoFormat Start
        this(a_value_in        => eq(a_expected_in => a_expected_in, a_actual_in => a_actual_in),
             a_comment_in      => NVL(a_comment_in, to_char(a_actual_in) || ' is expected to be equal to ' || to_char(a_expected_in)),
             a_expected_in     => to_char(a_expected_in),
             a_actual_in       => to_char(a_actual_in),
             a_plsql_unit_in => a_plsql_unit_in,
             a_plsql_line_in         => a_plsql_line_in);
        -- NoFormat End
    END;

    --------------------------------------------------------------------------------
    FUNCTION eq
    (
        a_expected_in VARCHAR2,
        a_actual_in   VARCHAR2
    ) RETURN BOOLEAN IS
    BEGIN
        RETURN a_expected_in = a_actual_in OR(a_expected_in IS NULL AND a_actual_in IS NULL);
    END;

    --------------------------------------------------------------------------------
    PROCEDURE eq
    (
        a_expected_in   VARCHAR2,
        a_actual_in     VARCHAR2,
        a_comment_in    VARCHAR2 DEFAULT NULL,
        a_plsql_unit_in IN VARCHAR2 DEFAULT NULL,
        a_plsql_line_in  INTEGER DEFAULT NULL
    ) IS
    BEGIN
        -- TODO: to_char(date, format) - format to pete_config
        -- NoFormat Start
        this(a_value_in    => eq(a_expected_in => a_expected_in, a_actual_in => a_actual_in),
             a_comment_in  => NVL(a_comment_in, a_actual_in || ' is expected to be equal to ' || a_expected_in),
             a_expected_in => a_expected_in,
             a_actual_in   => a_actual_in,
             a_plsql_unit_in => a_plsql_unit_in,
             a_plsql_line_in         => a_plsql_line_in);
        -- NoFormat End
    END;

    --------------------------------------------------------------------------------
    FUNCTION eq
    (
        a_expected_in DATE,
        a_actual_in   DATE
    ) RETURN BOOLEAN IS
    BEGIN
        RETURN a_expected_in = a_actual_in OR(a_expected_in IS NULL AND a_actual_in IS NULL);
    END;

    --------------------------------------------------------------------------------
    PROCEDURE eq
    (
        a_expected_in   DATE,
        a_actual_in     DATE,
        a_comment_in    VARCHAR2 DEFAULT NULL,
        a_plsql_unit_in IN VARCHAR2 DEFAULT NULL,
        a_plsql_line_in  INTEGER DEFAULT NULL
    ) IS
    BEGIN
        -- TODO: to_char(date, format) - format to pete_config
        -- NoFormat Start
        this(a_value_in    => eq(a_expected_in => a_expected_in, a_actual_in => a_actual_in),
             a_comment_in  => NVL(a_comment_in, to_char(a_actual_in) || ' is expected to be equal to ' || to_char(a_expected_in)),
             a_expected_in => to_char(a_expected_in),
             a_actual_in   => to_char(a_actual_in),
             a_plsql_unit_in => a_plsql_unit_in,
             a_plsql_line_in         => a_plsql_line_in);
        -- NoFormat End
    END;

    --------------------------------------------------------------------------------
    FUNCTION eq
    (
        a_expected_in BOOLEAN,
        a_actual_in   BOOLEAN
    ) RETURN BOOLEAN IS
    BEGIN
        RETURN a_expected_in = a_actual_in OR(a_expected_in IS NULL AND a_actual_in IS NULL);
    END;

    --------------------------------------------------------------------------------
    PROCEDURE eq
    (
        a_expected_in   BOOLEAN,
        a_actual_in     BOOLEAN,
        a_comment_in    VARCHAR2 DEFAULT NULL,
        a_plsql_unit_in IN VARCHAR2 DEFAULT NULL,
        a_plsql_line_in  INTEGER DEFAULT NULL
    ) IS
    BEGIN
        -- NoFormat Start
        this(a_value_in    => eq(a_expected_in => a_expected_in, a_actual_in => a_actual_in),
             a_comment_in  => NVL(a_comment_in, bool2char(a_actual_in) || ' is expected to be equal to ' || bool2char(a_expected_in)),
             a_expected_in => bool2char(a_expected_in),
             a_actual_in   => bool2char(a_actual_in),
             a_plsql_unit_in => a_plsql_unit_in,
             a_plsql_line_in         => a_plsql_line_in);
        -- NoFormat End
    END;

    --------------------------------------------------------------------------------
    FUNCTION eq
    (
        a_expected_in IN sys.xmltype,
        a_actual_in   IN sys.xmltype
    ) RETURN BOOLEAN IS
    BEGIN
        IF (a_expected_in IS NULL AND a_actual_in IS NOT NULL OR a_expected_in IS NOT NULL AND a_actual_in IS NULL) THEN
            RETURN FALSE;
        ELSIF (a_expected_in IS NULL AND a_actual_in IS NULL) THEN
            RETURN TRUE;
        ELSE
            RETURN a_expected_in.extract('/').getclobval = a_actual_in.extract('/').getclobval;
        END IF;
    END;

    -- 
    -- helper procedure which finds beginning of difference between char representation
    -- of two non empty xmltypes. It returns position of first difference
    FUNCTION get_diff_position
    (
        a_xml_in  IN xmltype,
        a_xml2_in xmltype
    ) RETURN NUMBER IS
    
        l_clob   CLOB;
        l_clob2  CLOB;
        l_Result NUMBER;
        l_POS    NUMBER;
        l_max    NUMBER;
        l_step   NUMBER;
        l_nahoru BOOLEAN;
    BEGIN
    
        l_clob  := a_xml_in.extract('/').getclobval();
        l_clob2 := a_xml2_in.extract('/').getclobval();
        l_max   := (length(l_clob) + length(l_clob2)) / 2;
        --smallest greater power of 2
        l_max    := power(2, ceil(log(2, l_max)));
        l_step   := l_max / 2;
        l_POS    := l_max;
        l_nahoru := FALSE;
        WHILE l_step >= 1 LOOP
            IF (l_nahoru) THEN
                l_POS := l_POS + l_step;
            ELSE
                l_POS := l_POS - l_step;
            END IF;
            IF (substr(l_clob, 1, l_POS) = substr(l_clob2, 1, l_POS)) THEN
                l_nahoru := TRUE;
            ELSE
                l_nahoru := FALSE;
            END IF;
            l_step := l_step / 2;
        END LOOP;
        IF (l_nahoru) THEN
            RETURN l_POS + 1;
        ELSE
            RETURN l_POS;
        END IF;
        /*                FOR x IN 1 .. length(l_clob)
                        LOOP
                            IF (substr(l_clob, x, 1) <> substr(l_clob2, x, 1))
                            THEN
                                l_result := x;
                                EXIT;
                            END IF;
                        END LOOP;
        */
        RETURN l_Result;
    END;

    --------------------------------------------------------------------------------
    PROCEDURE eq
    (
        a_expected_in   IN sys.xmltype,
        a_actual_in     IN sys.xmltype,
        a_comment_in    IN VARCHAR2 DEFAULT NULL,
        a_plsql_unit_in IN VARCHAR2 DEFAULT NULL,
        a_plsql_line_in  INTEGER DEFAULT NULL
    ) IS
        l_this    BOOLEAN;
        l_comment VARCHAR2(500) := a_comment_in;
        l_Diff    NUMBER;
    BEGIN
        l_this := eq(a_expected_in => a_expected_in, a_actual_in => a_actual_in);
        IF l_this THEN
            IF l_comment IS NULL THEN
                IF a_expected_in IS NULL THEN
                    l_comment := 'exmpty xmlType equals empty xmlType';
                ELSE
                    l_comment := 'xmlTypes equals each other';
                END IF;
            END IF;
            this(a_value_in => l_this, a_comment_in => l_comment);
        ELSE
            -- not equal
            IF (a_expected_in IS NULL) THEN
                this(a_value_in      => l_this,
                     a_comment_in    => NVL(a_comment_in,
                                            substr(a_actual_in.extract('/').getclobval, 1, 100) || '... is expected to be equal to <NULL>'),
                     a_expected_in   => '<NULL>',
                     a_actual_in     => substr(a_actual_in.extract('/').getclobval, 1, 100) || '...',
                     a_plsql_unit_in => a_plsql_unit_in,
                     a_plsql_line_in  => a_plsql_line_in);
            ELSIF (a_actual_in IS NULL) THEN
                this(a_value_in      => l_this,
                     a_comment_in    => NVL(a_comment_in,
                                            '<NULL> is expected to be equal to ' || substr(a_actual_in.extract('/').getclobval, 1, 100) ||
                                            '...'),
                     a_expected_in   => substr(a_actual_in.extract('/').getclobval, 1, 100) || '...',
                     a_actual_in     => '<NULL>',
                     a_plsql_unit_in => a_plsql_unit_in,
                     a_plsql_line_in  => a_plsql_line_in);
            ELSE
                --         find_difference(a_xml_in => a_expected_in, a_xml2_in => a_actual_in, a_diff_from => l_from, a_diff_to => l_to);
                l_Diff := get_diff_position(a_xml_in => a_expected_in, a_xml2_in => a_actual_in);
                this(a_value_in      => l_this,
                     a_comment_in    => NVL(a_comment_in,
                                            substr(a_actual_in.extract('/').getclobval, 1, 100) || '...' || chr(10) ||
                                            'is expected to be equal to: ' || substr(a_expected_in.extract('/').getclobval, 1, 100) || '...' ||
                                            chr(10)),
                     a_expected_in   => substr(a_expected_in.extract('/').getclobval,
                                               greatest(l_Diff - gc_diff_window_size / 2, 1),
                                               gc_diff_window_size),
                     a_actual_in     => substr(a_actual_in.extract('/').getclobval,
                                               greatest(l_Diff - gc_diff_window_size / 2, 1),
                                               gc_diff_window_size) || chr(10) || 'Difference starts at position ' || l_Diff,
                     a_plsql_unit_in => a_plsql_unit_in,
                     a_plsql_line_in  => a_plsql_line_in);
            END IF;
        END IF;
    END;

END;
/
