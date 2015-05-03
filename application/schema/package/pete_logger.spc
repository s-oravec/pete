CREATE OR REPLACE PACKAGE pete_logger AS

    --
    -- Pete logging package
    -- - used by convention and configuration runners
    --- use log_method method in implementation of test packages for Convention style test packages
    --

    /*--
    -- Logs methods info - use in Convention style test packages
    PROCEDURE log_method
    (
        a_description_in IN pete_core.typ_description,
        a_result_in      IN pete_core.typ_execution_result DEFAULT pete_core.gc_SUCCESS
    );
    
    --
    -- Logs runner thingies
    --
    -- %param a_context_in suite / script / case / block | schema / package / method
    -- %param a_result_in logged result
    -- %param a_description_in 
    --
    PROCEDURE log_runner
    (
        a_description_in IN pete_core.typ_description,
        a_result_in      IN pete_core.typ_execution_result DEFAULT pete_core.gc_SUCCESS,
        a_context_in     IN pete_core.typ_object_type DEFAULT pete_core.gc_CONTEXT_METHOD
    );*/

    PROCEDURE log_start
    (
        a_run_log_id_in        IN pete_run_log.id%TYPE,
        a_parent_run_log_id_in IN pete_run_log.parent_id%TYPE,
        a_description_in       IN pete_run_log.description%TYPE,
        a_object_type_in       IN pete_run_log.object_type%TYPE,
        a_object_name_in       IN pete_run_log.object_name%TYPE
    );

    PROCEDURE log_end
    (
        a_run_log_id_in    IN pete_run_log.id%TYPE,
        a_result_in        IN pete_run_log.result%TYPE,
        a_xml_in_in        IN pete_run_log.xml_in%TYPE,
        a_xml_out_in       IN pete_run_log.xml_out%TYPE,
        a_error_code_in    IN pete_run_log.error_code%TYPE,
        a_error_message_in IN pete_run_log.error_message%TYPE
    );

    --
    -- inits a logger
    -- 
    PROCEDURE init(a_log_to_dbms_output_in IN BOOLEAN DEFAULT TRUE);

    -- tracing methods
    --
    -- wrapper for trace log 
    --
    PROCEDURE trace(a_trace_message_in VARCHAR2);

    --
    -- trace log settings
    --
    PROCEDURE set_trace(a_value_in IN BOOLEAN);

    --
    -- update method description - defined on method
    --
    -- %param a_description_in method description
    --
    PROCEDURE log_method_description(a_description_in IN pete_core.typ_description);

END;
/
