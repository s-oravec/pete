rem Types
prompt Granting EXECUTE priviledge on type PETET_EXPECTED_RESULT to PUBLIC
grant EXECUTE on PETET_EXPECTED_RESULT to PUBLIC;

prompt Granting EXECUTE priviledge on type PETET_INPUT_ARGUMENT to PUBLIC
grant EXECUTE on PETET_INPUT_ARGUMENT to PUBLIC;

prompt Granting EXECUTE priviledge on type PETET_PLSQL_BLOCK to PUBLIC
grant EXECUTE on PETET_PLSQL_BLOCK to PUBLIC;

prompt Granting EXECUTE priviledge on type PETET_PLSQL_BLOCK_IN_CASE to PUBLIC
grant EXECUTE on PETET_PLSQL_BLOCK_IN_CASE to PUBLIC;

prompt Granting EXECUTE priviledge on type PETET_PLSQL_BLOCKS_IN_CASE to PUBLIC
grant EXECUTE on PETET_PLSQL_BLOCKS_IN_CASE to PUBLIC;

prompt Granting EXECUTE priviledge on type PETET_TEST_CASE to PUBLIC
grant EXECUTE on PETET_TEST_CASE to PUBLIC;

prompt Granting EXECUTE priviledge on type PETET_TEST_CASE_IN_SUITE to PUBLIC
grant EXECUTE on PETET_TEST_CASE_IN_SUITE to PUBLIC;

prompt Granting EXECUTE priviledge on type PETET_TEST_CASES_IN_SUITE to PUBLIC
grant EXECUTE on PETET_TEST_CASES_IN_SUITE to PUBLIC;

prompt Granting EXECUTE priviledge on type PETET_TEST_SUITE to PUBLIC
grant EXECUTE on PETET_TEST_SUITE to PUBLIC;


rem Views
--TODO: ALL/USER/DBA
prompt Granting SELECT priviledge on view PETEV_TEST_SUITE to PUBLIC
grant SELECT on PETEV_TEST_SUITE to PUBLIC;

prompt Granting SELECT priviledge on view PETEV_TEST_CASE_IN_SUITE to PUBLIC
grant SELECT on PETEV_TEST_CASE_IN_SUITE to PUBLIC;

prompt Granting SELECT priviledge on view PETEV_PLSQL_BLOCK_IN_CASE to PUBLIC
grant SELECT on PETEV_PLSQL_BLOCK_IN_CASE to PUBLIC;

prompt Granting SELECT priviledge on view PETEV_TEST_CASE to PUBLIC
grant SELECT on PETEV_TEST_CASE to PUBLIC;

prompt Granting SELECT priviledge on view PETEV_EXPECTED_RESULT to PUBLIC
grant SELECT on PETEV_EXPECTED_RESULT to PUBLIC;

prompt Granting SELECT priviledge on view PETEV_INPUT_ARGUMENT to PUBLIC
grant SELECT on PETEV_INPUT_ARGUMENT to PUBLIC;

prompt Granting SELECT priviledge on view PETEV_PLSQL_BLOCK to PUBLIC
grant SELECT on PETEV_PLSQL_BLOCK to PUBLIC;

rem Packages
prompt Grantint EXECUTE privilege on package PETE_TYPES
grant EXECUTE on PETE_TYPES to PUBLIC;

prompt Granting EXECUTE privilege on package PETE
grant EXECUTE on PETE to PUBLIC;

prompt Granting EXECUTE privilege on package PETE_ASSERT
grant EXECUTE on PETE_ASSERT to PUBLIC;

prompt Granting EXECUTE privilege on package PETE_CONFIG
grant EXECUTE on PETE_CONFIG to PUBLIC;

prompt Granting EXECUTE privilege on package PETE_CONFIGURATION_RUNNER_ADM
grant EXECUTE on PETE_CONFIGURATION_RUNNER_ADM to PUBLIC;

