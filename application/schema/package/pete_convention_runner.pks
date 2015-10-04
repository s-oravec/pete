CREATE OR REPLACE PACKAGE pete_convention_runner AS

    --
    -- Convention over Configuration test runner
    -- do not call these methods directly - use Pete package instead
    --

    --
    -- Tests suite
    -- runs all UT% packages defined in user's schema
    --
    -- %argument a_suite_name_in test suite name = USER
    -- %argument a_description_in test suite description
    -- %argument a_parent_run_log_id_in Specify parent run_log_id for recursive execution - used for testing of Pete
    --
    -- %return true - success, false - failure
    --
    FUNCTION run_suite
    (
        a_suite_name_in        IN pete_core.typ_object_name DEFAULT USER,
        a_description_in       IN pete_core.typ_description DEFAULT NULL,
        a_parent_run_log_id_in IN pete_run_log.parent_id%TYPE DEFAULT NULL
    ) RETURN pete_core.typ_execution_result;

    --
    -- Tests one package
    --
    -- %argument a_package_in package name 
    -- %argument a_method_like_in filter for methods being run - if null, all methods would be run
    -- %argument a_description_in test suite description
    -- %argument a_parent_run_log_id_in Specify parent run_log_id for recursive execution - used for testing of Pete
    --
    -- %return true - success, false - failure
    --
    FUNCTION run_package
    (
        a_package_name_in      IN pete_core.typ_object_name,
        a_method_name_like_in  IN pete_core.typ_object_name DEFAULT NULL,
        a_description_in       IN pete_core.typ_description DEFAULT NULL,
        a_parent_run_log_id_in IN pete_run_log.parent_id%TYPE DEFAULT NULL
    ) RETURN pete_core.typ_execution_result;

    --
    -- Tests one method
    --
    -- %argument a_package_in package name 
    -- %argument a_method_name_in method name
    -- %argument a_object_type_in method type (METHOD|HOOK)
    -- %argument a_description_in test suite description
    -- %argument a_parent_run_log_id_in Specify parent run_log_id for recursive execution - used for testing of Pete
    --
    -- %return true - success, false - failure
    --
    FUNCTION run_method
    (
        a_package_name_in      IN pete_core.typ_object_name,
        a_method_name_in       IN pete_core.typ_object_name,
        a_object_type_in       IN pete_core.typ_object_type,
        a_description_in       IN pete_core.typ_description DEFAULT NULL,
        a_parent_run_log_id_in IN pete_run_log.parent_id%TYPE DEFAULT NULL
    ) RETURN pete_core.typ_execution_result;

END;
/
