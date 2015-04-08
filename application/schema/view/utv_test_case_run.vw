create or replace force view utv_test_case_run as
select tmp.code,
       tmp.NAME,
       tmp.description,
       run.run_id,
       max(case
             when tmp.plsql_block_id = run.plsql_block_id
                  and tmp.block_order = run.run_order then
              run.expected_result
             else
              null
           end) expected_result,
       max(case
             when tmp.plsql_block_id = run.plsql_block_id
                  and tmp.block_order = run.run_order then
              run.result
             else
              null
           end) case_RESULT,
       to_char(utf_sum_interval(run.end_time - run.start_time)) RUN_TIME,
       min(run.start_time) as TEST_CASE_START_TIMESTAMP
  from (select tc.id,
               tc.code,
               tc.NAME,
               tc.description,
               rank() over(partition by tc.id order by bltc.block_order desc) my_rank,
               bltc.plsql_block_id,
               bltc.block_order
          from ut_test_case tc, ut_plsql_block_in_case bltc
         where tc.id = bltc.test_case_id) tmp,
       ut_plsql_block_run run
 where tmp.id = run.test_case_id
   and tmp.my_rank = 1
 group by tmp.code, tmp.NAME, tmp.description, run.run_id
 order by tmp.code, TEST_CASE_START_TIMESTAMP;

