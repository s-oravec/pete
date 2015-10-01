CREATE OR REPLACE TYPE BODY petet_plsql_block AS

    -------------------------------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION petet_plsql_block
    (
        id              IN INTEGER DEFAULT NULL,
        NAME            IN VARCHAR2,
        description     IN VARCHAR2 DEFAULT NULL,
        owner           IN VARCHAR2 DEFAULT NULL,
        PACKAGE         IN VARCHAR2 DEFAULT NULL,
        method          IN VARCHAR2 DEFAULT NULL,
        anonymous_block IN CLOB DEFAULT NULL
    ) RETURN SELF AS RESULT IS
    BEGIN
        --
        self.id              := id;
        self.NAME            := NAME;
        self.description     := description;
        self.owner           := owner;
        self.PACKAGE         := PACKAGE;
        self.method          := method;
        self.anonymous_block := anonymous_block;
        --
        RETURN;
        --
    END;
END;
/
