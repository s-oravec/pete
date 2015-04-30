CREATE OR REPLACE PACKAGE petep_convention_runner AS

    --
    -- Convention over configuration runner
    --

    --
    -- Tests one package
    -- %param a_package_in package name 
    -- %param a_test_package_in if true, then methods of a_package_name_in would be run
    --                          if false, then methods of UT_ || a_package_name_in would be run
    -- %param a_method_like_in filter for methods being run - if null, all methods would be run
    --
    PROCEDURE test
    (
        a_package_name_in IN VARCHAR2,
        a_test_package_in IN BOOLEAN DEFAULT FALSE,
        a_method_like_in  IN VARCHAR2 DEFAULT NULL
    );

END;
/
