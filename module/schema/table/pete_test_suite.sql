create table PETE_TEST_SUITE
(
  id              INTEGER not null,
  name            VARCHAR2(255) not null,
  stop_on_failure VARCHAR2(1) default 'N' not null,
  run_modifier    VARCHAR2(30),
  description     VARCHAR2(255)
)
;
comment on table PETE_TEST_SUITE
  is 'Test suite';
  
comment on column PETE_TEST_SUITE.id
  is 'Test suite surrogate identifier';
comment on column PETE_TEST_SUITE.name
  is 'Test suite name';
comment on column PETE_TEST_SUITE.stop_on_failure
  is 'Stops test execution on error';
comment on column PETE_TEST_SUITE.run_modifier
  is 'Run modifier - ONLY - only this Test Suite is executed; SKIP - this Test Suite will be skipped';
comment on column PETE_TEST_SUITE.description
  is 'Test script description';
  
alter table PETE_TEST_SUITE
  add constraint PETE_TEST_SUITE_PK primary key (ID);
alter table PETE_TEST_SUITE
  add constraint PETE_TEST_SUITE_UK1 unique (NAME);

alter table PETE_TEST_SUITE
  add constraint PETE_TEST_SUITE_CHK01
  check (run_modifier is null or run_modifier in ('ONLY','SKIP')
  );
alter table PETE_TEST_SUITE
  add constraint PETE_TEST_SUITE_CHK02
  check (run_modifier is null or stop_on_failure in ('Y','N')
  );
