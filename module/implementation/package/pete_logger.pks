create or replace package pete_logger as

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
    procedure log_start
    (
        a_run_log_id_in        in pete_run_log.id%type,
        a_parent_run_log_id_in in pete_run_log.parent_id%type,
        a_description_in       in pete_run_log.description%type,
        a_object_type_in       in pete_run_log.object_type%type,
        a_object_name_in       in pete_run_log.object_name%type
    );

    --
    -- TODO: public
    -- update method description - defined on method
    --
    -- %argument a_description_in method description
    --
    --------------------------------------------------------------------------------  
    procedure set_method_description(a_description_in in pete_types.typ_description);

    --
    -- TODO: private
    --------------------------------------------------------------------------------
    procedure log_end
    (
        a_run_log_id_in      in pete_run_log.id%type,
        a_result_in          in pete_run_log.result%type,
        a_error_code_in      in pete_run_log.error_code%type,
        a_error_stack_in     in pete_run_log.error_stack%type,
        a_error_backtrace_in in pete_run_log.error_backtrace%type
    );

    --------------------------------------------------------------------------------
    -- TODO: public
    -- formatting methods
    --------------------------------------------------------------------------------
    -- TODO: move to pete types
    subtype typ_integer_boolean is pls_integer range 0 .. 1;
    g_TRUE  constant typ_integer_boolean := 1;
    g_FALSE constant typ_integer_boolean := 0;

    procedure output_log
    (
        a_run_log_id_in         in pete_run_log.id%type,
        a_show_failures_only_in in typ_integer_boolean default g_FALSE
    );

    function display_log
    (
        a_run_log_id_in         in pete_run_log.id%type,
        a_show_failures_only_in in typ_integer_boolean default g_FALSE
    ) return pete_log_items
        pipelined;

    --
    -- TODO: public
    -- inits a logger
    -- 
    --------------------------------------------------------------------------------  
    procedure init(a_log_to_dbms_output_in in boolean default true);

    --
    -- TODO: private
    -- logs assert result
    -- 
    procedure log_assert
    (
        a_result_in     in boolean,
        a_comment_in    in varchar2,
        a_plsql_unit_in in varchar2 default null,
        a_plsql_line_in in integer default null
    );

    --------------------------------------------------------------------------------
    -- tracing methods
    --------------------------------------------------------------------------------

    --
    -- TODO: private
    -- wrapper for trace log
    --
    --------------------------------------------------------------------------------  
    procedure trace(a_trace_message_in varchar2);

    --
    -- TODO: private
    -- trace log settings
    --
    --------------------------------------------------------------------------------  
    procedure set_trace(a_value_in in boolean);

end;
/
