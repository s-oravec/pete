create table PETE_PLSQL_BLOCK_IN_CASE
(
  id              INTEGER not null,
  test_case_id    INTEGER not null,
  plsql_block_id  INTEGER not null,
  input_param_id  INTEGER,
  output_param_id INTEGER,
  block_order     INTEGER,
  description     varchar2(4000)
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
comment on column PETE_PLSQL_BLOCK_IN_CASE.input_param_id
  is 'Input parameters identifier';
comment on column PETE_PLSQL_BLOCK_IN_CASE.block_order
  is 'Block order in Test case';
comment on column PETE_PLSQL_BLOCK_IN_CASE.description
  is 'Description';

create index PETE_PLSQL_BLOCK_IN_CASE_FK01 on PETE_PLSQL_BLOCK_IN_CASE (PLSQL_BLOCK_ID);
create index PETE_PLSQL_BLOCK_IN_CASE_FK02 on PETE_PLSQL_BLOCK_IN_CASE (INPUT_PARAM_ID);
create index PETE_PLSQL_BLOCK_IN_CASE_FK03 on PETE_PLSQL_BLOCK_IN_CASE (TEST_CASE_ID);

alter table PETE_PLSQL_BLOCK_IN_CASE
  add constraint PETE_PLSQL_BLOCK_IN_CASE_PK primary key (ID);
alter table PETE_PLSQL_BLOCK_IN_CASE
  add constraint PETE_PLSQL_BLOCK_IN_CASE_UK01 unique (TEST_CASE_ID, BLOCK_ORDER);
alter table PETE_PLSQL_BLOCK_IN_CASE
  add constraint PETE_PLSQL_BLOCK_IN_CASE_FK01 foreign key (PLSQL_BLOCK_ID)
  references PETE_PLSQL_BLOCK (ID);
alter table PETE_PLSQL_BLOCK_IN_CASE
  add constraint PETE_PLSQL_BLOCK_IN_CASE_FK02 foreign key (INPUT_PARAM_ID)
  references PETE_INPUT_PARAM (ID);
alter table PETE_PLSQL_BLOCK_IN_CASE
  add constraint PETE_PLSQL_BLOCK_IN_CASE_FK03 foreign key (TEST_CASE_ID)
  references PETE_TEST_CASE (ID);
