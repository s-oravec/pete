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

    --------------------------------------------------------------------------------
    MEMBER FUNCTION copy RETURN petet_test_case IS
        l_plsql_blocks_in_case petet_plsql_blocks_in_case;
    BEGIN
        --
        IF self.plsql_blocks_in_case IS NOT NULL
        THEN
            l_plsql_blocks_in_case := NEW petet_plsql_blocks_in_case();
            l_plsql_blocks_in_case.extend(self.plsql_blocks_in_case.count);
            --
            FOR block_idx IN 1 .. self.plsql_blocks_in_case.count
            LOOP
                l_plsql_blocks_in_case(block_idx) := self.plsql_blocks_in_case(block_idx)
                                                     .copy();
            END LOOP;
            --
        END IF;
        --
        RETURN NEW petet_test_case(self.id,
                                   self.name,
                                   self.description,
                                   l_plsql_blocks_in_case);
    END;

    --------------------------------------------------------------------------------
    MEMBER FUNCTION equals
    (
        p_obj_in  IN petet_test_case,
        p_deep_in IN VARCHAR2 DEFAULT 'N' --pete_core.g_NO
    ) RETURN VARCHAR2 --pete_core.typ_YES_NO
     IS
        l_deep_in            pete_core.typ_YES_NO := nvl(p_deep_in,
                                                         pete_core.g_NO);
        l_plsql_block_equals pete_core.typ_YES_NO;
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
        IF l_deep_in = pete_core.g_YES
        THEN
            --
            IF NOT ((self.plsql_blocks_in_case IS NULL AND
                p_obj_in.plsql_blocks_in_case IS NULL) OR
                self.plsql_blocks_in_case.count =
                p_obj_in.plsql_blocks_in_case.count)
            THEN
                RETURN pete_core.g_NO;
            END IF;
            --
            FOR block_idx IN 1 .. self.plsql_blocks_in_case.count
            LOOP
                l_plsql_block_equals := self.plsql_blocks_in_case(block_idx)
                                        .equals(p_obj_in  => p_obj_in.plsql_blocks_in_case(block_idx),
                                                p_deep_in => l_deep_in);
                IF l_plsql_block_equals = pete_core.g_NO
                THEN
                    RETURN pete_core.g_NO;
                END IF;
            END LOOP;
            --
        END IF;
        --
        RETURN pete_core.g_YES;
        --
    END;
END;
/
