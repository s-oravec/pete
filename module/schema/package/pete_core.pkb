CREATE OR REPLACE PACKAGE BODY pete_core AS

    g_last_run_log_id pete_run_log.id%Type;

    --------------------------------------------------------------------------------
    FUNCTION begin_test
    (
        a_object_name_in       IN pete_types.typ_object_name,
        a_object_type_in       IN pete_types.typ_object_type,
        a_parent_run_log_id_in IN pete_run_log.parent_id%Type DEFAULT NULL,
        a_description_in       IN pete_types.typ_description DEFAULT NULL
    ) RETURN pete_run_log.id%Type IS
    
    BEGIN
        --
        g_last_run_log_id := petes_run_log.nextval;
        --
        --
        pete_logger.log_start(a_run_log_id_in        => g_last_run_log_id,
                              a_parent_run_log_id_in => a_parent_run_log_id_in,
                              a_description_in       => CASE
                                                            WHEN a_object_type_in = pete_core.g_OBJECT_TYPE_PETE AND a_description_in IS NOT NULL THEN
                                                             'Pete run "' || a_description_in || '" id=' || g_last_run_log_id || ' @ ' ||
                                                             to_char(systimestamp)
                                                            WHEN a_object_type_in = pete_core.g_OBJECT_TYPE_PETE AND a_description_in IS NULL THEN
                                                             'Pete run id=' || g_last_run_log_id || ' @ ' || to_char(systimestamp)
                                                            ELSE
                                                             a_description_in
                                                        END,
                              a_object_type_in       => a_object_type_in,
                              a_object_name_in       => a_object_name_in);
        --
        RETURN g_last_run_log_id;
        --
    END;

    --------------------------------------------------------------------------------
    FUNCTION get_last_run_log_id RETURN pete_run_log.id%Type IS
    BEGIN
        RETURN g_last_run_log_id;
    END;

    --------------------------------------------------------------------------------
    PROCEDURE end_test
    (
        a_run_log_id_in       IN pete_run_log.id%Type,
        a_execution_result_in IN pete_types.typ_execution_result DEFAULT g_SUCCESS,
        a_xml_in_in           IN pete_run_log.xml_in%Type DEFAULT NULL,
        a_xml_out_in          IN pete_run_log.xml_out%Type DEFAULT NULL,
        a_error_code_in       IN pete_run_log.error_code%Type DEFAULT NULL
    ) IS
    BEGIN
        --
        pete_logger.log_end(a_run_log_id_in      => a_run_log_id_in,
                            a_result_in          => a_execution_result_in,
                            a_xml_in_in          => a_xml_in_in,
                            a_xml_out_in         => a_xml_out_in,
                            a_error_code_in      => a_error_code_in,
                            a_error_stack_in     => CASE
                                                        WHEN NOT a_execution_result_in = g_SUCCESS THEN
                                                         dbms_utility.format_error_stack
                                                        ELSE
                                                         NULL
                                                    END,
                            a_error_backtrace_in => CASE
                                                        WHEN NOT a_execution_result_in = g_SUCCESS THEN
                                                         dbms_utility.format_error_backtrace
                                                        ELSE
                                                         NULL
                                                    END);
        g_last_run_log_id := NULL;
    END;

END;
/
