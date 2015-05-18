CREATE OR REPLACE PACKAGE ut_pete_logger AS
    description pete_core.typ_description := 'Pete_logger package tests';

    PROCEDURE log_assert(d VARCHAR2 DEFAULT 'log assert should write FAILURE when test fails');
END;
/
CREATE OR REPLACE PACKAGE BODY ut_pete_logger AS
    PROCEDURE log_assert(d VARCHAR2 DEFAULT 'log assert should write FAILURE when test fails') IS
      l_result pete_run_log.result%type;
      l_id number;
    BEGIN
        pete_logger.log_assert(false, 'This should write FAILURE');
        l_id := petes_run_log.currval;
        select prl.result into l_result from pete_run_log prl where prl.id = l_id;
        if (l_result <> pete_core.g_FAILURE) then 
          raise_application_error(-20000, 'Log assert did not store failure');
        end if;
    END;
END;
/
