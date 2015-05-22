CREATE OR REPLACE PACKAGE ut_pete_logger AS

    description pete_core.typ_description := 'Pete_logger package tests';

    PROCEDURE log_assert(d VARCHAR2 DEFAULT 'log assert should write FAILURE when test fails');

END;
/
CREATE OR REPLACE PACKAGE BODY ut_pete_logger AS

    PROCEDURE log_assert(d VARCHAR2 DEFAULT 'log assert should write FAILURE when test fails') IS
        l_result pete_run_log.result%TYPE;
        l_id     NUMBER;
    BEGIN
        pete_logger.log_assert(FALSE, 'This should write FAILURE');
        l_id := petes_run_log.currval;
        SELECT prl.result
          INTO l_result
          FROM pete_run_log prl
         WHERE prl.id = l_id;
        IF (l_result <> pete_core.g_FAILURE)
        THEN
            raise_application_error(-20000, 'Log assert did not store failure');
        END IF;
    END;

END;
/
