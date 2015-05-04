-- Create table
create table PETE_RUN_LOG_DETAIL
(
  run_log_detail_id INTEGER not null,
  run_log_id        INTEGER not null,
  result            VARCHAR2(10),
  assert_comment    VARCHAR2(1000),
  test_package      VARCHAR2(30),
  test_procedure    VARCHAR2(30),
  line_number       INTEGER,
  run_at            TIMESTAMP(6)
)
;

comment on table PETE_RUN_LOG_DETAIL is 'assert level run log';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PETE_RUN_LOG_DETAIL
  add constraint PETE_RUN_LOG_DETAIL_PK primary key (run_log_detail_id)
;
