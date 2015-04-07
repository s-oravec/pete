create or replace package utp_plsql_block_generator as

  --
  --PLSQL block generator implementation package
  --------------------------------------------------------------------------------

  subtype gtyp_in_out is varchar2(3);
  gc_argument_in  constant gtyp_in_out := 'IN';
  gc_argument_out constant gtyp_in_out := 'OUT';

  -- 
  -- Returns create type specification DDL statement for in/out Object Type for PLSQL block  wrapper method
  -- %param p_package_name_in 
  -- %param p_method_name_in 
  -- %param p_in_out_in 
  -- %param p_subprogram_id_in 
  -- %param p_overload_in 
  -- %return create type specification DDL statement
  --
  function get_arguments_type_spec
  (
    p_package_name_in  in user_arguments.package_name%type,
    p_method_name_in   in user_arguments.object_name%type,
    p_in_out_in        in gtyp_in_out,
    p_subprogram_id_in in user_arguments.subprogram_id%type default null,
    p_overload_in      in user_arguments.overload%type default null
  ) return varchar2;

  -- 
  -- Returns create type body DDL statement for in/out Object Type for PLSQL block  wrapper method
  -- %param p_package_name_in 
  -- %param p_method_name_in 
  -- %param p_in_out_in 
  -- %param p_subprogram_id_in 
  -- %param p_overload_in 
  -- %return create type body DDL statement
  --
  function get_arguments_type_body
  (
    p_package_name_in  in user_arguments.package_name%type,
    p_method_name_in   in user_arguments.object_name%type,
    p_in_out_in        in gtyp_in_out,
    p_subprogram_id_in in user_arguments.subprogram_id%type default null,
    p_overload_in      in user_arguments.overload%type default null
  ) return varchar2;

  -- 
  -- Returns create package specification DDL statement of wrapper packager for specified package
  -- %param p_package_name_in 
  -- %return create package specification DDL statement 
  --
  function get_wrapper_package_spec(p_package_name_in in user_arguments.package_name%type)
    return clob;

  -- 
  -- Returns create package body DDL statement of wrapper packager for specified package
  -- %param p_package_name_in 
  -- %return create package body DDL statement 
  --
  function get_wrapper_package_body(p_package_name_in in user_arguments.package_name%type)
    return clob;

  --
  -- Generate argument types and packages with wrapper methods
  procedure generate_test_objects(p_pkg_name_like_expression_in in varchar2 default null);

  -- internal
  function get_wrapper_method_impl
  (
    p_package_name  in varchar2,
    p_method_name   in varchar2,
    p_subprogram_id in integer default null,
    p_overload      in integer default null
  ) return varchar2;

end;
/
