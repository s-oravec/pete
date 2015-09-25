create table PETE_PLSQL_BLOCK_IN_CASE
(
  id                 INTEGER not null,
  test_case_id       INTEGER not null,
  plsql_block_id     INTEGER not null,
  input_argument_id  INTEGER,
  expected_result_id INTEGER,
  block_order        INTEGER not null,
  stop_on_failure    VARCHAR2(1) default 'N' not null,
  run_modifier       VARCHAR2(30),
  description        VARCHAR2(4000)
)
;
comment on table PETE_PLSQL_BLOCK_IN_CASE
  is 'PLSQL block in Test case';
  
comment on column PETE_PLSQL_BLOCK_IN_CASE.id
  is 'PLSQL block surrogate identifier';
comment on column PETE_PLSQL_BLOCK_IN_CASE.test_case_id
  is 'Test case identifier';
comment on column PETE_PLSQL_BLOCK_IN_CASE.plsql_block_id
  is 'PLSQL block identifier';
comment on column PETE_PLSQL_BLOCK_IN_CASE.input_argument_id
  is 'Input argument identifier';
comment on column PETE_PLSQL_BLOCK_IN_CASE.expected_result_id
  is 'Expected result identifier';
comment on column PETE_PLSQL_BLOCK_IN_CASE.block_order
  is 'Block order in Test case';
comment on column PETE_PLSQL_BLOCK_IN_CASE.stop_on_failure
  is 'Stops test execution on error';
comment on column PETE_PLSQL_BLOCK_IN_CASE.run_modifier
  is 'Run modifier - ONLY - only this PLSQL block in Test Case is executed; SKIP - this PLSQL block in Test Case will be skipped';
comment on column PETE_PLSQL_BLOCK_IN_CASE.description
  is 'Description';

create index PETE_PLSQL_BLOCK_IN_CASE_FK01 on PETE_PLSQL_BLOCK_IN_CASE (PLSQL_BLOCK_ID);
create index PETE_PLSQL_BLOCK_IN_CASE_FK02 on PETE_PLSQL_BLOCK_IN_CASE (INPUT_ARGUMENT_ID);
create index PETE_PLSQL_BLOCK_IN_CASE_FK03 on PETE_PLSQL_BLOCK_IN_CASE (TEST_CASE_ID);

alter table PETE_PLSQL_BLOCK_IN_CASE
  add constraint PETE_PLSQL_BLOCK_IN_CASE_PK primary key (ID);
alter table PETE_PLSQL_BLOCK_IN_CASE
  add constraint PETE_PLSQL_BLOCK_IN_CASE_UK01 unique (TEST_CASE_ID, BLOCK_ORDER);
alter table PETE_PLSQL_BLOCK_IN_CASE
  add constraint PETE_PLSQL_BLOCK_IN_CASE_FK01 foreign key (PLSQL_BLOCK_ID)
  references PETE_PLSQL_BLOCK (ID);
alter table PETE_PLSQL_BLOCK_IN_CASE
  add constraint PETE_PLSQL_BLOCK_IN_CASE_FK02 foreign key (INPUT_ARGUMENT_ID)
  references PETE_INPUT_ARGUMENT (ID);
alter table PETE_PLSQL_BLOCK_IN_CASE
  add constraint PETE_PLSQL_BLOCK_IN_CASE_FK03 foreign key (TEST_CASE_ID)
  references PETE_TEST_CASE (ID);

alter table PETE_PLSQL_BLOCK_IN_CASE
  add constraint PETE_PLSQL_BLOCK_IN_CASE_CHK01
  check (run_modifier is null or run_modifier in ('ONLY','SKIP')
  );
alter table PETE_PLSQL_BLOCK_IN_CASE
  add constraint PETE_PLSQL_BLOCK_IN_CASE_CHK02
  check (run_modifier is null or stop_on_failure in ('Y','N')
  );
