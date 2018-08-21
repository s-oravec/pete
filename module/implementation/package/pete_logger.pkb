create or replace package body pete_logger as

    gc_LOG_TO_DBMS_OUTPUT constant boolean := true;

    g_log_to_dbms_output boolean;
    g_trace              boolean := false;

    --used to update log_run record as method description is available after 
    --log record for method is already created
    g_run_log_id           integer;
    g_output_run_log_id    integer;
    g_show_failures_only   typ_integer_boolean;
    g_parent_run_log_id_in integer;
    g_object_type_in       pete_run_log.object_type%type;
    g_object_name_in       pete_run_log.object_name%type;

    --------------------------------------------------------------------------------
    function get_package_description(a_package_name_in in pete_types.typ_object_name) return varchar2 is
        l_call_template constant varchar2(255) --
        := 'begin :1 := #PackageName#.description; end;';
        l_Result varchar(255);
    begin
        execute immediate replace(l_call_template, '#PackageName#', a_package_name_in)
            using out l_Result;
        return l_Result;
    exception
        when others then
            return null;
    end get_package_description;

    --------------------------------------------------------------------------------  
    function get_suite_description(a_suite_name_in in varchar2) return varchar2 is
    begin
        return 'Suite ' || a_suite_name_in;
    end get_suite_description;

    --
    -- package initialization
    --
    --------------------------------------------------------------------------------
    procedure init(a_log_to_dbms_output_in in boolean default true) is
    begin
        g_log_to_dbms_output := nvl(a_log_to_dbms_output_in, gc_LOG_TO_DBMS_OUTPUT);
    end init;

    --------------------------------------------------------------------------------
    procedure log_start
    (
        a_run_log_id_in        in pete_run_log.id%type,
        a_parent_run_log_id_in in pete_run_log.parent_id%type,
        a_description_in       in pete_run_log.description%type,
        a_object_type_in       in pete_run_log.object_type%type,
        a_object_name_in       in pete_run_log.object_name%type
    ) is
        lrec_pete_run_log pete_run_log%rowtype;
        pragma autonomous_transaction;
    begin
        --
        trace('LOG_START: ' || 'a_run_log_id_in:' || NVL(to_char(a_run_log_id_in), 'NULL') || ', ' || 'a_parent_run_log_id_in:' ||
              NVL(to_char(a_parent_run_log_id_in), 'NULL') || ', ' || 'a_description_in:' || NVL(a_description_in, 'NULL') || ', ' ||
              'a_object_type_in:' || NVL(a_object_type_in, 'NULL') || ', ' || 'a_object_name_in:' || NVL(a_object_name_in, 'NULL'));
    
        g_run_log_id           := a_run_log_id_in;
        g_parent_run_log_id_in := a_parent_run_log_id_in;
        g_object_type_in       := a_object_type_in;
        g_object_name_in       := a_object_name_in;
    
        --
        lrec_pete_run_log.id          := a_run_log_id_in;
        lrec_pete_run_log.parent_id   := a_parent_run_log_id_in;
        lrec_pete_run_log.object_type := a_object_type_in;
        lrec_pete_run_log.object_name := a_object_name_in;
        lrec_pete_run_log.test_begin  := systimestamp;
        --
        case a_object_type_in
            when pete_core.g_OBJECT_TYPE_PACKAGE then
                lrec_pete_run_log.description := get_package_description(a_package_name_in => a_object_name_in) || a_description_in;
            when pete_core.g_OBJECT_TYPE_SUITE then
                lrec_pete_run_log.description := get_suite_description(a_suite_name_in => a_object_name_in) || a_description_in;
            else
                lrec_pete_run_log.description := a_description_in;
        end case;
        --
        lrec_pete_run_log.description := nvl(lrec_pete_run_log.description,
                                             'Testing ' || lower(a_object_type_in) || ' ' || upper(a_object_name_in));
        --
        insert into pete_run_log values lrec_pete_run_log;
        --
        commit;
        --
    end;

    --------------------------------------------------------------------------------
    procedure log_end
    (
        a_run_log_id_in      in pete_run_log.id%type,
        a_result_in          in pete_run_log.result%type,
        a_error_code_in      in pete_run_log.error_code%type,
        a_error_stack_in     in pete_run_log.error_stack%type,
        a_error_backtrace_in in pete_run_log.error_backtrace%type
    ) is
        pragma autonomous_transaction;
    begin
        --
        trace('LOG_END: ' || 'a_run_log_id_in:' || NVL(to_char(a_run_log_id_in), 'NULL') || ', ' || 'a_result_in:' ||
              NVL(to_char(a_result_in), 'NULL') || ', ' || 'a_error_code_in:' || NVL(to_char(a_error_code_in), 'NULL') || ', ' ||
              'a_error_stack_in:' || NVL(a_error_stack_in, 'NULL') || ', ' || 'a_error_backtrace_in:' || NVL(a_error_backtrace_in, 'NULL'));
        update pete_run_log P
           set p.result          = a_result_in,
               p.test_end        = systimestamp,
               p.error_code      = a_error_code_in,
               p.error_stack     = a_error_stack_in,
               p.error_backtrace = a_error_backtrace_in
         where ID = a_run_log_id_in;
        --
        commit;
        --
    end;

    --------------------------------------------------------------------------------
    procedure set_method_description(a_description_in in pete_types.typ_description) is
        pragma autonomous_transaction;
    begin
        --
        trace('set_method_description: ' || 'a_description_in:' || NVL(a_description_in, 'NULL'));
        update pete_run_log set Description = a_description_in where ID = g_run_log_id; --set to package session variable on start of method execution
        --
        commit;
        --
    end;

    --------------------------------------------------------------------------------
    procedure log_assert
    (
        a_result_in     in boolean,
        a_comment_in    in varchar2,
        a_plsql_unit_in in varchar2 default null,
        a_plsql_line_in in integer default null
    ) is
        pragma autonomous_transaction;
        lrec_pete_run_log pete_run_log%rowtype;
    begin
        --
        lrec_pete_run_log.id          := pete_run_log_seq.nextval;
        lrec_pete_run_log.parent_id   := g_parent_run_log_id_in;
        lrec_pete_run_log.object_type := pete_core.g_OBJECT_TYPE_ASSERT;
        lrec_pete_run_log.object_name := g_object_name_in;
        lrec_pete_run_log.test_begin  := systimestamp;
        lrec_pete_run_log.test_end    := systimestamp;
        lrec_pete_run_log.description := a_comment_in;
        lrec_pete_run_log.plsql_unit  := a_plsql_unit_in;
        lrec_pete_run_log.plsql_line  := a_plsql_line_in;
        if (a_result_in) then
            lrec_pete_run_log.result := pete_core.g_SUCCESS;
        else
            lrec_pete_run_log.result := pete_core.g_FAILURE;
        end if;
        --
        insert into pete_run_log values lrec_pete_run_log;
        --
        commit;
        --
    end log_assert;

    --
    --wrapper for trace log 
    --
    --------------------------------------------------------------------------------
    procedure trace(a_trace_message_in varchar2) is
    begin
        if (g_trace) then
            dbms_output.put_line('TRACE> ' || a_trace_message_in); --enhancement  --konfigurovatelne globalne
        end if;
    end trace;

    --
    -- trace log settings
    --
    procedure set_trace(a_value_in in boolean) is
    begin
        g_trace := a_value_in;
    end set_trace;

    --------------------------------------------------------------------------------
    function get_output_run_log_id return pete_run_log.id%type is
    begin
        return g_output_run_log_id;
    end;

    --------------------------------------------------------------------------------
    function do_output(a_log_line_in in petev_output_run_log%rowtype) return boolean is
    begin
        --
        -- hook methods
        if (not pete_config_impl.get_show_hook_methods and a_log_line_in.object_type = pete_core.g_OBJECT_TYPE_HOOK) then
            pete_logger.trace('not printing hook methods - ' || a_log_line_in.log);
            return false;
        end if;
        --
        -- asserts
        if a_log_line_in.object_type = pete_core.g_OBJECT_TYPE_ASSERT then
            if (pete_config_impl.get_show_asserts = pete_config.ASSERTS_NONE) then
                pete_logger.trace('not printing asserts - ' || a_log_line_in.log);
                return false;
            elsif (pete_config_impl.get_show_asserts = pete_config.ASSERTS_FAILED and a_log_line_in.result = pete_core.g_SUCCESS) then
                pete_logger.trace('not printing success asserts - ' || a_log_line_in.log);
                return false;
            end if;
        end if;
        --
        -- failures only
        if (pete_config_impl.get_show_failures_only and a_log_line_in.result = pete_core.g_SUCCESS) then
            return false;
        end if;
        --
        return true;
        --
    end;

    --------------------------------------------------------------------------------
    procedure print_top_level_result(a_result_in in pete_types.typ_execution_result) is
    begin
        dbms_output.put_line(null);
        if a_result_in = pete_core.g_SUCCESS then
            dbms_output.put_line('    SSSS   U     U   CCC     CCC   EEEEEEE   SSSS     SSSS   ');
            dbms_output.put_line('   S    S  U     U  C   C   C   C  E        S    S   S    S  ');
            dbms_output.put_line('  S        U     U C     C C     C E       S        S        ');
            dbms_output.put_line('   S       U     U C       C       E        S        S       ');
            dbms_output.put_line('    SSSS   U     U C       C       EEEE      SSSS     SSSS   ');
            dbms_output.put_line('        S  U     U C       C       E             S        S  ');
            dbms_output.put_line('         S U     U C     C C     C E              S        S ');
            dbms_output.put_line('   S    S   U   U   C   C   C   C  E        S    S   S    S  ');
            dbms_output.put_line('    SSSS     UUU     CCC     CCC   EEEEEEE   SSSS     SSSS   ');
        else
            dbms_output.put_line('  FFFFFFF   AA     III  L      U     U RRRRR   EEEEEEE ');
            dbms_output.put_line('  F        A  A     I   L      U     U R    R  E       ');
            dbms_output.put_line('  F       A    A    I   L      U     U R     R E       ');
            dbms_output.put_line('  F      A      A   I   L      U     U R     R E       ');
            dbms_output.put_line('  FFFF   A      A   I   L      U     U RRRRRR  EEEE    ');
            dbms_output.put_line('  F      AAAAAAAA   I   L      U     U R   R   E       ');
            dbms_output.put_line('  F      A      A   I   L      U     U R    R  E       ');
            dbms_output.put_line('  F      A      A   I   L       U   U  R     R E       ');
            dbms_output.put_line('  F      A      A  III  LLLLLLL  UUU   R     R EEEEEEE ');
        end if;
    end;

    --------------------------------------------------------------------------------
    procedure output_log
    (
        a_run_log_id_in         in pete_run_log.id%type,
        a_show_failures_only_in in typ_integer_boolean default g_FALSE
    ) is
        l_top_level_result pete_types.typ_execution_result;
    begin
        trace('OUTPUT_LOG: ' || 'a_run_log_id_in:' || NVL(to_char(a_run_log_id_in), 'NULL'));
        --
        g_output_run_log_id  := a_run_log_id_in;
        g_show_failures_only := a_show_failures_only_in;
        --
        dbms_output.put_line(chr(10));
        for log_line in (select * from petev_output_run_log where run_log_id = a_run_log_id_in) loop
            --first record in the view is the top level one
            if (l_top_level_result is null) then
                l_top_level_result := log_line.result;
            end if;
        
            if (do_output(a_log_line_in => log_line)) then
                -- additional empty line before package
                if log_line.object_type = pete_core.g_OBJECT_TYPE_PACKAGE then
                    dbms_output.put_line(null);
                end if;
                dbms_output.put_line(log_line.log);
            end if;
        end loop;
        print_top_level_result(l_top_level_result);
        dbms_output.put_line(chr(10) || chr(10));
    end;

    --------------------------------------------------------------------------------                 
    function display_log
    (
        a_run_log_id_in         in pete_run_log.id%type,
        a_show_failures_only_in in typ_integer_boolean default g_FALSE
    ) return pete_log_items
        pipelined is
    begin
        trace('DISPLAY_LOG: ' || 'a_run_log_id_in:' || NVL(to_char(a_run_log_id_in), 'NULL'));
        --
        g_output_run_log_id  := a_run_log_id_in;
        g_show_failures_only := a_show_failures_only_in;
        --
        for log_line in (select * from petev_output_run_log where run_log_id = a_run_log_id_in) loop
            if log_line.object_type = pete_core.g_OBJECT_TYPE_PACKAGE then
                -- pipe aditional empty line before package
                pipe row(pete_log_item(null));
            end if;
            if do_output(log_line) then
                pipe row(pete_log_item(log_line.log));
            end if;
        end loop;
    end;

    --------------------------------------------------------------------------------    
    function get_show_failures_only return typ_integer_boolean is
    begin
        return g_show_failures_only;
    end;

begin
    init(a_log_to_dbms_output_in => true);
end;
/
