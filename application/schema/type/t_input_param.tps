CREATE OR REPLACE Type T_INPUT_PARAM as Object
(
  all_errors char(1),
  where_part   varchar2(4000),
  order_part   varchar2(4000)
);
/

