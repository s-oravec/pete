CREATE OR REPLACE PACKAGE BODY pete_assert IS

    --
    -- parse formated call stack and get stack before call of assert package
    --------------------------------------------------------------------------------  
    FUNCTION get_call_stack_before_assert RETURN VARCHAR2 IS
        l_stack    VARCHAR2(1000);
        l_from_pos NUMBER;
        --TODO: use precompiler directives here to get package name or set as literal during installation      
        lc_ASSERT_PACKAGE CONSTANT VARCHAR2(30) := USER || '.pete_ASSERT';
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
    -- TODO: review: what is use for this?
    --------------------------------------------------------------------------------
    PROCEDURE get_assert_caller_info
    (
        a_object_name_out OUT VARCHAR2,
        a_line_number_out OUT NUMBER
    ) IS
        l_stack VARCHAR2(1000);
    BEGIN
        l_stack           := get_call_stack_before_assert;
        a_object_name_out := TRIM(regexp_substr(l_stack,
                                                '([xa-f0-9]+[ ]+)([0-9]+)(.*)',
                                                1,
                                                1,
                                                'i',
                                                3));
        a_line_number_out := to_number(regexp_substr(l_stack,
                                                     '([xa-f0-9]+[ ]+)([0-9]+)(.*)',
                                                     1,
                                                     1,
                                                     'i',
                                                     2));
    END get_assert_caller_info;

    --------------------------------------------------------------------------------
    PROCEDURE this
    (
        a_value_in   IN BOOLEAN,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        CASE a_value_in
            WHEN TRUE THEN
                NULL;
            ELSE
                raise_application_error(-20000,
                                        'Assertion failed: ' ||
                                        nvl(a_comment_in,
                                            'Value expected to be true'));
        END CASE;
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
             nvl(a_comment_in, a_value_in || ' is expected to be null.'));
    END is_null;

    --------------------------------------------------------------------------------
    PROCEDURE is_null
    (
        a_value_in   IN VARCHAR2,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        this(a_value_in IS NULL,
             nvl(a_comment_in, a_value_in || ' is expected to be null.'));
    END is_null;

    --------------------------------------------------------------------------------
    PROCEDURE is_null
    (
        a_value_in   IN DATE,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        this(a_value_in IS NULL,
             nvl(a_comment_in, a_value_in || ' is expected to be null.'));
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
             nvl(a_comment_in, a_value_in || ' is expected to be not null.'));
    END is_not_null;

    --------------------------------------------------------------------------------
    PROCEDURE is_not_null
    (
        a_value_in   IN VARCHAR2,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        this(a_value_in IS NOT NULL,
             nvl(a_comment_in, a_value_in || ' is expected to be not null.'));
    END is_not_null;

    --------------------------------------------------------------------------------
    PROCEDURE is_not_null
    (
        a_value_in   IN DATE,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        this(a_value_in IS NOT NULL,
             nvl(a_comment_in, a_value_in || ' is expected to be not null.'));
    END is_not_null;

    --
    -- This assert procedure always succeeds. It's usefull to log, that something has
    -- happened if it is difficult to test it's value
    --------------------------------------------------------------------------------
    PROCEDURE pass(a_comment_in IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
        this(TRUE, nvl(a_comment_in, 'You have to pass!!!'));
    END pass;

    --
    -- This assert procedure always fails. It's usefull in a branch of code where the
    -- program should never enter. E.g. in an exception block
    --------------------------------------------------------------------------------
    PROCEDURE fail(a_comment_in IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
        this(FALSE, nvl(a_comment_in, 'You shall not pass!!!'));
    END fail;

    --
    -- Tests equality of the inpurt parameters. Nulls are considered equal
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
                 a_expected_in || ' expected to be equal to ' || a_actual_in));
    END eq;

    --
    -- Tests equality of the inpurt parameters. Nulls are considered equal
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
                 a_expected_in || ' expected to be equal to ' || a_actual_in));
    END eq;

    --
    -- Tests equality of the inpurt parameters. Nulls are considered equal
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
                 a_expected_in || ' expected to be equal to ' || a_actual_in));
    END eq;

    --
    -- Tests equality of the inpurt parameters. Nulls are considered equal
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
                     .getclobval()));
        ELSE
            this((a_expected_in IS NULL AND a_actual_in IS NULL) OR
                 (a_expected_in.extract('/')
                 .getclobval() = a_actual_in.extract('/').getclobval()),
                 nvl(a_comment_in,
                     a_expected_in.extract('/')
                     .getclobval() || ' expected to be equal to ' || a_actual_in.extract('/')
                     .getclobval()));
        END IF;
    END eq;

END;
/
