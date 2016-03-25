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
        --asserts
        pete_assert.is_not_null(a_value_in   => NAME,
                                a_comment_in => 'PETET_TEST_SUITE.NAME should be not null');
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
        
            IF self.test_cases_in_suite.count > 0
            THEN
                l_test_cases_in_suite.extend(self.test_cases_in_suite.count);
                --
                FOR block_idx IN 1 .. self.test_cases_in_suite.count
                LOOP
                    l_test_cases_in_suite(block_idx) := self.test_cases_in_suite(block_idx)
                                                        .copy();
                END LOOP;
            END IF;
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
        a_obj_in  IN petet_test_suite,
        a_deep_in IN VARCHAR2 DEFAULT 'N' --pete_core.g_NO
    ) RETURN VARCHAR2 --pete_types.typ_YES_NO
     IS
        l_deep_in          pete_types.typ_YES_NO := nvl(a_deep_in,
                                                       pete_core.g_NO);
        l_test_case_equals pete_types.typ_YES_NO;
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
        IF (self.stop_on_failure IS NULL AND
           a_obj_in.stop_on_failure IS NOT NULL)
           OR (self.stop_on_failure IS NOT NULL AND
           a_obj_in.stop_on_failure IS NULL)
           OR (self.stop_on_failure != a_obj_in.stop_on_failure)
        THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        IF (self.run_modifier IS NULL AND a_obj_in.run_modifier IS NOT NULL)
           OR (self.run_modifier IS NOT NULL AND a_obj_in.run_modifier IS NULL)
           OR (self.run_modifier != a_obj_in.run_modifier)
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
        IF l_deep_in = pete_core.g_YES
        THEN
            --
            IF (self.test_cases_in_suite IS NOT NULL AND
               a_obj_in.test_cases_in_suite IS NULL)
               OR (self.test_cases_in_suite IS NULL AND
               a_obj_in.test_cases_in_suite IS NOT NULL)
               OR (self.test_cases_in_suite.count !=
               a_obj_in.test_cases_in_suite.count)
            THEN
                RETURN pete_core.g_NO;
            END IF;
            --
            FOR case_idx IN 1 .. self.test_cases_in_suite.count
            LOOP
                l_test_case_equals := self.test_cases_in_suite(case_idx)
                                      .equals(a_obj_in  => a_obj_in.test_cases_in_suite(case_idx),
                                              a_deep_in => l_deep_in);
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
