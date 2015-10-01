create or replace force view petev_test_script_run as
select tmp.code,
       tmp.name,
       tmp.description,
       run.run_id,
       max(case
             when tmp.test_case_id = run.test_case_id
                  and tmp.plsql_block_id = run.plsql_block_id
                  and tmp.position = run.run_order then
              run.expected_result
             else
              null
           end) expected_result,
       max(case
             when tmp.test_case_id = run.test_case_id
                  and tmp.plsql_block_id = run.plsql_block_id
                  and tmp.position = run.run_order then
              run.RESULT
             else
              null
           end) case_result,
       to_char(petef_sum_interval(run.end_time - run.start_time)) run_time,
       min(run.start_time) as test_case_start_timestamp
  from (select ts.id,
               ts.code,
               ts.name,
               ts.description,
               rank() over(partition by ts.id, tcts.test_case_id order by bltc.position desc) my_rank,
               tcts.test_case_id,
               tcts.position,
               bltc.plsql_block_id,
               bltc.position
          from pete_test_script ts, pete_test_case_in_script tcts, pete_plsql_block_in_case bltc
         where ts.id = tcts.test_script_id
           and tcts.test_case_id = bltc.test_case_id) tmp,
       pete_plsql_block_run run
 where tmp.id = run.test_script_id
   and tmp.my_rank = 1
 group by tmp.code, tmp.NAME, tmp.description, run.run_id
 order by tmp.code, test_case_start_timestamp;

