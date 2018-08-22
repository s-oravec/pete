create or replace package pete_core as

    --
    -- Pete core package
    -- Constants, types and core methods
    --

    -- testing object type constants
    -- top level object
    g_OBJECT_TYPE_PETE constant pete_types.typ_object_type := 'PETE';
    -- test suite
    g_OBJECT_TYPE_SUITE constant pete_types.typ_object_type := 'SUITE';
    -- test case
    g_OBJECT_TYPE_CASE constant pete_types.typ_object_type := 'CASE';
    -- PL/SQL block
    g_OBJECT_TYPE_BLOCK constant pete_types.typ_object_type := 'BLOCK';
    -- PL/SQL package
    g_OBJECT_TYPE_PACKAGE constant pete_types.typ_object_type := 'PACKAGE';
    -- PL/SQL pacakge method
    g_OBJECT_TYPE_METHOD constant pete_types.typ_object_type := 'METHOD';
    -- Assert
    g_OBJECT_TYPE_ASSERT constant pete_types.typ_object_type := 'ASSERT';
    -- PL/SQL package hook method
    g_OBJECT_TYPE_HOOK constant pete_types.typ_object_type := 'HOOK';

    -- execution result constants
    g_SUCCESS constant pete_types.typ_execution_result := 0;
    g_FAILURE constant pete_types.typ_execution_result := 1;

    -- yes/no constants
    g_YES constant pete_types.typ_YES_NO := 'Y';
    g_NO  constant pete_types.typ_YES_NO := 'N';

    -- run modifier constants
    g_SKIP constant pete_types.typ_run_modifier := 'SKIP';
    g_ONLY constant pete_types.typ_run_modifier := 'ONLY';

    --
    -- Order constants
    -- Order first
    --g_ORDER_FIRST CONSTANT pete_plsql_block_in_case.position%Type := -1;
    --
    -- Order last
    --g_ORDER_LAST CONSTANT pete_plsql_block_in_case.position%Type := -2;

    --
    -- Core begin test implementation
    -- creates record for test run
    -- sets last run_log_id
    --
    -- %param a_object_name_in object name
    -- %param a_object_type_in object type
    -- %param a_parent_run_log_id_in parent PETE_RUN_LOG.ID
    -- %param a_description_in description
    --
    -- %return pete_run_log.id of new record in PETE_RUN_LOG table
    --
    function begin_test
    (
        a_object_name_in       in pete_types.typ_object_name,
        a_object_type_in       in pete_types.typ_object_type,
        a_parent_run_log_id_in in pete_run_log.parent_id%type default null,
        a_description_in       in pete_types.typ_description default null
    ) return pete_run_log.id%type;

    --
    -- Core end test implementation
    -- updates record for test run with result and detailed info
    -- clears last run_log_id
    --
    -- %param a_run_log_id_in id of current run log
    -- %param a_is_succes_in is result success?
    -- %param a_xml_in_in XML passed into PL/SQL block as input argument
    -- %param a_xml_out_in XML returned from PL/SQL block as output argument
    -- %param a_error_code_in error code
    --
    procedure end_test
    (
        a_run_log_id_in       in pete_run_log.id%type,
        a_execution_result_in in pete_types.typ_execution_result default g_SUCCESS,
        a_error_code_in       in pete_run_log.error_code%type default null
    );

    --
    -- Get last created run_log_id
    -- used in testing of Pete to get last generated run_log_id
    -- TODO: could be switched to petes_run_log.currval?
    --
    -- %return last PETE_RUN_LOG.ID
    --
    function get_last_run_log_id return pete_run_log.id%type;

end;
/
