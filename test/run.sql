@&&run_dir_begin

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

@&&run_dir function
@&&run_dir package

set serveroutput on size unlimited
exec pete.run_test_suite;

@&&run_dir_end
