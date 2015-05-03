@&&run_dir_begin

@&&run_dir function
@&&run_dir package

set pages 0
set lines 255

SELECT lpad(' ', (LEVEL - 1) * 2, ' ') || --x
       description || --x
       ' - ' || RESULT || --x
       CASE
           WHEN l.error_message IS NOT NULL THEN
            chr(10) || chr(10) || error_message || chr(10) || chr(10)
       END
  FROM pete_run_log l
 START WITH parent_id IS NULL
CONNECT BY PRIOR id = parent_id
 ORDER BY id;


@&&run_dir_end
