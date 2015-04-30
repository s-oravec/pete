CREATE OR REPLACE PACKAGE petep_convention_runner AS

    /**
    * Convention over configuration runner
    */

    /**
    * Tests one package
    * %param a_package_in package name 
    * %param a_test_package_in if true, then methods of a_package_name_in would be run
    *                          if false, then methods of UT_ || a_package_name_in would be run
    * %param a_method_like_in filter for methods being run - if null, all methods would be run
    */
    PROCEDURE test
    (
        a_package_in      IN VARCHAR2,
        a_test_package_in BOOLEAN DEFAULT FALSE,
        a_method_like_in  IN VARCHAR2 DEFAULT NULL
    );

/*    \**
    * API used to set execution result - for pete framework testing
    *\
    PROCEDURE set_test_result(a_value_in BOOLEAN);

    \**
    * wrapper for trace logs
    *\
    PROCEDURE trace(a_co_in VARCHAR2);

    \**
    * set trace log output
    *\
    PROCEDURE set_trace(a_value_in IN BOOLEAN);

    PROCEDURE resolve_assert
    (
        a_value_in   BOOLEAN,
        a_comment_in VARCHAR2
    );
*/

END;
/
