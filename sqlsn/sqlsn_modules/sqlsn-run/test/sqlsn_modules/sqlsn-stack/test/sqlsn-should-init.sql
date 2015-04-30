--case
prompt
prompt * case [sqlsn should init]

--assertions
prompt - sqlsn path [&&g_sqlsn_path] should be [sqlsn].
prompt - sqlsn modules path [&&g_sqlsn_modules_path] should be [..].
