CREATE OR REPLACE PACKAGE ut_pete_functions AS

    description petep_logger.typ_description := 'Sum interval SQL function';

    PROCEDURE sum_interval(description IN petep_logger.typ_description := 'should work as expected');

END;
/
CREATE OR REPLACE PACKAGE BODY ut_pete_functions AS

    PROCEDURE sum_interval(description IN petep_logger.typ_description) IS
        a INTERVAL DAY TO SECOND := numtodsinterval(1, 'hour');
        b INTERVAL DAY TO SECOND := numtodsinterval(1, 'hour');
        c INTERVAL DAY TO SECOND;
    BEGIN
        --log
        petep_logger.log_method(description);
        --test
        SELECT petef_sum_interval(x)
          INTO c
          FROM (SELECT a AS x FROM dual UNION ALL SELECT b AS x FROM dual);
        --assert
        petep_assert.this(a + b = c);
    END;

END;
/
