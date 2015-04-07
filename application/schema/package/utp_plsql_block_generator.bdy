create or replace package body utp_plsql_block_generator as

  --------------------------------------------------------------------------------
  cursor gcrs_type_argument_lists
  (
    p_package_name  user_procedures.object_name%type,
    p_method_name   user_procedures.procedure_name%type,
    p_subprogram_id user_procedures.subprogram_id%type,
    p_overload      user_procedures.subprogram_id%type,
    p_in_out        utp_plsql_block_generator.gtyp_in_out
  ) is
    with type_attrs as
     (
      --generate type attributes definitions and constructor arguments
      select case p_in_out
                when 'IN' then
                 m.input_type_name
                else
                 m.output_type_name
              end as type_name,
              a.type_attr_name || ' ' || a.type_attr_type ||
              nvl2(a.type_attr_length, '(' || a.type_attr_length || ')', null) as type_attr_definition,
              a.type_attr_name || ' ' || a.type_attr_type || ' default null' as type_attr_constructor,
              a.position,
              a.package_name,
              a.method_name
        from utm_metadata_arguments a
        join utm_metadata_methods_api_types m on (a.package_name = m.package_name and
                                                 a.method_name = m.method_name and
                                                 a.subprogram_id = m.subprogram_id)
       where 1 = 1
         and in_out like '%' || p_in_out || '%'
         and a.package_name = p_package_name
         and a.method_name = p_method_name
         and (p_subprogram_id is null or a.subprogram_id = p_subprogram_id)
         and (p_overload is null or a.overload = p_overload)
         and a.data_level = 0)
    -- aggregate to lists
    select distinct --TODO: listagg for version > 11.1
                    utf_varchar2_delimited_concat(type_attr_definition) --
                     over(partition by type_name order by position rows between unbounded preceding and unbounded following) as type_attr_definition_list,
                    utf_varchar2_delimited_concat(type_attr_constructor) --
                    over(partition by type_name order by position rows between unbounded preceding and unbounded following) as type_attr_constructor_list,
                    package_name,
                    method_name,
                    type_name
      from type_attrs;
  type gtyp_type_argument_lists_tab is table of gcrs_type_argument_lists%rowtype;

  --------------------------------------------------------------------------------
  function get_metadata_methods_api_types
  (
    p_package_name  in varchar2,
    p_method_name   in varchar2,
    p_subprogram_id in integer,
    p_overload      in integer
  ) return utm_metadata_methods_api_types%rowtype is
    lrec_result utm_metadata_methods_api_types%rowtype;
  begin
    select *
      into lrec_result
      from utm_metadata_methods_api_types m
     where m.package_name = p_package_name
       and m.method_name = p_method_name
       and (p_subprogram_id is null or m.subprogram_id = p_subprogram_id)
       and (p_overload is null or m.overload = p_overload);
    --
    return lrec_result;
    --
  exception
    when no_data_found then
      raise_application_error(-20000,
                              'Method not found <package>.<method>: "' || --
                              p_package_name || '"."' || p_method_name || '"',
                              true);
    when too_many_rows then
      raise_application_error(-20000,
                              'More than one method matched. Set subprogram_id or overload',
                              true);
  end get_metadata_methods_api_types;

  --------------------------------------------------------------------------------
  function get_arguments_type_spec
  (
    p_package_name_in  in user_arguments.package_name%type,
    p_method_name_in   in user_arguments.object_name%type,
    p_in_out_in        in gtyp_in_out,
    p_subprogram_id_in in user_arguments.subprogram_id%type default null,
    p_overload_in      in user_arguments.overload%type default null
  ) return varchar2 is
    l_argument_type_spec_tpl     varchar(32767) --
    := 'create or replace type #TypeName# as object (' || chr(10) || --
       '  #AttributesDefinitionList#,' || chr(10) || --
       '  constructor function #TypeName# (self in out nocopy #TypeName#,' || chr(10) || --
       ' #AttributesConstructorList#) return self as result' || chr(10) || --
       ');';
    ltab_type_argument_lists     gtyp_type_argument_lists_tab;
    lrec_metadata_mtds_api_types utm_metadata_methods_api_types%rowtype;
  begin
    --
    --get method metadata - raise exception if too many rows
    lrec_metadata_mtds_api_types := get_metadata_methods_api_types(p_package_name  => p_package_name_in,
                                                                   p_method_name   => p_method_name_in,
                                                                   p_subprogram_id => p_subprogram_id_in,
                                                                   p_overload      => p_overload_in);
    --
    open gcrs_type_argument_lists(p_package_name  => p_package_name_in,
                                  p_method_name   => p_method_name_in,
                                  p_subprogram_id => p_subprogram_id_in,
                                  p_overload      => p_overload_in,
                                  p_in_out        => p_in_out_in);
    fetch gcrs_type_argument_lists bulk collect
      into ltab_type_argument_lists;
    close gcrs_type_argument_lists;
    --
    if ltab_type_argument_lists.count > 1
    then
      raise too_many_rows;
    elsif ltab_type_argument_lists.count = 0
    then
      return replace(replace(replace(l_argument_type_spec_tpl,
                                     '#TypeName#',
                                     case p_in_out_in when 'IN' then
                                     lrec_metadata_mtds_api_types.input_type_name else
                                     lrec_metadata_mtds_api_types.output_type_name end),
                             '#AttributesConstructorList#',
                             'dummy number default null'),
                     '#AttributesDefinitionList#',
                     'dummy number');
    else
      return replace(replace(replace(l_argument_type_spec_tpl,
                                     '#TypeName#',
                                     ltab_type_argument_lists(1).type_name),
                             '#AttributesConstructorList#',
                             ltab_type_argument_lists(1).type_attr_constructor_list),
                     '#AttributesDefinitionList#',
                     ltab_type_argument_lists(1).type_attr_definition_list);
    end if;
  exception
    when too_many_rows then
      raise_application_error(-20000,
                              'More than one method matched. Set subprogram_id or overload',
                              true);
    when others then
      if gcrs_type_argument_lists%isopen
      then
        close gcrs_type_argument_lists;
      end if;
      raise;
  end get_arguments_type_spec;

  --------------------------------------------------------------------------------
  function get_arguments_type_body
  (
    p_package_name_in  in user_arguments.package_name%type,
    p_method_name_in   in user_arguments.object_name%type,
    p_in_out_in        in gtyp_in_out,
    p_subprogram_id_in in user_arguments.subprogram_id%type default null,
    p_overload_in      in user_arguments.overload%type default null
  ) return varchar2 is
    l_argument_type_body_tpl     varchar(32767) --
    := 'create or replace type body #TypeName# as' || chr(10) || --
       '  constructor function #TypeName# (self in out nocopy #TypeName#,' || chr(10) || --
       ' #AttributesConstructorList#) return self as result is' || chr(10) || --
       '  begin' || chr(10) || --
       '    return;' || chr(10) || --
       '  end;' || chr(10) || --
       'end;';
    ltab_type_argument_lists     gtyp_type_argument_lists_tab;
    lrec_metadata_mtds_api_types utm_metadata_methods_api_types%rowtype;
  begin
    --
    --get method metadata - raise exception if too many rows
    lrec_metadata_mtds_api_types := get_metadata_methods_api_types(p_package_name  => p_package_name_in,
                                                                   p_method_name   => p_method_name_in,
                                                                   p_subprogram_id => p_subprogram_id_in,
                                                                   p_overload      => p_overload_in);
    --
    open gcrs_type_argument_lists(p_package_name  => p_package_name_in,
                                  p_method_name   => p_method_name_in,
                                  p_subprogram_id => p_subprogram_id_in,
                                  p_overload      => p_overload_in,
                                  p_in_out        => p_in_out_in);
    fetch gcrs_type_argument_lists bulk collect
      into ltab_type_argument_lists;
    close gcrs_type_argument_lists;
    --
    if ltab_type_argument_lists.count > 1
    then
      raise too_many_rows;
    elsif ltab_type_argument_lists.count = 0
    then
      return replace(replace(l_argument_type_body_tpl,
                             '#TypeName#',
                             case p_in_out_in when 'IN' then
                             lrec_metadata_mtds_api_types.input_type_name else
                             lrec_metadata_mtds_api_types.output_type_name end),
                     '#AttributesConstructorList#',
                     'dummy number default null');
    else
      return replace(replace(l_argument_type_body_tpl,
                             '#TypeName#',
                             ltab_type_argument_lists(1).type_name),
                     '#AttributesConstructorList#',
                     ltab_type_argument_lists(1).type_attr_constructor_list);
    end if;
  exception
    when too_many_rows then
      raise_application_error(-20000,
                              'More than one method matched. Set subprogram_id or overload',
                              true);
    when others then
      if gcrs_type_argument_lists%isopen
      then
        close gcrs_type_argument_lists;
      end if;
      raise;
  end get_arguments_type_body;

  --------------------------------------------------------------------------------
  function get_wrapper_method_spec
  (
    p_package_name  in varchar2,
    p_method_name   in varchar2,
    p_subprogram_id in integer default null,
    p_overload      in integer default null
  ) return varchar2 is
    --
    --method implementation template  
    l_method_implementation_tpl varchar2(32767) --
    := 'procedure #UxMethodName#' || chr(10) || --
       '  (' || chr(10) || --
       '    p_xml_in  in xmltype,' || chr(10) || --
       '    p_xml_out out nocopy xmltype' || chr(10) || --
       '  );' || chr(10) --
     ;
    --
    lrec_metadata_mtds_api_types utm_metadata_methods_api_types%rowtype;
  begin
    --
    --get method metadata - raise exception if too many rows
    lrec_metadata_mtds_api_types := get_metadata_methods_api_types(p_package_name  => p_package_name,
                                                                   p_method_name   => p_method_name,
                                                                   p_subprogram_id => p_subprogram_id,
                                                                   p_overload      => p_overload);
    --
    return replace(l_method_implementation_tpl,
                   '#UxMethodName#',
                   lrec_metadata_mtds_api_types.ux_method_name);
    --
  end get_wrapper_method_spec;

  --------------------------------------------------------------------------------
  function get_wrapper_method_impl
  (
    p_package_name  in varchar2,
    p_method_name   in varchar2,
    p_subprogram_id in integer default null,
    p_overload      in integer default null
  ) return varchar2 is
    --
    --method implementation template  
    l_method_implementation_tpl varchar2(32767) --
    := 'procedure #UxMethodName#' || chr(10) || --
       '  (' || chr(10) || --
       '    p_xml_in  in xmltype,' || chr(10) || --
       '    p_xml_out out nocopy xmltype' || chr(10) || --
       '  ) is' || chr(10) || --
       '  l_params_in  #InputTypeName#;' || chr(10) || --
       '  l_params_out #OutputTypeName# := #OutputTypeName#();' || chr(10) || --
       '  --' || chr(10) || ---
       '  --declaration of local helper variables' || chr(10) || --
       '  #RefCrsDeclaration#' || chr(10) || --
       'begin' || chr(10) || --
       '  --' || chr(10) || --
       '  --create input params object from xml' || chr(10) || --
       '  p_xml_in.toobject(object => l_params_in);' || chr(10) || --
       '  --' || chr(10) || --
       '  --for all in/out arguments assign in/out arguments of output params object' || chr(10) || --
       '  #InOutAssignment#' || --      
       '  --' || chr(10) || --
       '  --call method' || chr(10) || --
       '  #ResultAssignment##PackageName#.#MethodName#(#ArgumentsAssignementList#);' || chr(10) || --
       '  --' || chr(10) || --
       '  --add helper output arguments to output xml' || chr(10) || --
       '  #RefCrsToXml#' || --
       '  --' || chr(10) || --
       '  --convert output parameters object to xml' || chr(10) || --
       '  p_xml_out := xmltype.createxml(xmlData => l_params_out);' || chr(10) || --
       '  --' || chr(10) || --
       'end #UxMethodName#;';
    --
    --------------------------------------------------------------------------------
    --helper templates
    --declaration
    l_refcrs_declaration_tpl varchar2(255) --
    := '#LocalHelperName# sys_refcursor;' || chr(10);
    --convert to xml
    l_refcrs_to_xml_tpl varchar2(255) --
    := 'l_params_out.#ArgName# := xmlType.createXml(#LocalHelperName#);' || chr(10);
    --
    --cursor of cursor fragments
    cursor lcrs_cursor_sql_fragments is
      select distinct utf_varchar2_concat(replace(l_refcrs_declaration_tpl,
                                                  '#LocalHelperName#',
                                                  a.local_helper_name)) --
                      over(order by position rows between unbounded preceding and unbounded following) as refcrs_declaration,
                      utf_varchar2_concat(replace(replace(l_refcrs_to_xml_tpl,
                                                          '#LocalHelperName#',
                                                          a.local_helper_name),
                                                  '#ArgName#',
                                                  a.argument_name)) --
                      over(order by position rows between unbounded preceding and unbounded following) as refcrs_to_xml
        from utm_metadata_arguments a
       where package_name = p_package_name
         and method_name = p_method_name
         and (p_subprogram_id is null or a.subprogram_id = p_subprogram_id)
         and (p_overload is null or a.overload = p_overload)
         and data_type = 'REF CURSOR';
    --
    --------------------------------------------------------------------------------
    --arguments templates
    --in -> out assignment - for in/out arguments
    l_inout_assignment_tpl varchar2(255) := 'l_params_out.#ArgName# := l_params_in.#ArgName#;' ||
                                            chr(10);
    cursor lcrs_inout_asgn_sql_fragments is
      select distinct utf_varchar2_concat(replace(l_inout_assignment_tpl,
                                                  '#ArgName#',
                                                  a.argument_name)) --
                      over(order by position rows between unbounded preceding and unbounded following) as inout_assignment,
                      position
        from utm_metadata_arguments a
       where package_name = p_package_name
         and method_name = p_method_name
         and (p_subprogram_id is null or a.subprogram_id = p_subprogram_id)
         and (p_overload is null or a.overload = p_overload)
         and in_out = 'IN/OUT'
         and argument_name is not null
       order by position;
    --argument assignement
    l_args_assignment_tpl        varchar2(255) := '#ArgName# => l_params_#InOut#.#ArgName#' ||
                                                  chr(10);
    l_args_helper_assignment_tpl varchar2(255) := '#ArgName# => #LocalHelperName#' || chr(10);
    cursor lcrs_args_asgn_sql_fragments is
      select distinct utf_varchar2_delimited_concat(replace(replace(case
                                                                      when data_type in ('REF CURSOR') then
                                                                       replace(l_args_helper_assignment_tpl,
                                                                               '#LocalHelperName#',
                                                                               a.local_helper_name)
                                                                      else
                                                                       l_args_assignment_tpl
                                                                    end,
                                                                    '#ArgName#',
                                                                    a.argument_name),
                                                            '#InOut#',
                                                            lower(decode(a.in_out,
                                                                         'IN/OUT',
                                                                         'out',
                                                                         a.in_out)))) --
                      over(order by position rows between unbounded preceding and unbounded following) as args_assignment,
                      position
        from utm_metadata_arguments a
       where package_name = p_package_name
         and method_name = p_method_name
         and (p_subprogram_id is null or a.subprogram_id = p_subprogram_id)
         and (p_overload is null or a.overload = p_overload)
         and argument_name is not null
       order by position;
    --
    lrec_metadata_mtds_api_types utm_metadata_methods_api_types%rowtype;
    l_sql                        varchar2(32767);
  begin
    --
    --get method metadata - raise exception if too many rows
    lrec_metadata_mtds_api_types := get_metadata_methods_api_types(p_package_name  => p_package_name,
                                                                   p_method_name   => p_method_name,
                                                                   p_subprogram_id => p_subprogram_id,
                                                                   p_overload      => p_overload);
    --
    --build sql statement
    l_sql := replace(l_method_implementation_tpl,
                     '#UxMethodName#',
                     lrec_metadata_mtds_api_types.ux_method_name);
    l_sql := replace(l_sql, '#MethodName#', lrec_metadata_mtds_api_types.method_name);
    l_sql := replace(l_sql, '#PackageName#', lrec_metadata_mtds_api_types.package_name);
    l_sql := replace(l_sql, '#InputTypeName#', lrec_metadata_mtds_api_types.input_type_name);
    l_sql := replace(l_sql, '#OutputTypeName#', lrec_metadata_mtds_api_types.output_type_name);
    --
    --------------------------------------------------------------------------------
    --helper sql fragments
    --refcursors
    for sql_fragment in lcrs_cursor_sql_fragments
    loop
      l_sql := replace(l_sql, '#RefCrsDeclaration#', sql_fragment.refcrs_declaration);
      l_sql := replace(l_sql, '#RefCrsToXml#', sql_fragment.refcrs_to_xml);
    end loop;
    l_sql := replace(l_sql, '#RefCrsDeclaration#');
    l_sql := replace(l_sql, '#RefCrsToXml#');
    --result assignment
    if lrec_metadata_mtds_api_types.method_type = 'FUNCTION'
    then
      l_sql := replace(l_sql, '#ResultAssignment#', 'l_params_out.result := ');
    else
      l_sql := replace(l_sql, '#ResultAssignment#');
    end if;
    --
    --------------------------------------------------------------------------------
    --arguments sql fragments
    for sql_fragment in lcrs_inout_asgn_sql_fragments
    loop
      l_sql := replace(l_sql, '#InOutAssignment#', sql_fragment.inout_assignment);
    end loop;
    l_sql := replace(l_sql, '#InOutAssignment#');
    --argument assignements    
    for sql_fragment in lcrs_args_asgn_sql_fragments
    loop
      l_sql := replace(l_sql, '#ArgumentsAssignementList#', sql_fragment.args_assignment);
    end loop;
    l_sql := replace(l_sql, '#ArgumentsAssignementList#');
    --
    return l_sql;
    --
  end get_wrapper_method_impl;

  --------------------------------------------------------------------------------
  function get_wrapper_package_spec(p_package_name_in in user_arguments.package_name%type)
    return clob is
    l_result       clob;
    l_package_name varchar2(30);
  begin
    --
    dbms_lob.createtemporary(lob_loc => l_result, cache => false);
    --
    for package_method_api_type in (select *
                                      from utm_metadata_methods_api_types m
                                     where package_name = p_package_name_in
                                     order by m.subprogram_id)
    loop
      --
      if dbms_lob.getlength(l_result) = 0
      then
        l_result       := 'create or replace package ' || package_method_api_type.ux_package_name ||
                          ' as' || chr(10);
        l_package_name := package_method_api_type.ux_package_name;
      end if;
      --
      l_result := l_result || chr(10) ||
                  get_wrapper_method_spec(p_package_name  => package_method_api_type.package_name,
                                          p_method_name   => package_method_api_type.method_name,
                                          p_subprogram_id => package_method_api_type.subprogram_id);
    end loop;
    --
    l_result := l_result || chr(10) || 'end ' || l_package_name || ';';
    --
    return l_result;
    --
  end get_wrapper_package_spec;

  --------------------------------------------------------------------------------
  function get_wrapper_package_body(p_package_name_in in user_arguments.package_name%type)
    return clob is
    l_result       clob;
    l_package_name varchar2(30);
  begin
    --
    dbms_lob.createtemporary(lob_loc => l_result, cache => false);
    --
    for package_method_api_type in (select *
                                      from utm_metadata_methods_api_types m
                                     where package_name = p_package_name_in
                                     order by m.subprogram_id)
    loop
      --
      if dbms_lob.getlength(l_result) = 0
      then
        l_result       := 'create or replace package body ' ||
                          package_method_api_type.ux_package_name || ' as' || chr(10);
        l_package_name := package_method_api_type.ux_package_name;
      end if;
      --
      l_result := l_result || chr(10) || lpad('-', 80, '-') || chr(10) ||
                  get_wrapper_method_impl(p_package_name  => package_method_api_type.package_name,
                                          p_method_name   => package_method_api_type.method_name,
                                          p_subprogram_id => package_method_api_type.subprogram_id);
    end loop;
    --
    l_result := l_result || chr(10) || 'end ' || l_package_name || ';';
    --
    return l_result;
    --
  end get_wrapper_package_body;

  --------------------------------------------------------------------------------
  procedure generate_test_objects(p_pkg_name_like_expression_in in varchar2 default null) is
    --
    procedure execute_ddl_statement
    (
      p_statement_in    in clob,
      p_package_name_in in user_arguments.package_name%type default null,
      p_method_name_in  in user_arguments.object_name%type default null
    ) is
      le_succes_with_comp_error exception;
      pragma exception_init(le_succes_with_comp_error, -24344);
    begin
      if p_statement_in is not null
      then
        dbms_output.put_line(p_statement_in || chr(10) || '/' || chr(10));
        --execute immediate p_statement_in;
      end if;
    exception
      when le_succes_with_comp_error then
        dbms_output.put_line('ERROR: package:method: [' || p_package_name_in || ':' ||
                             p_method_name_in || ']');
        dbms_output.put_line(sqlerrm);
      when others then
        dbms_output.put_line(substr(p_statement_in, 1, 4000));
        dbms_output.put_line('ERROR: package:method: [' || p_package_name_in || ':' ||
                             p_method_name_in || ']');
        dbms_output.put_line(sqlerrm);
        raise;
    end;
    --
  begin
    <<package_loop>>
    for lrec_package in (select distinct package_name
                           from utm_metadata_methods
                          where package_name like nvl(p_pkg_name_like_expression_in, '%'))
    loop
      <<method_loop>>
      for lrec_method in (select *
                            from utm_metadata_methods
                           where package_name = lrec_package.package_name)
      loop
        --
        --create input type specification
        execute_ddl_statement(p_statement_in    => get_arguments_type_spec(p_package_name_in  => lrec_method.package_name,
                                                                           p_method_name_in   => lrec_method.method_name,
                                                                           p_in_out_in        => utp_plsql_block_generator.gc_argument_in,
                                                                           p_subprogram_id_in => lrec_method.subprogram_id),
                              p_package_name_in => lrec_method.method_name,
                              p_method_name_in  => lrec_method.method_name);
        --
        --create input type body
        execute_ddl_statement(p_statement_in    => get_arguments_type_body(p_package_name_in  => lrec_method.package_name,
                                                                           p_method_name_in   => lrec_method.method_name,
                                                                           p_in_out_in        => utp_plsql_block_generator.gc_argument_in,
                                                                           p_subprogram_id_in => lrec_method.subprogram_id),
                              p_package_name_in => lrec_method.method_name,
                              p_method_name_in  => lrec_method.method_name);
        --
        --create output type specification
        execute_ddl_statement(p_statement_in    => get_arguments_type_spec(p_package_name_in  => lrec_method.package_name,
                                                                           p_method_name_in   => lrec_method.method_name,
                                                                           p_in_out_in        => utp_plsql_block_generator.gc_argument_out,
                                                                           p_subprogram_id_in => lrec_method.subprogram_id),
                              p_package_name_in => lrec_method.method_name,
                              p_method_name_in  => lrec_method.method_name);
        --
        --create output type body
        execute_ddl_statement(p_statement_in    => get_arguments_type_body(p_package_name_in  => lrec_method.package_name,
                                                                           p_method_name_in   => lrec_method.method_name,
                                                                           p_in_out_in        => utp_plsql_block_generator.gc_argument_out,
                                                                           p_subprogram_id_in => lrec_method.subprogram_id),
                              p_package_name_in => lrec_method.method_name,
                              p_method_name_in  => lrec_method.method_name);
      end loop method_loop;
      --
      --create package specification
      execute_ddl_statement(p_statement_in    => get_wrapper_package_spec(p_package_name_in => lrec_package.package_name),
                            p_package_name_in => lrec_package.package_name);
      --
      --create package body
      execute_ddl_statement(p_statement_in    => get_wrapper_package_body(p_package_name_in => lrec_package.package_name),
                            p_package_name_in => lrec_package.package_name);
      --
    end loop package_loop;
    --
  end generate_test_objects;

end;
/
