accept l_schema_name prompt "Package &&g_package_name schema [&&g_schema_name] : " default "&&g_schema_name"

@@drop_&&l_environment._implementation.sql

undefine l_schema_name