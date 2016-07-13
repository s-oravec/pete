CREATE OR REPLACE Type BODY petet_test_case AS

    -------------------------------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION petet_test_case
    (
        ID                    IN INTEGER DEFAULT NULL,
        Name                  IN VARCHAR2,
        stop_on_failure       IN VARCHAR2 DEFAULT 'N',
        run_modifier          IN VARCHAR2 DEFAULT NULL,
        Description           IN VARCHAR2 DEFAULT NULL,
        plsql_blocks_in_case  IN petet_plsql_blocks_in_case DEFAULT NULL,
        test_case_ids_in_case IN petet_test_case_ids_in_case DEFAULT NULL
    ) RETURN SELF AS Result IS
    BEGIN
        --
        --asserts
        pete_assert.is_not_null(a_value_in => Name, a_comment_in => 'PETET_TEST_CASE.NAME should be not null');
        --Test Case has either Test Cases or PLSQL Blocks, but not both
        IF plsql_blocks_in_case IS NOT NULL AND plsql_blocks_in_case.count > 0 AND test_case_ids_in_case IS NOT NULL AND
           test_case_ids_in_case.count > 0 THEN
            pete_assert.fail(a_comment_in => 'PETET_TEST_CASE can have either PLSQL_BLOCKS_IN_CASE or TEST_CASE_IDS_IN_CASE, but not both');
        END IF;
        --
        self.id                    := ID;
        self.name                  := Name;
        self.stop_on_failure       := stop_on_failure;
        self.run_modifier          := run_modifier;
        self.description           := Description;
        self.plsql_blocks_in_case  := plsql_blocks_in_case;
        self.test_case_ids_in_case := test_case_ids_in_case;
        --
        RETURN;
        --
    END;

    --------------------------------------------------------------------------------
    MEMBER FUNCTION copy RETURN petet_test_case IS
        l_plsql_blocks_in_case petet_plsql_blocks_in_case;
    BEGIN
        --
        IF self.plsql_blocks_in_case IS NOT NULL THEN
            l_plsql_blocks_in_case := NEW petet_plsql_blocks_in_case();
        
            IF self.plsql_blocks_in_case.count > 0 THEN
                l_plsql_blocks_in_case.extend(self.plsql_blocks_in_case.count);
                --
                FOR block_idx IN 1 .. self.plsql_blocks_in_case.count LOOP
                    l_plsql_blocks_in_case(block_idx) := self.plsql_blocks_in_case(block_idx);
                END LOOP;
            END IF;
            --
        END IF;
        --
        RETURN NEW petet_test_case(self.id,
                                   self.name,
                                   self.stop_on_failure,
                                   self.run_modifier,
                                   self.description,
                                   l_plsql_blocks_in_case,
                                   self.test_case_ids_in_case);
    END;

    --------------------------------------------------------------------------------
    MEMBER FUNCTION equals
    (
        a_obj_in  IN petet_test_case,
        a_deep_in IN VARCHAR2 DEFAULT 'N' --pete_core.g_NO
    ) RETURN VARCHAR2 --pete_types.typ_YES_NO
     IS
        l_deep_in pete_types.typ_YES_NO := nvl(a_deep_in, pete_core.g_NO);
        l_equals  pete_types.typ_YES_NO;
    BEGIN
        --
        IF (self.id IS NULL AND a_obj_in.id IS NOT NULL) OR (self.id IS NOT NULL AND a_obj_in.id IS NULL) OR (self.id != a_obj_in.id) THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        IF (self.name IS NULL AND a_obj_in.name IS NOT NULL) OR (self.name IS NOT NULL AND a_obj_in.name IS NULL) OR
           (self.name != a_obj_in.name) THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        IF (self.description IS NULL AND a_obj_in.description IS NOT NULL) OR
           (self.description IS NOT NULL AND a_obj_in.description IS NULL) OR (self.description != a_obj_in.description) THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        IF l_deep_in = pete_core.g_YES THEN
            --
            IF (self.plsql_blocks_in_case IS NOT NULL AND a_obj_in.plsql_blocks_in_case IS NULL) OR
               (self.plsql_blocks_in_case IS NULL AND a_obj_in.plsql_blocks_in_case IS NOT NULL) OR
               (self.plsql_blocks_in_case.count != a_obj_in.plsql_blocks_in_case.count) THEN
                RETURN pete_core.g_NO;
            END IF;
            --
            FOR block_idx IN 1 .. self.plsql_blocks_in_case.count LOOP
                l_equals := self.plsql_blocks_in_case(block_idx)
                            .equals(a_obj_in => a_obj_in.plsql_blocks_in_case(block_idx), a_deep_in => l_deep_in);
                IF l_equals = pete_core.g_NO THEN
                    RETURN pete_core.g_NO;
                END IF;
            END LOOP;
            --
        END IF;
        --
        IF l_deep_in = pete_core.g_YES THEN
            --
            IF (self.test_case_ids_in_case IS NOT NULL AND a_obj_in.test_case_ids_in_case IS NULL) OR
               (self.test_case_ids_in_case IS NULL AND a_obj_in.test_case_ids_in_case IS NOT NULL) OR
               (self.test_case_ids_in_case.count != a_obj_in.test_case_ids_in_case.count) THEN
                RETURN pete_core.g_NO;
            END IF;
            --
            FOR case_idx IN 1 .. self.test_case_ids_in_case.count LOOP
                IF self.test_case_ids_in_case(case_idx) != a_obj_in.test_case_ids_in_case(case_idx) THEN
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
