CREATE OR REPLACE PACKAGE pete_logger AS

    --
    -- Pete logging package
    -- - used by convention and configuration runners
    -- - use log_method method in implementation of test packages for Convention style test packages
    --

    -- TODO: split into pete_logger_public - granted to PUBLIC - to encapsulate Pete as a module
    -- TODO: and pete_logger_private - implementation of methods used by Pete runners implementation

    --------------------------------------------------------------------------------
    -- logging methods
    --------------------------------------------------------------------------------

    --
    -- TODO: private
    --------------------------------------------------------------------------------      
    PROCEDURE log_start
    (
        a_run_log_id_in        IN pete_run_log.id%TYPE,
        a_parent_run_log_id_in IN pete_run_log.parent_id%TYPE,
        a_description_in       IN pete_run_log.description%TYPE,
        a_object_type_in       IN pete_run_log.object_type%TYPE,
        a_object_name_in       IN pete_run_log.object_name%TYPE
    );

    --
    -- TODO: public
    -- update method description - defined on method
    --
    -- %argument a_description_in method description
    --
    --------------------------------------------------------------------------------  
    PROCEDURE set_method_description(a_description_in IN pete_core.typ_description);

    --
    -- TODO: private
    --------------------------------------------------------------------------------
    PROCEDURE log_end
    (
        a_run_log_id_in      IN pete_run_log.id%TYPE,
        a_result_in          IN pete_run_log.result%TYPE,
        a_xml_in_in          IN pete_run_log.xml_in%TYPE,
        a_xml_out_in         IN pete_run_log.xml_out%TYPE,
        a_error_code_in      IN pete_run_log.error_code%TYPE,
        a_error_stack_in     IN pete_run_log.error_stack%TYPE,
        a_error_backtrace_in IN pete_run_log.error_backtrace%TYPE
    );

    --------------------------------------------------------------------------------
    -- TODO: public
    -- formatting methods
    --------------------------------------------------------------------------------
    PROCEDURE output_log(a_run_log_id_in IN pete_run_log.id%TYPE);

    FUNCTION display_log(a_run_log_id_in IN pete_run_log.id%TYPE)
        RETURN petet_log_tab
        PIPELINED;

    -- TODO: private
    FUNCTION get_output_run_log_id RETURN pete_run_log.id%TYPE;

    --
    -- TODO: public
    -- inits a logger
    -- 
    --------------------------------------------------------------------------------  
    PROCEDURE init(a_log_to_dbms_output_in IN BOOLEAN DEFAULT TRUE);

    --
    -- TODO: private
    -- logs assert result
    -- 
    PROCEDURE log_assert
    (
        a_result_in  BOOLEAN,
        a_comment_in VARCHAR2
    );

    --------------------------------------------------------------------------------
    -- tracing methods
    --------------------------------------------------------------------------------

    --
    -- TODO: private
    -- wrapper for trace log
    --
    --------------------------------------------------------------------------------  
    PROCEDURE trace(a_trace_message_in VARCHAR2);

    --
    -- TODO: private
    -- trace log settings
    --
    --------------------------------------------------------------------------------  
    PROCEDURE set_trace(a_value_in IN BOOLEAN);

END;
/
