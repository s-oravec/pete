CREATE OR REPLACE PACKAGE pete_core AS

    --
    -- Pete core package
    -- Constants, types and core methods
    --

    -- testing object type subtype
    SUBTYPE typ_object_type IS pete_run_log.object_type%TYPE;
    -- testing object type constants
    -- top level object
    g_OBJECT_TYPE_PETE CONSTANT typ_object_type := 'PETE';
    -- test suite
    g_OBJECT_TYPE_SUITE CONSTANT typ_object_type := 'SUITE';
    -- test case
    g_OBJECT_TYPE_CASE CONSTANT typ_object_type := 'CASE';
    -- PL/SQL block
    g_OBJECT_TYPE_BLOCK CONSTANT typ_object_type := 'BLOCK';
    -- PL/SQL package
    g_OBJECT_TYPE_PACKAGE CONSTANT typ_object_type := 'PACKAGE';
    -- PL/SQL pacakge method
    g_OBJECT_TYPE_METHOD CONSTANT typ_object_type := 'METHOD';
    -- Assert
    g_OBJECT_TYPE_ASSERT CONSTANT typ_object_type := 'ASSERT';
    -- PL/SQL package hook method
    g_OBJECT_TYPE_HOOK CONSTANT typ_object_type := 'HOOK';

    -- execution result subtype
    SUBTYPE typ_execution_result IS PLS_INTEGER;
    g_SUCCESS CONSTANT typ_execution_result := 0;
    g_FAILURE CONSTANT typ_execution_result := 1;

    -- object name
    SUBTYPE typ_object_name IS pete_run_log.object_name%TYPE;

    -- description subtype
    SUBTYPE typ_description IS VARCHAR2(4000);

    --
    -- Core begin test implementation
    -- creates record for test run
    --
    -- %argument a_object_name_in object name
    -- %argument a_object_type_in object type
    -- %argument a_parent_run_log_id_in parent PETE_RUN_LOG.ID
    -- %argument a_description_in description
    --
    -- %return pete_run_log.id of new record in PETE_RUN_LOG table
    --
    FUNCTION begin_test
    (
        a_object_name_in       IN typ_object_name,
        a_object_type_in       IN typ_object_type,
        a_parent_run_log_id_in IN pete_run_log.parent_id%TYPE DEFAULT NULL,
        a_description_in       IN typ_description DEFAULT NULL
    ) RETURN pete_run_log.id%TYPE;

    --
    -- Core end test implementation
    -- updates record for test run with result and detailed info
    --
    -- %argument a_run_log_id_in id of current run log
    -- %argument a_is_succes_in is result success?
    -- %argument a_xml_in_in XML passed into PL/SQL block as input argument
    -- %argument a_xml_out_in XML returned from PL/SQL block as output argument
    -- %argument a_error_code_in error code
    --
    PROCEDURE end_test
    (
        a_run_log_id_in       IN pete_run_log.id%TYPE,
        a_execution_result_in IN typ_execution_result DEFAULT g_SUCCESS,
        a_xml_in_in           IN pete_run_log.xml_in%TYPE DEFAULT NULL,
        a_xml_out_in          IN pete_run_log.xml_out%TYPE DEFAULT NULL,
        a_error_code_in       IN pete_run_log.error_code%TYPE DEFAULT NULL
    );

    --
    -- Get last created run_log_id
    -- used in testing of Pete to get last generated run_log_id
    -- TODO: could be switched to petes_run_log.currval?
    --
    -- %return last PETE_RUN_LOG.ID
    --
    FUNCTION get_last_run_log_id RETURN pete_run_log.id%TYPE;

END;
/
