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
