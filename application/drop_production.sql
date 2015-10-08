rem Pete 1.0.0
define g_pete_production_schema = "PETE_010000"

rem Pete Development Schema
prompt drop &&g_pete_production_schema user
drop user &&g_pete_production_schema cascade;
