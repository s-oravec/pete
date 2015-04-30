CREATE OR REPLACE PACKAGE petep_convention_runner AS

    --
    -- Convention over configuration runner
    --

    --
    -- Tests one package
    -- %param a_package_in package name 
    -- %param a_method_like_in filter for methods being run - if null, all methods would be run
    --
    PROCEDURE run_package
    (
        a_package_name_in     IN VARCHAR2,
        a_method_name_like_in IN VARCHAR2 DEFAULT NULL
    );

    --
    -- Tests suite
    -- %param a_suite_name test suite name = USER
    PROCEDURE run_suite(a_suite_name_in IN VARCHAR2);

END;
/
