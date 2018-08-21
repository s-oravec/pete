-- Create table
create table PETE_CONFIGURATION
(
  key         VARCHAR2(255) not null,
  value       VARCHAR2(4000),
  description VARCHAR2(4000)
)
;
-- Create/Recreate primary, unique and foreign key constraints 
alter table PETE_CONFIGURATION
  add constraint PETE_CONFIGURATION_PK primary key (KEY)
;
