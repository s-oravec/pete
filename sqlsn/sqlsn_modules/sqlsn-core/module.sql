set verify off

--define global sqlsn-core path
define g_sqlsn_path = &1

--load default config
@&&g_sqlsn_path./lib/conf/conf.sql

--sqlsn core command scripts
define sqlsn_require           = "&&g_sqlsn_path./lib/command/sqlsn_require.sql"
define sqlsn_require_from_path = "&&g_sqlsn_path./lib/command/sqlsn_require_from_path.sql"

--logging stubs
define log_pause = "&&g_sqlsn_path./lib/command/sqlsn_noop.sql"
define log_continue = "&&g_sqlsn_path./lib/command/sqlsn_noop.sql"
