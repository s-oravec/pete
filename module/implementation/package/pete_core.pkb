create or replace package body pete_core as

    g_last_run_log_id pete_run_log.id%type;

    --------------------------------------------------------------------------------
    function begin_test
    (
        a_object_name_in       in pete_types.typ_object_name,
        a_object_type_in       in pete_types.typ_object_type,
        a_parent_run_log_id_in in pete_run_log.parent_id%type default null,
        a_description_in       in pete_types.typ_description default null
    ) return pete_run_log.id%type is
    
    begin
        --
        g_last_run_log_id := pete_run_log_seq.nextval;
        --
        --
        pete_logger.log_start(a_run_log_id_in        => g_last_run_log_id,
                              a_parent_run_log_id_in => a_parent_run_log_id_in,
                              a_description_in       => case
                                                            when a_object_type_in = pete_core.g_OBJECT_TYPE_PETE and a_description_in is not null then
                                                             'Pete run "' || a_description_in || '" id=' || g_last_run_log_id || ' @ ' ||
                                                             to_char(systimestamp)
                                                            when a_object_type_in = pete_core.g_OBJECT_TYPE_PETE and a_description_in is null then
                                                             'Pete run id=' || g_last_run_log_id || ' @ ' || to_char(systimestamp)
                                                            else
                                                             a_description_in
                                                        end,
                              a_object_type_in       => a_object_type_in,
                              a_object_name_in       => a_object_name_in);
        --
        return g_last_run_log_id;
        --
    end;

    --------------------------------------------------------------------------------
    function get_last_run_log_id return pete_run_log.id%type is
    begin
        return g_last_run_log_id;
    end;

    --------------------------------------------------------------------------------
    procedure end_test
    (
        a_run_log_id_in       in pete_run_log.id%type,
        a_execution_result_in in pete_types.typ_execution_result default g_SUCCESS,
        a_error_code_in       in pete_run_log.error_code%type default null
    ) is
    begin
        --
        pete_logger.log_end(a_run_log_id_in      => a_run_log_id_in,
                            a_result_in          => a_execution_result_in,
                            a_error_code_in      => a_error_code_in,
                            a_error_stack_in     => case
                                                        when not a_execution_result_in = g_SUCCESS then
                                                         dbms_utility.format_error_stack
                                                        else
                                                         null
                                                    end,
                            a_error_backtrace_in => case
                                                        when not a_execution_result_in = g_SUCCESS then
                                                         dbms_utility.format_error_backtrace
                                                        else
                                                         null
                                                    end);
        g_last_run_log_id := null;
    end;

end;
/
