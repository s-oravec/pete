CREATE OR REPLACE PACKAGE BODY pete_core AS

    --------------------------------------------------------------------------------
    FUNCTION begin_test
    (
        a_object_name_in       IN typ_object_name,
        a_object_type_in       IN typ_object_type,
        a_parent_run_log_id_in IN pete_run_log.parent_id%TYPE DEFAULT NULL,
        a_description_in       IN typ_description DEFAULT NULL
    ) RETURN pete_run_log.id%TYPE IS
        l_run_log_id pete_run_log.id%TYPE := petes_run_log.nextval;
    BEGIN
        --
        pete_logger.log_start(a_run_log_id_in        => l_run_log_id,
                              a_parent_run_log_id_in => a_parent_run_log_id_in,
                              a_description_in       => a_description_in,
                              a_object_type_in       => a_object_type_in,
                              a_object_name_in       => a_object_name_in);
        --
        RETURN l_run_log_id;
        --
    END;

    --------------------------------------------------------------------------------
    PROCEDURE end_test
    (
        a_run_log_id_in    IN pete_run_log.id%TYPE,
        a_is_succes_in     IN typ_is_success DEFAULT TRUE,
        a_error_code_in    IN pete_run_log.error_code%TYPE DEFAULT NULL,
        a_error_message_in IN pete_run_log.error_message%TYPE DEFAULT NULL
    ) IS
    BEGIN
        --
        pete_logger.log_end(a_run_log_id_in    => a_run_log_id_in,
                            a_result_in        => CASE
                                                      WHEN a_is_succes_in THEN
                                                       pete_core.g_SUCCESS
                                                      ELSE
                                                       pete_core.g_FAILURE
                                                  END,
                            a_error_code_in    => a_error_code_in,
                            a_error_message_in => a_error_message_in);
    END;

END;
/
