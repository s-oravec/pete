CREATE OR REPLACE PACKAGE petep_assert AS

    /**
    * Pete assert package
    */

    /**
    * Basic assert procedure. Every other procedure transform it's parameters and calls this one
    * %param a_value_in value, that is expected to be true
    * %param a_comment_in comment in case of failing assert
    */
    PROCEDURE this
    (
        a_value_in   IN BOOLEAN,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    );

    /** 
    * Group of assert procedure for testing null values
    */
    PROCEDURE is_null
    (
        a_value_in   IN NUMBER,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    );
    PROCEDURE is_null
    (
        a_value_in   IN VARCHAR2,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    );
    PROCEDURE is_null
    (
        a_value_in   IN DATE,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    );

    /** 
    * Group of assert procedure for testing null values
    */
    PROCEDURE is_not_null
    (
        a_value_in   IN NUMBER,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    );
    PROCEDURE is_not_null
    (
        a_value_in   IN VARCHAR2,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    );
    PROCEDURE is_not_null
    (
        a_value_in   IN DATE,
        a_comment_in IN VARCHAR2 DEFAULT NULL
    );

    /**
    * This assert procedure always succeeds. It's usefull to log, that something has
    * happened if it is difficult to test it's value
    */
    PROCEDURE pass(a_comment_in IN VARCHAR2);

    /**
    * This assert procedure always fails. It's usefull in a branch of code where the
    * program should never enter. E.g. in an exception block
    */
    PROCEDURE fail(a_comment_in IN VARCHAR2 DEFAULT NULL);

    /**
    * Tests equality of the inpurt parameters. Nulls are considered equal
    */
    PROCEDURE eq
    (
        a_expected_in NUMBER,
        a_actual_in   NUMBER,
        a_comment_in  VARCHAR2 DEFAULT NULL
    );

    /**
    * Tests equality of the inpurt parameters. Nulls are considered equal
    */
    PROCEDURE eq
    (
        a_expected_in VARCHAR2,
        a_actual_in   VARCHAR2,
        a_comment_in  VARCHAR2 DEFAULT NULL
    );

    /**
    * Tests equality of the inpurt parameters. Nulls are considered equal
    */
    PROCEDURE eq
    (
        a_expected_in DATE,
        a_actual_in   DATE,
        a_comment_in  VARCHAR2 DEFAULT NULL
    );

    /**
    * Tests equality of the inpurt parameters. Nulls are considered equal
    */
    PROCEDURE eq
    (
        a_expected_in sys.xmltype,
        a_actual_in   sys.xmltype,
        a_comment_in  VARCHAR2 DEFAULT NULL
    );

END petep_assert;
/
