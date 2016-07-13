create table PETE_TEST_CASE_IN_CASE
(
  id                  INTEGER not null,
  parent_test_case_id INTEGER,
  test_case_id        INTEGER not null,
  position            NUMBER not null,
  stop_on_failure     VARCHAR2(1) default 'N' not null,
  run_modifier        VARCHAR2(30),
  description         VARCHAR2(4000)
)
;

comment on table PETE_TEST_CASE_IN_CASE
  is 'Test case in Test case';
comment on column PETE_TEST_CASE_IN_CASE.id
  is 'Test case in Test case surrogate identifier';
comment on column PETE_TEST_CASE_IN_CASE.parent_test_case_id
  is 'Parent Test case identifier';
comment on column PETE_TEST_CASE_IN_CASE.test_case_id
  is 'Test case identifier';
comment on column PETE_TEST_CASE_IN_CASE.position
  is 'Defines order of test cases in test case';
comment on column PETE_TEST_CASE_IN_CASE.stop_on_failure
  is 'Stops test execution on error';
comment on column PETE_TEST_CASE_IN_CASE.run_modifier
  is 'Run modifier - ONLY - only this Test Case in parent Test Case is executed; SKIP - Test Case in parent Test Case will be skipped';
comment on column PETE_TEST_CASE_IN_CASE.description
  is 'Description';

create index PETE_TEST_CASE_IN_CASE_FK01 on PETE_TEST_CASE_IN_CASE (PARENT_TEST_CASE_ID);
create index PETE_TEST_CASE_IN_CASE_FK02 on PETE_TEST_CASE_IN_CASE (TEST_CASE_ID);

alter table PETE_TEST_CASE_IN_CASE
  add constraint PETE_TEST_CASE_IN_CASE_PK primary key (ID);
alter table PETE_TEST_CASE_IN_CASE
  add constraint PETE_TEST_CASE_IN_CASE_UK1 unique (parent_test_case_id, test_case_id);
alter table PETE_TEST_CASE_IN_CASE
  add constraint PETE_TEST_CASE_IN_CASE_UK2 unique (parent_test_case_id, position);

alter table PETE_TEST_CASE_IN_CASE
  add constraint PETE_TEST_CASE_IN_CASE_FK01 foreign key (parent_test_case_id)
  references PETE_TEST_CASE (ID);
alter table PETE_TEST_CASE_IN_CASE
  add constraint PETE_TEST_CASE_IN_CASE_FK02 foreign key (TEST_CASE_ID)
  references PETE_TEST_CASE (ID);
  
alter table PETE_TEST_CASE_IN_CASE
  add constraint PETE_TEST_CASE_IN_CASE_CHK01
  check (run_modifier is null or run_modifier in ('ONLY','SKIP')
  );

alter table PETE_TEST_CASE_IN_CASE
  add constraint PETE_TEST_CASE_IN_CASE_CHK02
  check (run_modifier is null or stop_on_failure in ('Y','N')
  );

--TODO: constraint or trigger that prohibites cycles
