CREATE OR REPLACE TYPE BODY petet_test_case AS

    -------------------------------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION petet_test_case
    (
        id                   IN INTEGER DEFAULT NULL,
        NAME                 IN VARCHAR2,
        description          IN VARCHAR2 DEFAULT NULL,
        plsql_blocks_in_case IN petet_plsql_blocks_in_case DEFAULT NULL
    ) RETURN SELF AS RESULT IS
    BEGIN
        --
        self.id                   := id;
        self.name                 := NAME;
        self.description          := description;
        self.plsql_blocks_in_case := plsql_blocks_in_case;
        --
        RETURN;
        --
    END;
END;
/
