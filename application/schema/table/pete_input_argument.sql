create table PETE_INPUT_ARGUMENT
(
  id             INTEGER not null,
  test_script_id INTEGER,
  name           VARCHAR2(255) not null,
  value          XMLTYPE,
  description    VARCHAR2(255)
)
;
comment on table PETE_INPUT_ARGUMENT
  is 'PLSQL block input ARGUMENTeters';
  
comment on column PETE_INPUT_ARGUMENT.id
  is 'Input ARGUMENTeter surrogate key';
comment on column PETE_INPUT_ARGUMENT.test_script_id
  is 'Test script identifier [deprecated?]';
comment on column PETE_INPUT_ARGUMENT.name
  is 'Input ARGUMENTeter name';
comment on column PETE_INPUT_ARGUMENT.value
  is 'XML for input ARGUMENTeter of PLSQL block';
comment on column PETE_INPUT_ARGUMENT.description
  is 'Input ARGUMENTeter description';
  
create index PETE_INPUT_ARGUMENT_FK01 on PETE_INPUT_ARGUMENT (TEST_SCRIPT_ID);

alter table PETE_INPUT_ARGUMENT
  add constraint PETE_INPUT_ARGUMENT_PK primary key (ID);
alter table PETE_INPUT_ARGUMENT
  add constraint PETE_INPUT_ARGUMENT_UK01 unique (NAME, TEST_SCRIPT_ID);
alter table PETE_INPUT_ARGUMENT
  add constraint PETE_INPUT_ARGUMENT_FK01 foreign key (TEST_SCRIPT_ID)
  references PETE_TEST_SCRIPT (ID);
