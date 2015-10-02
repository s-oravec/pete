CREATE OR REPLACE TYPE BODY petet_test_suite AS

    -------------------------------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION petet_test_suite
    (
        id                  IN INTEGER DEFAULT NULL,
        NAME                IN VARCHAR2,
        stop_on_failure     IN VARCHAR2 DEFAULT 'N',
        run_modifier        IN VARCHAR2 DEFAULT NULL,
        description         IN VARCHAR2 DEFAULT NULL,
        test_cases_in_suite IN petet_test_cases_in_suite DEFAULT NULL
    ) RETURN SELF AS RESULT IS
    BEGIN
        --
        self.id                  := id;
        self.name                := NAME;
        self.stop_on_failure     := nvl(stop_on_failure, 'N');
        self.run_modifier        := run_modifier;
        self.description         := description;
        self.test_cases_in_suite := test_cases_in_suite;
        --
        RETURN;
        --
    END;

    --------------------------------------------------------------------------------
    MEMBER FUNCTION copy RETURN petet_test_suite IS
        l_test_cases_in_suite petet_test_cases_in_suite;
    BEGIN
        --
        IF self.test_cases_in_suite IS NOT NULL
        THEN
            l_test_cases_in_suite := NEW petet_test_cases_in_suite();
            l_test_cases_in_suite.extend(self.test_cases_in_suite.count);
            --
            FOR block_idx IN 1 .. self.test_cases_in_suite.count
            LOOP
                l_test_cases_in_suite(block_idx) := self.test_cases_in_suite(block_idx)
                                                    .copy();
            END LOOP;
            --
        END IF;
        --
        RETURN NEW petet_test_suite(self.id,
                                    self.name,
                                    self.stop_on_failure,
                                    self.run_modifier,
                                    self.description,
                                    l_test_cases_in_suite);
    END;

    --------------------------------------------------------------------------------
    MEMBER FUNCTION equals
    (
        p_obj_in  IN petet_test_suite,
        p_deep_in IN VARCHAR2 DEFAULT 'N' --pete_core.g_NO
    ) RETURN VARCHAR2 --pete_core.typ_YES_NO
     IS
        l_deep_in          pete_core.typ_YES_NO := nvl(p_deep_in,
                                                       pete_core.g_NO);
        l_test_case_equals pete_core.typ_YES_NO;
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
        IF NOT
            (self.stop_on_failure = p_obj_in.stop_on_failure OR
            (self.stop_on_failure IS NULL AND p_obj_in.stop_on_failure IS NULL))
        THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        IF NOT (self.run_modifier = p_obj_in.run_modifier OR
            (self.run_modifier IS NULL AND p_obj_in.run_modifier IS NULL))
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
            IF NOT ((self.test_cases_in_suite IS NULL AND
                p_obj_in.test_cases_in_suite IS NULL) OR
                self.test_cases_in_suite.count =
                p_obj_in.test_cases_in_suite.count)
            THEN
                RETURN pete_core.g_NO;
            END IF;
            --
            FOR block_idx IN 1 .. self.test_cases_in_suite.count
            LOOP
                l_test_case_equals := self.test_cases_in_suite(block_idx)
                                      .equals(p_obj_in  => p_obj_in.test_cases_in_suite(block_idx),
                                              p_deep_in => l_deep_in);
                IF l_test_case_equals = pete_core.g_NO
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
