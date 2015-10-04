CREATE OR REPLACE TYPE BODY petet_expected_result AS

    -------------------------------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION petet_expected_result
    (
        id          IN INTEGER DEFAULT NULL,
        NAME        IN VARCHAR2,
        VALUE       IN XMLTYPE DEFAULT NULL,
        description IN VARCHAR2 DEFAULT NULL
    ) RETURN SELF AS RESULT IS
    BEGIN
        --
        --asserts
        pete_assert.is_not_null(a_value_in   => NAME,
                                a_comment_in => 'PETET_EXPECTED_RESULT.NAME should be not null');
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
    MEMBER FUNCTION copy RETURN petet_expected_result IS
    BEGIN
        RETURN NEW petet_expected_result(self.id,
                                         self.name,
                                         self.value,
                                         self.description);
    END;

    --------------------------------------------------------------------------------  
    MEMBER FUNCTION equals
    (
        a_obj_in  IN petet_expected_result,
        a_deep_in IN VARCHAR2 DEFAULT 'N' --pete_core.g_NO
    ) RETURN VARCHAR2 --pete_core.typ_YES_NO
     IS
    BEGIN
        --
        IF (self.id IS NULL AND a_obj_in.id IS NOT NULL)
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
        IF NOT pete_assert.eq(a_expected_in => self.value,
                              a_actual_in   => a_obj_in.value)
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
        RETURN pete_core.g_YES;
        --
    END;
END;
/
