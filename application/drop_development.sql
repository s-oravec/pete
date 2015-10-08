rem Pete 1.0.0
define g_pete_dev_schema       = "PETE_010000_DEV"
define g_pete_dev_other_schema = "PETE_010000_OTH"

rem Pete Development Schema
prompt drop &&g_pete_dev_schema user
drop user &&g_pete_dev_schema cascade;

rem Pete Development Other Schema - for Multischema Dev/Test
prompt drop &&g_pete_dev_other_schema user
drop user &&g_pete_dev_other_schema cascade;
