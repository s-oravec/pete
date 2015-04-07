create or replace package ut_test_generator_test_pkg2 as

  procedure ut_test_method
  (
    p_in    in integer,
    p_out   out integer,
    p_inout in out integer
  );

  procedure ut_test_method_overload(p_in1 in varchar2);

  procedure ut_test_method_overload
  (
    p_in1 in varchar2,
    p_in2 in integer
  );

  function ut_function return varchar2;

  function ut_function_with_args(p_in in integer) return varchar2;

  function ut_function_with_out_args(p_out out integer) return varchar2;

  function ut_function_with_args
  (
    p_in  in integer,
    p_out out integer
  ) return varchar2;

  function ut_function_with_args
  (
    p_in    in integer,
    p_out   out integer,
    p_inout in out integer
  ) return varchar2;

end;
/
create or replace package body ut_test_generator_test_pkg2 as

  procedure ut_test_method
  (
    p_in    in integer,
    p_out   out integer,
    p_inout in out integer
  ) is
  begin
    p_out   := p_in;
    p_inout := 42;
  end;

  procedure ut_test_method_overload(p_in1 in varchar2) is
  begin
    null;
  end;

  procedure ut_test_method_overload
  (
    p_in1 in varchar2,
    p_in2 in integer
  ) is
  begin
    null;
  end;

  function ut_function return varchar2 is
  begin
    return '42';
  end;

  function ut_function_with_args(p_in in integer) return varchar2 is
  begin
    return to_char(p_in);
  end;

  function ut_function_with_out_args(p_out out integer) return varchar2 is
  begin
    p_out := 42;
    return '42';
  end;

  function ut_function_with_args
  (
    p_in  in integer,
    p_out out integer
  ) return varchar2 is
  begin
    p_out := p_in;
    return '42';
  end;

  function ut_function_with_args
  (
    p_in    in integer,
    p_out   out integer,
    p_inout in out integer
  ) return varchar2 is
  begin
    p_out   := p_in;
    p_inout := p_inout + 1;
    return '42';
  end;

end;
/
