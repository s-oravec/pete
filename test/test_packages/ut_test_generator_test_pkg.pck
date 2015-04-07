create or replace package ut_test_generator_test_pkg as

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

  procedure get_x;
  procedure get_y;

  procedure ut_test_method_ref_cursor
  (
    p_in1  in integer,
    p_out1 out sys_refcursor
  );

end;
/
create or replace package body ut_test_generator_test_pkg as

  procedure get_x is
  begin
    null;
  end;

  procedure get_y is
  begin
    null;
  end;

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

  procedure ut_test_method_ref_cursor
  (
    p_in1  in integer,
    p_out1 out sys_refcursor
  ) is
  begin
    open p_out1 for
      select p_in1 as n from dual;
  end;

end;
/
