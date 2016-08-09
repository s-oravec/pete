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
        a_run_log_id_in        IN pete_run_log.id%Type,
        a_parent_run_log_id_in IN pete_run_log.parent_id%Type,
        a_description_in       IN pete_run_log.description%Type,
        a_object_type_in       IN pete_run_log.object_type%Type,
        a_object_name_in       IN pete_run_log.object_name%Type
    );

    --
    -- TODO: public
    -- update method description - defined on method
    --
    -- %argument a_description_in method description
    --
    --------------------------------------------------------------------------------  
    PROCEDURE set_method_description(a_description_in IN pete_types.typ_description);

    --
    -- TODO: private
    --------------------------------------------------------------------------------
    PROCEDURE log_end
    (
        a_run_log_id_in      IN pete_run_log.id%Type,
        a_result_in          IN pete_run_log.result%Type,
        a_xml_in_in          IN pete_run_log.xml_in%Type,
        a_xml_out_in         IN pete_run_log.xml_out%Type,
        a_error_code_in      IN pete_run_log.error_code%Type,
        a_error_stack_in     IN pete_run_log.error_stack%Type,
        a_error_backtrace_in IN pete_run_log.error_backtrace%Type
    );

    --------------------------------------------------------------------------------
    -- TODO: public
    -- formatting methods
    --------------------------------------------------------------------------------
    -- TODO: move to pete types
    SUBTYPE typ_integer_boolean IS PLS_INTEGER RANGE 0 .. 1;
    g_TRUE  CONSTANT typ_integer_boolean := 1;
    g_FALSE CONSTANT typ_integer_boolean := 0;

    PROCEDURE output_log
    (
        a_run_log_id_in         IN pete_run_log.id%Type,
        a_show_failures_only_in IN typ_integer_boolean DEFAULT g_FALSE
    );

    FUNCTION display_log
    (
        a_run_log_id_in         IN pete_run_log.id%Type,
        a_show_failures_only_in IN typ_integer_boolean DEFAULT g_FALSE
    ) RETURN petet_log_tab
        PIPELINED;

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
        a_result_in     IN BOOLEAN,
        a_comment_in    IN VARCHAR2,
        a_plsql_unit_in IN VARCHAR2 DEFAULT NULL,
        a_plsql_line_in IN INTEGER DEFAULT NULL
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
