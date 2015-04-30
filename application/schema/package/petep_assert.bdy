CREATE OR REPLACE PACKAGE BODY petep_assert IS

    --------------------------------------------------------------------------------
    PROCEDURE this
    (
        a_value_in   IN BOOLEAN,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
    
        petep_logger.log_assert(a_result_in      => CASE a_value_in
                                                        WHEN TRUE THEN
                                                         petep_logger.gc_SUCCESS
                                                        ELSE
                                                         petep_logger.gc_FAILURE
                                                    END,
                                a_description_in => a_comment_in);
    END this;

    /** 
    * Group of assert procedure for testing null values
    */
    --------------------------------------------------------------------------------
    PROCEDURE is_null
    (
        a_value_in   IN NUMBER,
        a_comment_in IN VARCHAR2 DEFAULT NULL
        
    ) IS
    BEGIN
        this(a_value_in IS NULL, a_comment_in);
    END is_null;

    --------------------------------------------------------------------------------
    PROCEDURE is_null
    (
        a_value_in   IN VARCHAR2,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        this(a_value_in IS NULL, a_comment_in);
    END is_null;

    --------------------------------------------------------------------------------
    PROCEDURE is_null
    (
        a_value_in   IN DATE,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        this(a_value_in IS NULL, a_comment_in);
    END is_null;

    /** 
    * Group of assert procedure for testing null values
    */
    --------------------------------------------------------------------------------
    PROCEDURE is_not_null
    (
        a_value_in   IN NUMBER,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        this(a_value_in IS NOT NULL, a_comment_in);
    END is_not_null;

    --------------------------------------------------------------------------------
    PROCEDURE is_not_null
    (
        a_value_in   IN VARCHAR2,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        this(a_value_in IS NOT NULL, a_comment_in);
    END is_not_null;

    --------------------------------------------------------------------------------
    PROCEDURE is_not_null
    (
        a_value_in   IN DATE,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        this(a_value_in IS NOT NULL, a_comment_in);
    END is_not_null;

    /**
    * This assert procedure always succeeds. It's usefull to log, that something has
    * happened if it is difficult to test it's value
    */
    --------------------------------------------------------------------------------
    PROCEDURE pass(a_comment_in IN VARCHAR2) IS
    BEGIN
        this(TRUE, a_comment_in);
    END pass;

    /**
    * This assert procedure always fails. It's usefull in a branch of code where the
    * program should never enter. E.g. in an exception block
    */
    --------------------------------------------------------------------------------
    PROCEDURE fail(a_comment_in IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
        this(FALSE, a_comment_in);
    END fail;

    /**
    * Tests equality of the inpurt parameters. Nulls are considered equal
    */
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
             a_comment_in);
    END eq;

    /**
    * Tests equality of the inpurt parameters. Nulls are considered equal
    */
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
             a_comment_in);
    END eq;

    /**
    * Tests equality of the inpurt parameters. Nulls are considered equal
    */
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
             a_comment_in);
    END eq;

    /**
    * Tests equality of the inpurt parameters. Nulls are considered equal
    */
    --------------------------------------------------------------------------------
    PROCEDURE eq
    (
        a_expected_in sys.xmltype,
        a_actual_in   sys.xmltype,
        a_comment_in  VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        IF (a_expected_in IS NULL AND a_actual_in IS NOT NULL OR
           a_expected_in IS NOT NULL AND a_actual_in IS NULL)
        THEN
            this(FALSE, a_comment_in);
        
        ELSE
        
            this((a_expected_in IS NULL AND a_actual_in IS NULL) OR
                 (a_expected_in.extract('/')
                 .getclobval() = a_actual_in.extract('/').getclobval()),
                 a_comment_in);
        END IF;
    END eq;

END;
/
