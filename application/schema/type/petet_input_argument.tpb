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

    --------------------------------------------------------------------------------
    MEMBER FUNCTION copy RETURN petet_input_argument IS
    BEGIN
        RETURN NEW petet_input_argument(self.id,
                                        self.name,
                                        self.value,
                                        self.description);
    END;

    --------------------------------------------------------------------------------
    MEMBER FUNCTION equals
    (
        p_obj_in  IN petet_input_argument,
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
        IF NOT (self.value.getclobval = p_obj_in.value.getclobval OR
            (self.value IS NULL AND p_obj_in.value IS NULL))
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
        RETURN pete_core.g_YES;
        --
    END;

END;
/
