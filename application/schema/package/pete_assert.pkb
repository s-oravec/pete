CREATE OR REPLACE PACKAGE BODY pete_assert IS

    gc_null     CONSTANT VARCHAR2(4) := 'NULL';
    gc_not_null CONSTANT VARCHAR2(10) := 'NOT NULL';

    --
    -- converts a boolean value to a string representation - 'TRUE', 'FALSE', 'NULL'
    --------------------------------------------------------------------------------
    FUNCTION bool2char(a_bool_in IN BOOLEAN) RETURN VARCHAR2 IS
    BEGIN
        IF (a_bool_in)
        THEN
            RETURN 'TRUE';
        ELSIF (NOT a_bool_in)
        THEN
            RETURN 'FALSE';
        ELSE
            RETURN 'NULL';
        END IF;
    END;

    --
    -- parse formated call stack and get stack before call of assert package
    --------------------------------------------------------------------------------  
    FUNCTION get_call_stack_before_assert RETURN VARCHAR2 IS
        l_stack    VARCHAR2(1000);
        l_from_pos NUMBER;
        --TODO: use precompiler directives here to get package name or set as literal during installation      
        lc_ASSERT_PACKAGE CONSTANT VARCHAR2(30) := USER || '.PETE_ASSERT';
    BEGIN
        --
        l_stack := dbms_utility.format_call_stack;
    
        -- find las occurence of lc_ASSERT_PACKAGE in stack
        l_from_pos := 1;
        WHILE INSTR(l_stack, lc_ASSERT_PACKAGE, l_from_pos) > 0
        LOOP
            l_from_pos := INSTR(l_stack, lc_ASSERT_PACKAGE, l_from_pos) +
                          LENGTH(lc_ASSERT_PACKAGE) + 1;
        END LOOP;
        --
        RETURN TRIM(SUBSTR(l_stack, l_from_pos));
        --
    END;

    --
    --TODO: review: what is use for this?
    --TODO: reviewed: it was used to display package and linenumber of an assert - to locate it easily. This feature was killed during the refactoring
    --------------------------------------------------------------------------------
    PROCEDURE get_assert_caller_info
    (
        a_object_name_out OUT VARCHAR2,
        a_line_number_out OUT NUMBER
    ) IS
        l_stack VARCHAR2(1000);
    BEGIN
        pete_logger.trace('GET_ASSERT_CALLER_INFO');
        l_stack           := get_call_stack_before_assert;
        a_object_name_out := TRIM(REGEXP_SUBSTR(l_stack,
                                                '([xa-f0-9]+[ ]+)([0-9]+)(.*)',
                                                1,
                                                1,
                                                'i',
                                                3));
        pete_logger.trace('a_object_name_out ' || a_object_name_out);
        a_line_number_out := TO_NUMBER(REGEXP_SUBSTR(l_stack,
                                                     '([xa-f0-9]+[ ]+)([0-9]+)(.*)',
                                                     1,
                                                     1,
                                                     'i',
                                                     2));
        pete_logger.trace('a_line_number_out ' || a_line_number_out);
    END;

    --------------------------------------------------------------------------------
    PROCEDURE this
    (
        a_value_in    IN BOOLEAN,
        a_comment_in  IN VARCHAR2,
        a_expected_in IN VARCHAR2,
        a_actual_in   IN VARCHAR2
        
    ) IS
    BEGIN
        -- NoFormat Start
        pete_logger.trace('THIS: ' || 'a_value_in:' || NVL(CASE WHEN a_value_in THEN 'TRUE' WHEN NOT a_value_in THEN 'FALSE' ELSE NULL END, 'NULL') || ', ' ||
                          'a_comment_in:' || NVL(a_comment_in, 'NULL') || ', ' ||
                          'a_expected_in:' || NVL(a_expected_in, 'NULL') || ', ' ||
                          'a_actual_in:' || NVL(a_actual_in, 'NULL'));
        -- NoFormat End
        IF a_value_in
        THEN
            pete_logger.trace('assert this - true');
            --
            --log assert only when running in test
            IF pete_core.get_last_run_log_id IS NOT NULL
            THEN
                pete_logger.log_assert(a_result_in  => TRUE,
                                       a_comment_in => 'ASSERT - ' ||
                                                       a_comment_in);
            END IF;
        
        ELSE
            pete_logger.trace('assert this - false');
            --
            --log assert only when running in test
            IF pete_core.get_last_run_log_id IS NOT NULL
            THEN
                pete_logger.log_assert(a_result_in  => FALSE,
                                       a_comment_in => 'ASSERT FAILURE - ' ||
                                                       a_comment_in);
            END IF;
        
            raise_application_error(-20000,
                                    'Assertion failed: ' || a_comment_in ||
                                    CHR(10) || --
                                    'Expected:' || a_expected_in || CHR(10) || --
                                    'Actual:  ' || a_actual_in);
        END IF;
    END;

    PROCEDURE this
    (
        a_value_in   IN BOOLEAN,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        this(a_value_in    => a_value_in,
             a_comment_in  => NVL(a_comment_in, 'Expected value to be true'),
             a_expected_in => 'TRUE',
             a_actual_in   => bool2char(a_value_in));
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
        a_value_in   IN NUMBER,
        a_comment_in IN VARCHAR2 DEFAULT NULL
        
    ) IS
    BEGIN
        this(is_null(a_value_in => a_value_in),
             NVL(a_comment_in, a_value_in || ' is expected to be null.'),
             gc_null,
             TO_CHAR(a_value_in));
    END;

    --------------------------------------------------------------------------------
    FUNCTION is_null(a_value_in IN VARCHAR2) RETURN BOOLEAN IS
    BEGIN
        RETURN a_value_in IS NULL;
    END;

    --------------------------------------------------------------------------------
    PROCEDURE is_null
    (
        a_value_in   IN VARCHAR2,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        this(is_null(a_value_in => a_value_in),
             NVL(a_comment_in, a_value_in || ' is expected to be null.'),
             gc_null,
             a_value_in);
    END;

    --------------------------------------------------------------------------------
    FUNCTION is_null(a_value_in IN DATE) RETURN BOOLEAN IS
    BEGIN
        RETURN a_value_in IS NULL;
    END;

    --------------------------------------------------------------------------------
    PROCEDURE is_null
    (
        a_value_in   IN DATE,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        this(is_null(a_value_in => a_value_in),
             NVL(a_comment_in, a_value_in || ' is expected to be null.'),
             gc_null,
             TO_CHAR(a_value_in, pete_config.get_date_format));
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
        a_value_in   IN NUMBER,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        this(is_not_null(a_value_in => a_value_in),
             NVL(a_comment_in, a_value_in || ' is expected to be not null.'),
             gc_not_null,
             TO_CHAR(a_value_in));
    END;

    --------------------------------------------------------------------------------
    FUNCTION is_not_null(a_value_in IN VARCHAR2) RETURN BOOLEAN IS
    BEGIN
        RETURN a_value_in IS NOT NULL;
    END;

    --------------------------------------------------------------------------------
    PROCEDURE is_not_null
    (
        a_value_in   IN VARCHAR2,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        this(is_not_null(a_value_in => a_value_in),
             NVL(a_comment_in, a_value_in || ' is expected to be not null.'),
             gc_not_null,
             a_value_in);
    END;

    --------------------------------------------------------------------------------
    FUNCTION is_not_null(a_value_in IN DATE) RETURN BOOLEAN IS
    BEGIN
        RETURN a_value_in IS NOT NULL;
    END;

    --------------------------------------------------------------------------------
    PROCEDURE is_not_null
    (
        a_value_in   IN DATE,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        this(is_not_null(a_value_in => a_value_in),
             NVL(a_comment_in, a_value_in || ' is expected to be not null.'),
             gc_not_null,
             TO_CHAR(a_value_in, pete_config.get_date_format));
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
    PROCEDURE pass(a_comment_in IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
        this(pass, NVL(a_comment_in, 'Passed!!!'), NULL, NULL);
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
    PROCEDURE fail(a_comment_in IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
        this(fail,
             NVL(a_comment_in, 'You shall not pass!!!'),
             'FAIL',
             'FAIL!!!');
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
        RETURN a_expected_in = a_actual_in OR(a_expected_in IS NULL AND
                                              a_actual_in IS NULL);
    END;

    --------------------------------------------------------------------------------
    PROCEDURE eq
    (
        a_expected_in NUMBER,
        a_actual_in   NUMBER,
        a_comment_in  VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        -- NoFormat Start
        this(a_value_in    => eq(a_expected_in => a_expected_in, a_actual_in => a_actual_in),
             a_comment_in  => NVL(a_comment_in, to_char(a_actual_in) || ' is expected to be equal to ' || to_char(a_expected_in)),
             a_expected_in => to_char(a_expected_in),
             a_actual_in   => to_char(a_actual_in));
        -- NoFormat End
    END;

    --------------------------------------------------------------------------------
    FUNCTION eq
    (
        a_expected_in VARCHAR2,
        a_actual_in   VARCHAR2
    ) RETURN BOOLEAN IS
    BEGIN
        RETURN a_expected_in = a_actual_in OR(a_expected_in IS NULL AND
                                              a_actual_in IS NULL);
    END;

    --------------------------------------------------------------------------------
    PROCEDURE eq
    (
        a_expected_in VARCHAR2,
        a_actual_in   VARCHAR2,
        a_comment_in  VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        -- TODO: to_char(date, format) - format to pete_config
        -- NoFormat Start
        this(a_value_in    => eq(a_expected_in => a_expected_in, a_actual_in => a_actual_in),
             a_comment_in  => NVL(a_comment_in, a_actual_in || ' is expected to be equal to ' || a_expected_in),
             a_expected_in => a_expected_in,
             a_actual_in   => a_actual_in);
        -- NoFormat End
    END;

    --------------------------------------------------------------------------------
    FUNCTION eq
    (
        a_expected_in DATE,
        a_actual_in   DATE
    ) RETURN BOOLEAN IS
    BEGIN
        RETURN a_expected_in = a_actual_in OR(a_expected_in IS NULL AND
                                              a_actual_in IS NULL);
    END;

    --------------------------------------------------------------------------------
    PROCEDURE eq
    (
        a_expected_in DATE,
        a_actual_in   DATE,
        a_comment_in  VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        -- TODO: to_char(date, format) - format to pete_config
        -- NoFormat Start
        this(a_value_in    => eq(a_expected_in => a_expected_in, a_actual_in => a_actual_in),
             a_comment_in  => NVL(a_comment_in, to_char(a_actual_in) || ' is expected to be equal to ' || to_char(a_expected_in)),
             a_expected_in => to_char(a_expected_in),
             a_actual_in   => to_char(a_actual_in));
        -- NoFormat End
    END;

    --------------------------------------------------------------------------------
    FUNCTION eq
    (
        a_expected_in BOOLEAN,
        a_actual_in   BOOLEAN
    ) RETURN BOOLEAN IS
    BEGIN
        RETURN a_expected_in = a_actual_in OR(a_expected_in IS NULL AND
                                              a_actual_in IS NULL);
    END;

    --------------------------------------------------------------------------------
    PROCEDURE eq
    (
        a_expected_in BOOLEAN,
        a_actual_in   BOOLEAN,
        a_comment_in  VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        -- NoFormat Start
        this(a_value_in    => eq(a_expected_in => a_expected_in, a_actual_in => a_actual_in),
             a_comment_in  => NVL(a_comment_in, bool2char(a_actual_in) || ' is expected to be equal to ' || bool2char(a_expected_in)),
             a_expected_in => bool2char(a_expected_in),
             a_actual_in   => bool2char(a_actual_in));
        -- NoFormat End
    END;

    --------------------------------------------------------------------------------
    FUNCTION eq
    (
        a_expected_in IN sys.xmltype,
        a_actual_in   IN sys.xmltype
    ) RETURN BOOLEAN IS
    BEGIN
        IF (a_expected_in IS NULL AND a_actual_in IS NOT NULL OR
           a_expected_in IS NOT NULL AND a_actual_in IS NULL)
        THEN
            RETURN FALSE;
        ELSIF (a_expected_in IS NULL AND a_actual_in IS NULL)
        THEN
            RETURN TRUE;
        ELSE
            RETURN a_expected_in.extract('/').getclobval = a_actual_in.extract('/').getclobval;
        END IF;
    END;

    --------------------------------------------------------------------------------
    PROCEDURE eq
    (
        a_expected_in IN sys.xmltype,
        a_actual_in   IN sys.xmltype,
        a_comment_in  IN VARCHAR2 DEFAULT NULL
    ) IS
        l_this BOOLEAN;
    BEGIN
        -- NoFormat Start
        l_this := eq(a_expected_in => a_expected_in, a_actual_in => a_actual_in);
        IF l_this
        THEN
            this(a_value_in   => l_this,
                 a_comment_in => 'exmpty xmlType equals empty xmlType');
        ELSE
            this(a_value_in    => l_this,
                 a_comment_in  =>  NVL(a_comment_in, a_actual_in.extract('/').getclobval || ' is expected to be equal to ' || a_expected_in.extract('/').getclobval),
                 a_expected_in => '<doesnt show actual content at the momement>',
                 a_actual_in   => '<todo>'); --todo: implement xml diff
        END IF;
        -- NoFormat End
    END;

END;
/
