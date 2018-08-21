define l_schema_name  = &&g_schema_name
define l_schema_pwd   = &&g_schema_pwd
define l_schema_tbspc = &&g_schema_tbspc
define l_temp_tbspc   = &&g_temp_tbspc

define l_schema_name_oth   = &&g_schema_name._OTH

@@create_&&l_environment._implementation.sql

undefine l_schema_name
undefine l_schema_pwd
undefine l_schema_tbspc
undefine l_temp_tbspc