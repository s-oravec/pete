create table PETE_TEST_CASE
(
  id             INTEGER not null,
  name           VARCHAR2(255) not null,
  description    VARCHAR2(4000)
)
;
comment on table PETE_TEST_CASE
  is 'Test case';
  
comment on column PETE_TEST_CASE.id
  is 'Surrogate identifier';
comment on column PETE_TEST_CASE.name
  is 'Test case name';
comment on column PETE_TEST_CASE.description
  is 'Test case description';
  
alter table PETE_TEST_CASE
  add constraint PETE_TEST_CASE_PK primary key (ID);
alter table PETE_TEST_CASE
  add constraint PETE_TEST_CASE_UK02 unique (NAME);
