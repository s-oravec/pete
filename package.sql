rem TODO sync package.json version with version defined here
rem TODO call package.sql from sqlsnrc.sql

rem Module name
define g_module_name="PETE"

rem SQL name compatible version string
define g_sql_version = "000200"

rem schema name base
define g_schema_name_base = &&g_module_name._&&g_sql_version

rem full semver version string
define g_semver_version = "0.2.0"