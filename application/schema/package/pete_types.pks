CREATE OR REPLACE PACKAGE pete_types AS

    -- testing object type subtype
    SUBTYPE typ_object_type IS pete_run_log.object_type%Type;

    -- execution result of test subtype
    SUBTYPE typ_execution_result IS PLS_INTEGER;

    -- object name subtype
    SUBTYPE typ_object_name IS pete_run_log.object_name%Type;

    -- description subtype
    SUBTYPE typ_description IS VARCHAR2(4000);

    -- Boolean - YES/NO subtype
    SUBTYPE typ_YES_NO IS VARCHAR2(1);

    -- Run modifier subytpe
    SUBTYPE typ_run_modifier IS pete_plsql_block_in_case.RUN_MODIFIER%Type;

END;
/
