CREATE OR REPLACE PACKAGE BODY pete_assert IS

    gc_null     CONSTANT VARCHAR2(4) := 'NULL';
    gc_not_null CONSTANT VARCHAR2(10) := 'NOT NULL';

    --
    -- converts a boolean value to a string representation - 'TRUE', 'FALSE', 'NULL'
    --
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
        --l_result VARCHAR2(1000);
    BEGIN
        --
        l_stack := dbms_utility.format_call_stack;
    
        -- find las occurence of lc_ASSERT_PACKAGE in stack
        l_from_pos := 1;
        WHILE instr(l_stack, lc_ASSERT_PACKAGE, l_from_pos) > 0
        LOOP
            l_from_pos := instr(l_stack, lc_ASSERT_PACKAGE, l_from_pos) +
                          length(lc_ASSERT_PACKAGE) + 1;
        END LOOP;
        --
        RETURN TRIM(substr(l_stack, l_from_pos));
        --
    END get_call_stack_before_assert;

    --
    --TODO: review: what is use for this?
    --reviewed- it was used to display package and linenumber of an assert - to locate it easily. This feature was killed during the refactoring
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
        a_object_name_out := TRIM(regexp_substr(l_stack,
                                                '([xa-f0-9]+[ ]+)([0-9]+)(.*)',
                                                1,
                                                1,
                                                'i',
                                                3));
        pete_logger.trace('a_object_name_out ' || a_object_name_out);
        a_line_number_out := to_number(regexp_substr(l_stack,
                                                     '([xa-f0-9]+[ ]+)([0-9]+)(.*)',
                                                     1,
                                                     1,
                                                     'i',
                                                     2));
        pete_logger.trace('a_line_number_out ' || a_line_number_out);
    END get_assert_caller_info;

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
        CASE a_value_in
            WHEN TRUE THEN
                pete_logger.trace('assert this - true');
                pete_logger.log_assert(a_result_in  => TRUE,
                                       a_comment_in => 'ASSERT - ' ||
                                                       a_comment_in);
            
            ELSE
                pete_logger.trace('assert this - false');
                pete_logger.log_assert(a_result_in  => FALSE,
                                       a_comment_in => 'ASSERT FAILURE - ' ||
                                                       a_comment_in);
                raise_application_error(-20000,
                                        'Assertion failed: ' || a_comment_in ||
                                        chr(10) || --
                                        'Expected:' || a_expected_in || chr(10) || --
                                        'Actual:  ' || a_actual_in);
        END CASE;
    END this;

    PROCEDURE this
    (
        a_value_in   IN BOOLEAN,
        a_comment_in IN VARCHAR2 DEFAULT NULL
        
    ) IS
    BEGIN
        this(a_value_in    => a_value_in,
             a_comment_in  => nvl(a_comment_in, 'Expected value to be true'),
             a_expected_in => 'TRUE',
             a_actual_in   => bool2char(a_value_in));
    END this;

    -- 
    -- Group of assert procedure for testing null values
    --------------------------------------------------------------------------------
    PROCEDURE is_null
    (
        a_value_in   IN NUMBER,
        a_comment_in IN VARCHAR2 DEFAULT NULL
        
    ) IS
    BEGIN
        this(a_value_in IS NULL,
             nvl(a_comment_in, a_value_in || ' is expected to be null.'),
             gc_null,
             to_char(a_value_in));
    END is_null;

    --------------------------------------------------------------------------------
    PROCEDURE is_null
    (
        a_value_in   IN VARCHAR2,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        this(a_value_in IS NULL,
             nvl(a_comment_in, a_value_in || ' is expected to be null.'),
             gc_null,
             a_value_in);
    END is_null;

    --------------------------------------------------------------------------------
    PROCEDURE is_null
    (
        a_value_in   IN DATE,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        this(a_value_in IS NULL,
             nvl(a_comment_in, a_value_in || ' is expected to be null.'),
             gc_null,
             to_char(a_value_in, pete_confgig.get_date_format));
    END is_null;

    -- 
    -- Group of assert procedure for testing null values
    --------------------------------------------------------------------------------
    PROCEDURE is_not_null
    (
        a_value_in   IN NUMBER,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        this(a_value_in IS NOT NULL,
             nvl(a_comment_in, a_value_in || ' is expected to be not null.'),
             gc_not_null,
             to_char(a_value_in));
    END is_not_null;

    --------------------------------------------------------------------------------
    PROCEDURE is_not_null
    (
        a_value_in   IN VARCHAR2,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        this(a_value_in IS NOT NULL,
             nvl(a_comment_in, a_value_in || ' is expected to be not null.'),
             gc_not_null,
             a_value_in);
    END is_not_null;

    --------------------------------------------------------------------------------
    PROCEDURE is_not_null
    (
        a_value_in   IN DATE,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        this(a_value_in IS NOT NULL,
             nvl(a_comment_in, a_value_in || ' is expected to be not null.'),
             gc_not_null,
             to_char(a_value_in, pete_confgig.get_date_format));
    END is_not_null;

    --
    -- This assert procedure always succeeds. It's usefull to log, that something has
    -- happened if it is difficult to test it's value
    --------------------------------------------------------------------------------
    PROCEDURE pass(a_comment_in IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
        this(TRUE, nvl(a_comment_in, 'You have to pass!!!'), NULL, NULL);
    END pass;

    --
    -- This assert procedure always fails. It's usefull in a branch of code where the
    -- program should never enter. E.g. in an exception block
    --------------------------------------------------------------------------------
    PROCEDURE fail(a_comment_in IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
        this(FALSE,
             nvl(a_comment_in, 'You shall not pass!!!'),
             'FAIL',
             'FAIL!!!');
    END fail;

    --
    -- Tests equality of the input arguments. Nulls are considered equal
    --------------------------------------------------------------------------------
    PROCEDURE eq
    (
        a_expected_in NUMBER,
        a_actual_in   NUMBER,
        a_comment_in  VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        this(a_expected_in = a_actual_in OR
             (a_expected_in IS NULL AND a_actual_in IS NULL),
             nvl(a_comment_in,
                 a_expected_in || ' expected to be equal to ' || a_actual_in),
             to_char(a_expected_in),
             to_char(a_actual_in));
    END eq;

    --
    -- Tests equality of the input arguments. Nulls are considered equal
    --------------------------------------------------------------------------------
    PROCEDURE eq
    (
        a_expected_in VARCHAR2,
        a_actual_in   VARCHAR2,
        a_comment_in  VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        this(a_expected_in = a_actual_in OR
             (a_expected_in IS NULL AND a_actual_in IS NULL),
             nvl(a_comment_in,
                 a_expected_in || ' expected to be equal to ' || a_actual_in),
             a_expected_in,
             a_actual_in);
    END eq;

    --
    -- Tests equality of the input arguments. Nulls are considered equal
    --------------------------------------------------------------------------------
    PROCEDURE eq
    (
        a_expected_in DATE,
        a_actual_in   DATE,
        a_comment_in  VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        this(a_expected_in = a_actual_in OR
             (a_expected_in IS NULL AND a_actual_in IS NULL),
             nvl(a_comment_in,
                 a_expected_in || ' expected to be equal to ' || a_actual_in),
             to_char(a_expected_in, pete_confgig.get_date_format),
             to_char(a_actual_in, pete_confgig.get_date_format));
    END eq;

    --------------------------------------------------------------------------------
    PROCEDURE eq
    (
        a_expected_in BOOLEAN,
        a_actual_in   BOOLEAN,
        a_comment_in  VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        this(a_expected_in = a_actual_in OR
             (a_expected_in IS NULL AND a_actual_in IS NULL),
             nvl(a_comment_in,
                 bool2char(a_expected_in) || ' expected to be equal to ' ||
                 bool2char(a_actual_in)),
             bool2char(a_expected_in),
             bool2char(a_actual_in));
    END;

    --
    -- Tests equality of the input arguments. Nulls are considered equal
    --------------------------------------------------------------------------------
    PROCEDURE eq
    (
        a_expected_in IN sys.xmltype,
        a_actual_in   IN sys.xmltype,
        a_comment_in  IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        IF (a_expected_in IS NULL AND a_actual_in IS NOT NULL OR
           a_expected_in IS NOT NULL AND a_actual_in IS NULL)
        THEN
            this(FALSE,
                 nvl(a_comment_in,
                     a_expected_in.extract('/')
                     .getclobval() || ' expected to be equal to ' || a_actual_in.extract('/')
                     .getclobval()),
                 '<doesnt show actual content at the momement>',
                 '<todo>'); --todo: implement xml diff
        ELSE
            this((a_expected_in IS NULL AND a_actual_in IS NULL) OR
                 (a_expected_in.extract('/')
                 .getclobval() = a_actual_in.extract('/').getclobval()),
                 nvl(a_comment_in,
                     a_expected_in.extract('/')
                     .getclobval() || ' expected to be equal to ' || a_actual_in.extract('/')
                     .getclobval()),
                 '<doesnt show actual content at the momement>',
                 '<todo>'); --todo: implement xml diff
        END IF;
    END eq;

END;
/
