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
        --asserts
        pete_assert.is_not_null(a_value_in   => NAME,
                                a_comment_in => 'PETET_PLSQL_BLOCK.NAME should be not null');
        -- NoFormat Start
        pete_assert.this(a_value_in => (anonymous_block IS NULL AND method IS NOT NULL) OR
                                       (anonymous_block IS NOT NULL AND owner IS NULL AND PACKAGE IS NULL AND method IS NULL),
                         a_comment_in => 'either PETET_PLSQL_BLOCK.ANONYMOUS_BLOCK or [PETET_PLSQL_BLOCK.OWNER, PETET_PLSQL_BLOCK.PACKAGE] PETET_PLSQL_BLOCK.METHOD should be set');
        -- NoFormat End
        --
        --set
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
        a_obj_in  IN petet_plsql_block,
        a_deep_in IN VARCHAR2 DEFAULT 'N' --pete_core.g_NO
    ) RETURN VARCHAR2 --pete_core.typ_YES_NO
     IS
    BEGIN
        --
        IF(self.id IS NULL AND a_obj_in.id IS NOT NULL)
           OR (self.id IS NOT NULL AND a_obj_in.id IS NULL)
           OR (self.id != a_obj_in.id)
        THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        IF (self.name IS NULL AND a_obj_in.name IS NOT NULL)
           OR (self.name IS NOT NULL AND a_obj_in.name IS NULL)
           OR (self.name != a_obj_in.name)
        THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        IF (self.description IS NULL AND a_obj_in.description IS NOT NULL)
           OR (self.description IS NOT NULL AND a_obj_in.description IS NULL)
           OR (self.description != a_obj_in.description)
        THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        IF (self.owner IS NULL AND a_obj_in.owner IS NOT NULL)
           OR (self.owner IS NOT NULL AND a_obj_in.owner IS NULL)
           OR (self.owner != a_obj_in.owner)
        THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        IF (self.package IS NULL AND a_obj_in.package IS NOT NULL)
           OR (self.package IS NOT NULL AND a_obj_in.package IS NULL)
           OR (self.package != a_obj_in.package)
        THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        IF (self.method IS NULL AND a_obj_in.method IS NOT NULL)
           OR (self.method IS NOT NULL AND a_obj_in.method IS NULL)
           OR (self.method != a_obj_in.method)
        THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        IF (self.anonymous_block IS NULL AND a_obj_in.anonymous_block IS NOT NULL)
           OR (self.anonymous_block IS NOT NULL AND a_obj_in.anonymous_block IS NULL)
           OR (self.anonymous_block != a_obj_in.anonymous_block)
        THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        RETURN pete_core.g_YES;
        --
    END;

END;
/
