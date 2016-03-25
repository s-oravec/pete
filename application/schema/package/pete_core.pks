CREATE OR REPLACE PACKAGE pete_core AS

    --
    -- Pete core package
    -- Constants, types and core methods
    --

    -- testing object type constants
    -- top level object
    g_OBJECT_TYPE_PETE CONSTANT pete_types.typ_object_type := 'PETE';
    -- test suite
    g_OBJECT_TYPE_SUITE CONSTANT pete_types.typ_object_type := 'SUITE';
    -- test case
    g_OBJECT_TYPE_CASE CONSTANT pete_types.typ_object_type := 'CASE';
    -- PL/SQL block
    g_OBJECT_TYPE_BLOCK CONSTANT pete_types.typ_object_type := 'BLOCK';
    -- PL/SQL package
    g_OBJECT_TYPE_PACKAGE CONSTANT pete_types.typ_object_type := 'PACKAGE';
    -- PL/SQL pacakge method
    g_OBJECT_TYPE_METHOD CONSTANT pete_types.typ_object_type := 'METHOD';
    -- Assert
    g_OBJECT_TYPE_ASSERT CONSTANT pete_types.typ_object_type := 'ASSERT';
    -- PL/SQL package hook method
    g_OBJECT_TYPE_HOOK CONSTANT pete_types.typ_object_type := 'HOOK';

    -- execution result constants
    g_SUCCESS CONSTANT pete_types.typ_execution_result := 0;
    g_FAILURE CONSTANT pete_types.typ_execution_result := 1;

    -- yes/no constants
    g_YES CONSTANT pete_types.typ_YES_NO := 'Y';
    g_NO  CONSTANT pete_types.typ_YES_NO := 'N';

    -- run modifier constants
    g_SKIP CONSTANT pete_types.typ_run_modifier := 'SKIP';
    g_ONLY CONSTANT pete_types.typ_run_modifier := 'ONLY';

    --
    -- Order constants
    -- Order first
    g_ORDER_FIRST CONSTANT pete_plsql_block_in_case.position%Type := -1;
    --
    -- Order last
    g_ORDER_LAST CONSTANT pete_plsql_block_in_case.position%Type := -2;

    --
    -- Core begin test implementation
    -- creates record for test run
    -- sets last run_log_id
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
        a_object_name_in       IN pete_types.typ_object_name,
        a_object_type_in       IN pete_types.typ_object_type,
        a_parent_run_log_id_in IN pete_run_log.parent_id%Type DEFAULT NULL,
        a_description_in       IN pete_types.typ_description DEFAULT NULL
    ) RETURN pete_run_log.id%Type;

    --
    -- Core end test implementation
    -- updates record for test run with result and detailed info
    -- clears last run_log_id
    --
    -- %argument a_run_log_id_in id of current run log
    -- %argument a_is_succes_in is result success?
    -- %argument a_xml_in_in XML passed into PL/SQL block as input argument
    -- %argument a_xml_out_in XML returned from PL/SQL block as output argument
    -- %argument a_error_code_in error code
    --
    PROCEDURE end_test
    (
        a_run_log_id_in       IN pete_run_log.id%Type,
        a_execution_result_in IN pete_types.typ_execution_result DEFAULT g_SUCCESS,
        a_xml_in_in           IN pete_run_log.xml_in%Type DEFAULT NULL,
        a_xml_out_in          IN pete_run_log.xml_out%Type DEFAULT NULL,
        a_error_code_in       IN pete_run_log.error_code%Type DEFAULT NULL
    );

    --
    -- Get last created run_log_id
    -- used in testing of Pete to get last generated run_log_id
    -- TODO: could be switched to petes_run_log.currval?
    --
    -- %return last PETE_RUN_LOG.ID
    --
    FUNCTION get_last_run_log_id RETURN pete_run_log.id%Type;

END;
/
