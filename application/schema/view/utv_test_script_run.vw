CREATE OR REPLACE FORCE VIEW UTV_TEST_SCRIPT_RUN AS
SELECT tmp.code
      ,tmp.NAME
      ,tmp.description
      ,run.run_group_id
      ,MAX(CASE
             WHEN tmp.test_case_id = run.test_case_id
                  AND tmp.plsql_block_id = run.plsql_block_id
                  AND tmp.block_order = run.run_order THEN
              run.expected_result
             ELSE
              NULL
           END) expected_result
      ,MAX(CASE
             WHEN tmp.test_case_id = run.test_case_id
                  AND tmp.plsql_block_id = run.plsql_block_id
                  AND tmp.block_order = run.run_order THEN
              run.RESULT
             ELSE
              NULL
           END) case_result
      ,to_char(f_sum_interval(run.end_time - run.start_time)) run_time
      ,MIN(run.start_time) AS test_case_start_timestamp
  FROM (SELECT ts.id
              ,ts.code
              ,ts.NAME
              ,ts.description
              ,rank() over(PARTITION BY ts.id, tcts.test_case_id ORDER BY bltc.block_order DESC) my_rank
              ,tcts.test_case_id
              ,tcts.script_order
              ,bltc.plsql_block_id
              ,bltc.block_order
          FROM ut_test_script ts, ut_test_case_in_script tcts, ut_plsql_block_in_case bltc
         WHERE ts.id = tcts.test_script_id
           AND tcts.test_case_id = bltc.test_case_id) tmp
      ,ut_plsql_block_run run
 WHERE tmp.id = run.test_script_id
   AND tmp.my_rank = 1
 GROUP BY tmp.code, tmp.NAME, tmp.description, run.run_group_id
 ORDER BY tmp.code, test_case_start_timestamp;

