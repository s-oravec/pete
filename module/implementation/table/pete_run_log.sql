-- Create table
create table PETE_RUN_LOG
(
  id                 INTEGER not null,
  parent_id          INTEGER,
  object_type        VARCHAR2(30) not null,
  object_name        VARCHAR2(386) not null,
  result             INTEGER,
  description        VARCHAR2(4000),
  test_begin         TIMESTAMP(6),
  test_end           TIMESTAMP(6),
  plsql_unit         VARCHAR2(255),
  plsql_line         INTEGER,
  error_code         INTEGER,
  error_stack        VARCHAR2(4000),
  error_backtrace    VARCHAR2(4000)
);

-- Create/Recreate primary, unique and foreign key constraints 
alter table PETE_RUN_LOG
  add constraint PETE_RUN_LOG_PK primary key (id)
;

--TODO: Comments
