@&&run_dir_begin

prompt Drop all test packages
BEGIN
    FOR obj IN (SELECT object_name
                  FROM user_objects
                 WHERE object_name LIKE 'UT%'
                   AND object_type = 'PACKAGE')
    LOOP
        EXECUTE IMMEDIATE 'drop package ' || obj.object_name;
    END LOOP;
END;
/

prompt Recreate all test packages
@&&run_dir function
@&&run_dir package
@&&run_dir type

prompt Recompile schema object bodies with debug
SET SERVEROUTPUT ON SIZE UNLIMITED
SET lines 255
DECLARE
BEGIN
    FOR compile_statement IN (SELECT REPLACE(CASE object_type
                                                 WHEN 'PACKAGE BODY' THEN
                                                  'ALTER PACKAGE #objectName# COMPILE DEBUG BODY'
                                                 WHEN 'TYPE BODY' THEN
                                                  'ALTER TYPE #objectName# COMPILE DEBUG BODY'
                                                 WHEN 'PROCEDURE' THEN
                                                  'ALTER PROCEDURE #objectName# COMPILE DEBUG'
                                                 WHEN 'FUNCTION' THEN
                                                  'ALTER FUNCTION #objectName# COMPILE DEBUG'
                                             END,
                                             '#objectName#',
                                             object_name) AS text
                                FROM user_objects
                               WHERE object_type IN ('PACKAGE BODY',
                                                     'TYPE BODY',
                                                     'PROCEDURE',
                                                     'FUNCTION'))
    LOOP
        --dbms_output.put_line('EXEC IMM> ' || compile_statement.text);
        EXECUTE IMMEDIATE compile_statement.text;
    END LOOP;
END;
/

prompt Run Pete Testing Suite
set serveroutput on size unlimited
exec pete.run_test_suite(a_suite_name_in => user);

@&&run_dir_end
