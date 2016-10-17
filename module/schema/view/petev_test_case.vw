CREATE OR REPLACE FORCE view petev_test_case AS
SELECT tc.id,
       tc.name,
       tc.description,
       petet_test_case(tc.id,
                       tc.name,
                       tc.description,
                       (SELECT CAST(COLLECT(bic.plsql_block_in_case) AS
                                    petet_plsql_blocks_in_case)
                          FROM petev_plsql_block_in_case bic
                         WHERE bic.test_case_id = tc.id)) AS test_case
  FROM pete_test_case tc;
