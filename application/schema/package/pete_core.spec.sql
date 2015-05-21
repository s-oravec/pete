CREATE OR REPLACE PACKAGE pete_core AS

    -- testing context subtype
    SUBTYPE typ_object_type IS pete_run_log.object_type%TYPE;
    -- testing context constants
    g_OBJECT_TYPE_PETE    CONSTANT typ_object_type := 'PETE';
    g_OBJECT_TYPE_SUITE   CONSTANT typ_object_type := 'SUITE';
    g_OBJECT_TYPE_SCRIPT  CONSTANT typ_object_type := 'SCRIPT';
    g_OBJECT_TYPE_CASE    CONSTANT typ_object_type := 'CASE';
    g_OBJECT_TYPE_BLOCK   CONSTANT typ_object_type := 'BLOCK';
    g_OBJECT_TYPE_SCHEMA  CONSTANT typ_object_type := 'SCHEMA';
    g_OBJECT_TYPE_PACKAGE CONSTANT typ_object_type := 'PACKAGE';
    g_OBJECT_TYPE_METHOD  CONSTANT typ_object_type := 'METHOD';
    g_OBJECT_TYPE_ASSERT  CONSTANT typ_object_type := 'ASSERT';
    g_OBJECT_TYPE_HOOK    CONSTANT typ_object_type := 'HOOK';

    -- execution result subtype
    SUBTYPE typ_execution_result IS pete_run_log.result%TYPE;
    -- execution result constants
    g_SUCCESS CONSTANT typ_execution_result := 'SUCCESS';
    g_FAILURE CONSTANT typ_execution_result := 'FAILURE';

    SUBTYPE typ_is_success IS BOOLEAN;

    -- object name
    SUBTYPE typ_object_name IS pete_run_log.object_name%TYPE;

    -- description subtype
    SUBTYPE typ_description IS VARCHAR2(4000);

    FUNCTION begin_test
    (
        a_object_name_in       IN typ_object_name,
        a_object_type_in       IN typ_object_type,
        a_parent_run_log_id_in IN pete_run_log.parent_id%TYPE DEFAULT NULL,
        a_description_in       IN typ_description DEFAULT NULL
    ) RETURN pete_run_log.id%TYPE;

    PROCEDURE end_test
    (
        a_run_log_id_in    IN pete_run_log.id%TYPE,
        a_is_succes_in     IN typ_is_success DEFAULT TRUE,
        a_xml_in_in        IN pete_run_log.xml_in%TYPE DEFAULT NULL,
        a_xml_out_in       IN pete_run_log.xml_out%TYPE DEFAULT NULL,
        a_error_code_in    IN pete_run_log.error_code%TYPE DEFAULT NULL
    );

    FUNCTION get_last_run_log_id RETURN pete_run_log.id%TYPE;

END;
/
