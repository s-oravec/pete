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

    --------------------------------------------------------------------------------
    MEMBER FUNCTION copy RETURN petet_plsql_block IS
    BEGIN
        RETURN NEW petet_plsql_block(self.id,
                                     self.name,
                                     self.description,
                                     self.owner,
                                     self.package,
                                     self.method,
                                     self.anonymous_block);
    END;

    --------------------------------------------------------------------------------
    MEMBER FUNCTION equals
    (
        p_obj_in  IN petet_plsql_block,
        p_deep_in IN VARCHAR2 DEFAULT 'N' --pete_core.g_NO
    ) RETURN VARCHAR2 --pete_core.typ_YES_NO
     IS
    BEGIN
        --
        IF NOT
            (self.id = p_obj_in.id OR (self.id IS NULL AND p_obj_in.id IS NULL))
        THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        IF NOT (self.name = p_obj_in.name OR
            (self.name IS NULL AND p_obj_in.name IS NULL))
        THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        IF NOT (self.description = p_obj_in.description OR
            (self.description IS NULL AND p_obj_in.description IS NULL))
        THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        IF NOT (self.owner = p_obj_in.owner OR
            (self.owner IS NULL AND p_obj_in.owner IS NULL))
        THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        IF NOT (self.package = p_obj_in.package OR
            (self.package IS NULL AND p_obj_in.package IS NULL))
        THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        IF NOT (self.method = p_obj_in.method OR
            (self.method IS NULL AND p_obj_in.method IS NULL))
        THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        IF NOT
            (self.anonymous_block = p_obj_in.anonymous_block OR
            (self.anonymous_block IS NULL AND p_obj_in.anonymous_block IS NULL))
        THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        RETURN pete_core.g_YES;
        --
    END;

END;
/
