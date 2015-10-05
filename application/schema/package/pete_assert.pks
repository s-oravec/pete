CREATE OR REPLACE PACKAGE pete_assert AS

    --
    -- Pete assert package
    --

    --
    -- Basic assert procedure. Every other procedure transforms it's arguments and calls this one
    --
    -- %argument a_value_in value, that is expected to be true
    -- %argument a_comment_in comment in case of failing assert
    --
    PROCEDURE this
    (
        a_value_in   IN BOOLEAN,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    );

    -- 
    -- Group of assert procedure for testing null values
    --
    PROCEDURE is_null
    (
        a_value_in   IN NUMBER,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    );

    FUNCTION is_null(a_value_in IN NUMBER) RETURN BOOLEAN;

    PROCEDURE is_null
    (
        a_value_in   IN VARCHAR2,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    );

    FUNCTION is_null(a_value_in IN VARCHAR2) RETURN BOOLEAN;

    PROCEDURE is_null
    (
        a_value_in   IN DATE,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    );

    FUNCTION is_null(a_value_in IN DATE) RETURN BOOLEAN;

    -- 
    -- Group of assert procedure for testing null values
    --
    PROCEDURE is_not_null
    (
        a_value_in   IN NUMBER,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    );

    FUNCTION is_not_null(a_value_in IN NUMBER) RETURN BOOLEAN;

    PROCEDURE is_not_null
    (
        a_value_in   IN VARCHAR2,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    );

    FUNCTION is_not_null(a_value_in IN VARCHAR2) RETURN BOOLEAN;

    PROCEDURE is_not_null
    (
        a_value_in   IN DATE,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    );

    FUNCTION is_not_null(a_value_in IN DATE) RETURN BOOLEAN;

    --
    -- This assert procedure always succeeds. It's usefull to log, that something has
    -- happened if it is difficult to test it's value
    --
    PROCEDURE pass(a_comment_in IN VARCHAR2 DEFAULT NULL);

    FUNCTION pass RETURN BOOLEAN;

    --
    -- This assert procedure always fails. It's usefull in a branch of code where the
    -- program should never enter. E.g. in an exception block
    --
    PROCEDURE fail(a_comment_in IN VARCHAR2 DEFAULT NULL);

    FUNCTION fail RETURN BOOLEAN;

    --
    -- Group of assert procedures for testing equality of input arguments
    -- Nulls are considered equal
    --
    PROCEDURE eq
    (
        a_expected_in IN NUMBER,
        a_actual_in   IN NUMBER,
        a_comment_in  IN VARCHAR2 DEFAULT NULL
    );

    FUNCTION eq
    (
        a_expected_in IN NUMBER,
        a_actual_in   IN NUMBER
    ) RETURN BOOLEAN;

    PROCEDURE eq
    (
        a_expected_in IN VARCHAR2,
        a_actual_in   IN VARCHAR2,
        a_comment_in  IN VARCHAR2 DEFAULT NULL
    );

    FUNCTION eq
    (
        a_expected_in IN VARCHAR2,
        a_actual_in   IN VARCHAR2
    ) RETURN BOOLEAN;

    PROCEDURE eq
    (
        a_expected_in IN DATE,
        a_actual_in   IN DATE,
        a_comment_in  IN VARCHAR2 DEFAULT NULL
    );

    FUNCTION eq
    (
        a_expected_in IN DATE,
        a_actual_in   IN DATE
    ) RETURN BOOLEAN;

    PROCEDURE eq
    (
        a_expected_in IN BOOLEAN,
        a_actual_in   IN BOOLEAN,
        a_comment_in  IN VARCHAR2 DEFAULT NULL
    );

    FUNCTION eq
    (
        a_expected_in IN BOOLEAN,
        a_actual_in   IN BOOLEAN
    ) RETURN BOOLEAN;

    PROCEDURE eq
    (
        a_expected_in IN sys.xmltype,
        a_actual_in   IN sys.xmltype,
        a_comment_in  IN VARCHAR2 DEFAULT NULL
    );

    FUNCTION eq
    (
        a_expected_in IN sys.xmltype,
        a_actual_in   IN sys.xmltype
    ) RETURN BOOLEAN;

END pete_assert;
/
