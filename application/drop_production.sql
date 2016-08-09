rem Pete 1.0.0
define g_pete_prod_schema_def = "PETE_010000"

accept g_pete_prod_schema prompt "Pete schema [&&g_pete_prod_schema_def] : " default "&&g_pete_prod_schema_def"

rem Pete Production Schema
prompt .. Dropping &&g_pete_prod_schema user
drop user &&g_pete_prod_schema cascade;
