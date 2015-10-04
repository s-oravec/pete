CREATE OR REPLACE PACKAGE pete_exception AS

    --
    -- Thrown if the set method could not find record being updated
    ge_record_not_found EXCEPTION;
    gc_RECORD_NOT_FOUND CONSTANT PLS_INTEGER := -20001;
    PRAGMA EXCEPTION_INIT(ge_record_not_found, -20001);

END;
/
