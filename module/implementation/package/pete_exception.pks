create or replace package pete_exception as

    --
    -- Thrown if the set method could not find record being updated
    ge_record_not_found exception;
    gc_RECORD_NOT_FOUND constant pls_integer := -20001;
    pragma exception_init(ge_record_not_found, -20001);

end;
/
