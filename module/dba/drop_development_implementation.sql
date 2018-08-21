rem Drop schema
prompt .. Dropping user &&l_schema_name
drop user &&l_schema_name cascade;

rem Drop schema - other - used for testing
prompt .. Dropping user &&l_schema_name._OTH
drop user &&l_schema_name._OTH cascade;
