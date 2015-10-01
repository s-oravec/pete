CREATE OR REPLACE TYPE BODY petet_input_argument AS

    -------------------------------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION petet_input_argument
    (
        id          IN INTEGER DEFAULT NULL,
        NAME        IN VARCHAR2,
        VALUE       IN XMLTYPE DEFAULT NULL,
        description IN VARCHAR2 DEFAULT NULL
    ) RETURN SELF AS RESULT IS
    BEGIN
        --
        self.id          := id;
        self.name        := NAME;
        self.value       := VALUE;
        self.description := description;
        --
        RETURN;
        --
    END;
END;
/
