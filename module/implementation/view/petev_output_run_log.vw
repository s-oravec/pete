create or replace force view petev_output_run_log
 as
-- NoFormat Start
with 
run_log as (
    select rl.*,
           test_end - test_begin as duration,
           to_char(test_end - test_begin) as duration_string,
           decode(result, 0, null, ' FAILURE') as result_negative_str,
           decode(result, 0, 'SUCCESS', 'FAILURE') as result_str
      from pete_run_log rl
)
--
select connect_by_root(id) as run_log_id,
       -- padding
       lpad(' ', (level - 1) * 2, ' ') ||
       -- object type - pad Asserts even more - so they don't get mixed with methods
        DECODE(object_type, 'ASSERT', '    ASSERT' || result_negative_str || ' - ') ||
       -- description of method
        description ||
       -- plsql unit and line
        NVL2(plsql_unit, ' @ ' || plsql_unit || ':' || plsql_line, null) ||
       -- timing info - for all except Asserts
        DECODE(object_type,
               'ASSERT',
               null,
               -- result status
               ' - ' || result_str || ' in ' ||
               -- timing info
                case
                -- for duration less then minute show seconds only
                    when duration < NUMTODSINTERVAL(1, 'minute') then
                     '0' || to_char(EXTRACT(second from duration)) || ' s'
                -- for duration longer then day show days also
                    when duration >= NUMTODSINTERVAL(1, 'day') then
                     regexp_replace(duration_string, '\+[0-9]+', '') || ' d'
                -- else show hours only
                    else
                     regexp_replace(duration_string, '\+0+ ', '') || ' h'
                end) ||
       -- error stack
        NVL2(error_stack, chr(10) || chr(10) || error_stack || chr(10) || error_backtrace || chr(10), null) as log,
       object_type,
       result,
       result_str
  from run_log
 start with object_type = 'PETE'
connect by prior id = parent_id
 order by 1, id
;
