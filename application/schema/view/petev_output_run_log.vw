CREATE OR REPLACE FORCE VIEW petev_output_run_log
 AS
-- NoFormat Start
WITH params AS 
(
  SELECT pete_logger.get_output_run_log_id  AS run_log_id, 
         pete_logger.get_show_failures_only AS show_failures_only 
    FROM dual
)
--
SELECT lpad(' ', (LEVEL - 1) * 2, ' ') || --x
       CASE object_type
           WHEN 'ASSERT'
           THEN '    ASSERT' || decode(RESULT, 0, null, ' FAILURE') || ' - '
       END || --x       
       description || --x
       NVL2(plsql_unit, ' @ ' || plsql_unit || ':' || plsql_line, null) || --x
       CASE object_type
           WHEN 'ASSERT' THEN NULL
           ELSE ' - ' || decode(RESULT, 0, 'SUCCESS', 'FAILURE') || --x
                ' in ' || CASE 
                            WHEN test_end - test_begin < NUMTODSINTERVAL(1, 'minute')  THEN '0' || to_char(EXTRACT(SECOND FROM test_end - test_begin)) || 's'
                            WHEN test_end - test_begin >= NUMTODSINTERVAL(1, 'day')    THEN regexp_replace(to_char(test_end - test_begin), '\+0+', '') || 'd'
                            ELSE regexp_replace(to_char(test_end - test_begin), '\+0+ ', '') || 'h'
                          END
       END || --
       CASE
           WHEN error_stack IS NOT NULL THEN
            chr(10) || chr(10) || error_stack || chr(10) || error_backtrace ||
            chr(10)
       END log,
       object_type,
       RESULT,
       decode(RESULT, 0, 'SUCCESS', 'FAILURE') result_str
  FROM pete_run_log, params
 START WITH ID = params.run_log_id
CONNECT BY PRIOR ID = parent_id AND (params.show_failures_only = 0 or (params.show_failures_only = 1 and result != 0))
  ORDER BY ID
-- NoFormat End
;
