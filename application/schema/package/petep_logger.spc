CREATE OR REPLACE PACKAGE petep_logger AS

    --
    -- Pete logging package
    -- - used by convention and configuration runners
    --- use log_method method in implementation of test packages for Convention style test packages
    --

    -- log context subtype 
    SUBTYPE typ_log_context IS VARCHAR2(255);
    -- context constants
    gc_LOG_CONTEXT_SUITE   CONSTANT typ_log_context := 'SUITE';
    gc_LOG_CONTEXT_SCRIPT  CONSTANT typ_log_context := 'SCRIPT';
    gc_LOG_CONTEXT_CASE    CONSTANT typ_log_context := 'CASE';
    gc_LOG_CONTEXT_BLOCK   CONSTANT typ_log_context := 'BLOCK';
    gc_LOG_CONTEXT_SCHEMA  CONSTANT typ_log_context := 'SCHEMA';
    gc_LOG_CONTEXT_PACKAGE CONSTANT typ_log_context := 'PACKAGE';
    gc_LOG_CONTEXT_METHOD  CONSTANT typ_log_context := 'METHOD';
    gc_LOG_CONTEXT_ASSERT  CONSTANT typ_log_context := 'ASSERT';

    /*
    TODO: owner="stiivo" category="Review" created="29.4.2015"
    text="move to petep_runner?"
    */
    -- execution result subtype
    SUBTYPE typ_execution_result IS VARCHAR2(255);
    -- execution result constants
    gc_SUCCESS CONSTANT typ_execution_result := 'SUCCESS';
    gc_FAILURE CONSTANT typ_execution_result := 'FAILURE';

    -- description subtype
    SUBTYPE typ_description IS VARCHAR2(4000);

    --
    -- Logs assert package thingies
    --
    -- %param a_result_in assert result
    -- %param a_description_in assert description
    --
    PROCEDURE log_assert
    (
        a_result_in      IN petep_logger.typ_execution_result,
        a_description_in IN petep_logger.typ_description
    );

    --
    -- Logs methods info - use in Convention style test packages
    PROCEDURE log_method
    (
        a_description_in IN petep_logger.typ_description,
        a_result_in      IN petep_logger.typ_execution_result DEFAULT gc_SUCCESS
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
        a_description_in IN petep_logger.typ_description,
        a_result_in      IN petep_logger.typ_execution_result DEFAULT gc_SUCCESS,
        a_context_in     IN petep_logger.typ_log_context DEFAULT gc_LOG_CONTEXT_METHOD
    );

    -- 
    -- Prints a result to stdout - step 0 from reporting package
    --
    PROCEDURE print_result;

    --
    -- inits a logger
    -- 
    PROCEDURE init;

    --
    --wrapper for trace log 
    --
    PROCEDURE trace(a_trace_message_in VARCHAR2);

    --
    -- trace log settings
    --
    PROCEDURE set_trace(a_value_in IN BOOLEAN);

END;
/
