create or replace force view petev_output_run_log
 as
SELECT lpad(' ', (LEVEL - 1) * 2, ' ') || --x
       description || --x
       ' - ' || RESULT || --x
       CASE
           WHEN l.error_message IS NOT NULL THEN
            chr(10) || chr(10) || error_message || chr(10) || chr(10)
       end log
  FROM pete_run_log l
 START WITH id = pete_logger.get_output_run_log_id
CONNECT BY PRIOR id = parent_id
 ORDER BY id
;
