create table PETE_PLSQL_BLOCK
(
  id              INTEGER not null,
  test_script_id  INTEGER,
  name            VARCHAR2(255) not null,
  description     VARCHAR2(255),
  owner           VARCHAR2(32),
  package         VARCHAR2(32),
  method          VARCHAR2(32),
  anonymous_block CLOB
)
;

comment on table PETE_PLSQL_BLOCK
  is 'PLSQL block';
  
comment on column PETE_PLSQL_BLOCK.id
  is 'PLSQL block surrogate identifier';
comment on column PETE_PLSQL_BLOCK.test_script_id
  is 'Test script identifier';
comment on column PETE_PLSQL_BLOCK.name
  is 'PLSQL block name';
comment on column PETE_PLSQL_BLOCK.description
  is 'PLSQL block description';
comment on column PETE_PLSQL_BLOCK.owner
  is 'Owner';
comment on column PETE_PLSQL_BLOCK.package
  is 'Package';
comment on column PETE_PLSQL_BLOCK.method
  is 'Method';
comment on column PETE_PLSQL_BLOCK.anonymous_block
  is 'Anonymous PLSQL block declaration';
  
create index PETE_PLSQL_BLOCK_FK01 on PETE_PLSQL_BLOCK (TEST_SCRIPT_ID);

alter table PETE_PLSQL_BLOCK
  add constraint PETE_PLSQL_BLOCK_PK primary key (ID);
alter table PETE_PLSQL_BLOCK
  add constraint PETE_PLSQL_BLOCK_FK01 foreign key (TEST_SCRIPT_ID)
  references PETE_TEST_SCRIPT (ID);
  
alter table PETE_PLSQL_BLOCK
  add constraint PETE_PLSQL_BLOCK_CHK01
  check (
  (ANONYMOUS_BLOCK is null and METHOD is not null) or
  (ANONYMOUS_BLOCK is not null and OWNER is null and package is null and METHOD is null)
  );
