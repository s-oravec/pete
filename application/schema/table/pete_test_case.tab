create table PETE_TEST_CASE
(
  id             INTEGER not null,
  test_script_id INTEGER,
  name           VARCHAR2(255) not null,
  description    VARCHAR2(4000)
)
;
comment on table PETE_TEST_CASE
  is 'Test case';
  
comment on column PETE_TEST_CASE.id
  is 'Surrogate identifier';
comment on column PETE_TEST_CASE.test_script_id
  is 'Test script identifier';
comment on column PETE_TEST_CASE.name
  is 'Test case name';
comment on column PETE_TEST_CASE.description
  is 'Test case description';
  
create index PETE_TEST_CASE_FK01 on PETE_TEST_CASE (TEST_SCRIPT_ID);

alter table PETE_TEST_CASE
  add constraint PETE_TEST_CASE_PK primary key (ID);
alter table PETE_TEST_CASE
  add constraint PETE_TEST_CASE_UK02 unique (NAME);
alter table PETE_TEST_CASE
  add constraint PETE_TEST_CASE_FK01 foreign key (TEST_SCRIPT_ID)
  references PETE_TEST_SCRIPT (ID);
