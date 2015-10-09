PROCEDURE &"Method name"(d VARCHAR2) IS
    l_thrown BOOLEAN := FALSE;
BEGIN
    --log
    pete.set_method_description(d);
    --test
    BEGIN
        [#] --TODO: add method call/expression/...
        l_thrown := FALSE;
    EXCEPTION
        WHEN OTHERS THEN
            l_thrown := TRUE;
    END;
    --assert
    IF NOT l_thrown
    THEN
        raise_application_error(-20000,
                                q'{It should throw and it doesn't, so fix it!}'); --TODO: add description
    END IF;
END &"Method name";
