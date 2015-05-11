create table PETE_EXPECTED_RESULT
(
  id             INTEGER not null,
  test_script_id INTEGER,
  name           VARCHAR2(255) not null,
  value          XMLTYPE,
  description    VARCHAR2(255)
)
;
comment on table PETE_EXPECTED_RESULT
  is 'PLSQL block expected output parameters';
  
comment on column PETE_EXPECTED_RESULT.id
  is 'Surrogate key';
comment on column PETE_EXPECTED_RESULT.test_script_id
  is 'Test script identifier [deprecated?]';
comment on column PETE_EXPECTED_RESULT.name
  is 'Expected result name';
comment on column PETE_EXPECTED_RESULT.value
  is 'XML for expected result of PLSQL block';
comment on column PETE_EXPECTED_RESULT.description
  is 'Expected result description';

create index PETE_EXPECTED_RESULT_FK01 on PETE_EXPECTED_RESULT (TEST_SCRIPT_ID);

alter table PETE_EXPECTED_RESULT
  add constraint PETE_EXPECTED_RESULT_PK primary key (ID);
alter table PETE_EXPECTED_RESULT
  add constraint PETE_EXPECTED_RESULT_UK01 unique (NAME, TEST_SCRIPT_ID);
alter table PETE_EXPECTED_RESULT
  add constraint PETE_EXPECTED_RESULT_FK01 foreign key (TEST_SCRIPT_ID)
  references PETE_TEST_SCRIPT (ID);
