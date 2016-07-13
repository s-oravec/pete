create table PETE_TEST_CASE
(
  id              INTEGER not null,
  name            VARCHAR2(255) not null,
  stop_on_failure VARCHAR2(1) default 'N' not null,
  run_modifier    VARCHAR2(30),
  description     VARCHAR2(4000)
)
;
comment on table PETE_TEST_CASE
  is 'Test case';
  
comment on column PETE_TEST_CASE.id
  is 'Surrogate identifier';
comment on column PETE_TEST_CASE.name
  is 'Test case name';
comment on column PETE_TEST_CASE.stop_on_failure
  is 'Stops test execution on error - serves as default for case in case relation';
comment on column PETE_TEST_CASE.run_modifier
  is 'Run modifier - ONLY - only this Test Case (and its subtree) is executed; SKIP - this Test Case (and its subtree) will be skipped - serves as default for case in case relation';
comment on column PETE_TEST_CASE.description
  is 'Test case description';
  
alter table PETE_TEST_CASE
  add constraint PETE_TEST_CASE_PK primary key (ID);
alter table PETE_TEST_CASE
  add constraint PETE_TEST_CASE_UK02 unique (NAME);
