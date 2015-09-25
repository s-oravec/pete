create table PETE_TEST_CASE_IN_SUITE
(
  id              INTEGER not null,
  test_suite_id   INTEGER not null,
  test_case_id    INTEGER not null,
  case_order      INTEGER not null,
  stop_on_failure VARCHAR2(1) default 'N' not null,
  run_modifier    VARCHAR2(30),
  description     VARCHAR2(4000)
)
;

comment on table PETE_TEST_CASE_IN_SUITE
  is 'Test case in Test script';
comment on column PETE_TEST_CASE_IN_SUITE.id
  is 'Test case in Test script surrogate identifier';
comment on column PETE_TEST_CASE_IN_SUITE.test_suite_id
  is 'Test script identifier';
comment on column PETE_TEST_CASE_IN_SUITE.test_case_id
  is 'Test case identifier';
comment on column PETE_TEST_CASE_IN_SUITE.case_order
  is 'Defines order of test cases in test script';
comment on column PETE_TEST_CASE_IN_SUITE.stop_on_failure
  is 'Stops test execution on error';
comment on column PETE_TEST_CASE_IN_SUITE.run_modifier
  is 'Run modifier - ONLY - only this PLSQL block in Test Case is executed; SKIP - this PLSQL block in Test Case will be skipped';
comment on column PETE_TEST_CASE_IN_SUITE.description
  is 'Description';
  
create index PETE_TEST_CASE_IN_SUITE_FK01 on PETE_TEST_CASE_IN_SUITE (TEST_CASE_ID);
create index PETE_TEST_CASE_IN_SUITE_FK02 on PETE_TEST_CASE_IN_SUITE (TEST_SUITE_ID);

alter table PETE_TEST_CASE_IN_SUITE
  add constraint PETE_TEST_CASE_IN_SUITE_PK primary key (ID);
alter table PETE_TEST_CASE_IN_SUITE
  add constraint PETE_TEST_CASE_IN_SUITE_FK01 foreign key (TEST_CASE_ID)
  references PETE_TEST_CASE (ID);
alter table PETE_TEST_CASE_IN_SUITE
  add constraint PETE_TEST_CASE_IN_SUITE_FK02 foreign key (TEST_SUITE_ID)
  references PETE_TEST_SUITE (ID);
  
alter table PETE_TEST_CASE_IN_SUITE
  add constraint PETE_TEST_CASE_IN_SUITE_CHK01
  check (run_modifier is null or run_modifier in ('ONLY','SKIP')
  );

alter table PETE_TEST_CASE_IN_SUITE
  add constraint PETE_TEST_CASE_IN_SUITE_CHK02
  check (run_modifier is null or stop_on_failure in ('Y','N')
  );
