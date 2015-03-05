CREATE OR REPLACE FORCE VIEW UTV_TEST_CASE_RUN AS
SELECT tmp.code
      ,tmp.NAME
      ,tmp.description
      ,run.run_group_id
      ,MAX(CASE
         WHEN tmp.plsql_block_id = run.plsql_block_id
              AND tmp.block_order = run.run_order THEN
          run.expected_result
         ELSE
          NULL
       END) expected_result
      ,MAX(CASE
         WHEN tmp.plsql_block_id = run.plsql_block_id
              AND tmp.block_order = run.run_order THEN
          run.result
         ELSE
          NULL
       END) case_RESULT
      ,to_char(f_sum_interval(run.end_time - run.start_time)) RUN_TIME
      ,MIN(run.start_time) AS TEST_CASE_START_TIMESTAMP
  FROM (SELECT tc.id
              ,tc.code
              ,tc.NAME
              ,tc.description
              ,rank() over(PARTITION BY tc.id ORDER BY bltc.block_order DESC) my_rank
              ,bltc.plsql_block_id
              ,bltc.block_order
          FROM ut_test_case tc, ut_plsql_block_in_case bltc
         WHERE tc.id = bltc.test_case_id) tmp
      ,ut_plsql_block_run run
 WHERE tmp.id = run.test_case_id
   AND tmp.my_rank = 1
GROUP BY tmp.code
      ,tmp.NAME
      ,tmp.description
      ,run.run_group_id
ORDER BY tmp.code, TEST_CASE_START_TIMESTAMP;

