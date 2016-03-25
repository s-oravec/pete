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
