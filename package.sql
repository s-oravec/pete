rem TODO sync package.json version with version defined here
rem TODO call package.sql from sqlsnrc.sql

rem TODO remove and replace with g_sql_version or g_schema_name_base
define g_version = "000200"

rem SQL name compatible version string
define g_sql_version = &&g_version

rem schema name base
define g_schema_name_base = &&g_module_name._&&g_sql_version

rem full semver version string
define g_semver_version = "0.2.0"