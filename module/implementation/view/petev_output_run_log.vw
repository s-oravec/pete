CREATE OR REPLACE FORCE VIEW petev_output_run_log
 AS
-- NoFormat Start
WITH run_log AS (
  SELECT rl.*,
         test_end - test_begin                   AS duration,
         to_char(test_end - test_begin )         AS duration_string,
         decode(result, 0, null, ' FAILURE')     AS result_negative_str,
         decode(result, 0, 'SUCCESS', 'FAILURE') AS result_str
    FROM pete_run_log rl
)
--
SELECT connect_by_root(id) as run_log_id,
       -- padding
       lpad(' ', (LEVEL - 1) * 2, ' ') ||
       -- object type - pad Asserts even more - so they don't get mixed with methods
       DECODE(object_type, 'ASSERT', '    ASSERT' || result_negative_str || ' - ') ||
       -- description of method
       description ||
       -- plsql unit and line
       NVL2(plsql_unit, ' @ ' || plsql_unit || ':' || plsql_line, null) ||
       -- timing info - for all except Asserts
       DECODE(object_type, 'ASSERT', NULL,
              -- result status
              ' - ' || result_str || ' in ' ||
              -- timing info
              CASE
                  -- for duration less then minute show seconds only
                  WHEN duration < NUMTODSINTERVAL(1, 'minute')  THEN '0' || to_char(EXTRACT(SECOND FROM duration)) || ' s'
                  -- for duration longer then day show days also
                  WHEN duration >= NUMTODSINTERVAL(1, 'day')    THEN regexp_replace(duration_string, '\+[0-9]+', '') || ' d'
                  -- else show hours only
                  ELSE regexp_replace(duration_string, '\+0+ ', '') || ' h'
              END
       ) ||
       -- error stack
       NVL2(error_stack, chr(10) || chr(10) || error_stack || chr(10) || error_backtrace ||chr(10), null) as log,
       object_type,
       result,
       result_str
  FROM run_log
 START WITH object_type = 'PETE'
CONNECT BY PRIOR id = parent_id
  ORDER BY 1, id
;
