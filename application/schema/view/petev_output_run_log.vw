CREATE OR REPLACE FORCE VIEW petev_output_run_log
 AS
SELECT lpad(' ', (LEVEL - 1) * 2, ' ') || --x
       CASE
           WHEN object_type = 'ASSERT' THEN
            '  '
       END || --x
       description || --x
       ' - ' || decode(RESULT, 0, 'SUCCESS', 'FAILURE') || --x
       ' in ' || CASE
           WHEN test_end - test_begin < NUMTODSINTERVAL(1, 'minute') THEN
            '0' || to_char(EXTRACT(SECOND FROM test_end - test_begin)) || 's'
           WHEN test_end - test_begin >= NUMTODSINTERVAL(1, 'day') THEN
            regexp_replace(to_char(test_end - test_begin), '\+0+', '') || 'd'
           ELSE
            regexp_replace(to_char(test_end - test_begin), '\+0+ ', '') || 'h'
       END || --
       CASE
           WHEN l.error_stack IS NOT NULL THEN
            chr(10) || chr(10) || error_stack || chr(10) || error_backtrace ||
            chr(10)
       END log,
       object_type,
       RESULT,
       decode(RESULT, 0, 'SUCCESS', 'FAILURE') result_str
  FROM pete_run_log l
 START WITH id = pete_logger.get_output_run_log_id
CONNECT BY PRIOR id = parent_id
 ORDER BY ID
;
