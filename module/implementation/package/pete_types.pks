create or replace package pete_types as

    -- testing object type subtype
    subtype typ_object_type is pete_run_log.object_type%type;

    -- execution result of test subtype
    subtype typ_execution_result is pls_integer;

    -- object name subtype
    subtype typ_object_name is pete_run_log.object_name%type;

    -- description subtype
    subtype typ_description is varchar2(4000);

    -- Boolean - YES/NO subtype
    subtype typ_YES_NO is varchar2(1);

    -- string - SKIP | ONLY
    subtype typ_RUN_MODIFIER is varchar2(10);

end;
/
