CREATE OR REPLACE TYPE BODY petet_test_case_in_suite AS

    -------------------------------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION petet_test_case_in_suite
    (
        id              IN INTEGER DEFAULT NULL,
        test_suite_id   IN INTEGER DEFAULT NULL,
        test_case_id    IN INTEGER DEFAULT NULL,
        test_case       IN petet_test_case DEFAULT NULL,
        position        IN NUMBER DEFAULT -1,
        stop_on_failure IN VARCHAR2 DEFAULT 'N',
        run_modifier    IN VARCHAR2 DEFAULT NULL,
        description     IN VARCHAR2 DEFAULT NULL
    ) RETURN SELF AS RESULT IS
    BEGIN
        --
        self.id            := id;
        self.test_suite_id := test_suite_id;
        --
        self.test_case := test_case;
        IF test_case IS NOT NULL
        THEN
            self.test_case_id := test_case.id;
        ELSE
            self.test_case_id := test_case_id;
        END IF;
        --
        self.position        := position;
        self.stop_on_failure := stop_on_failure;
        self.run_modifier    := run_modifier;
        self.description     := description;
        --
        RETURN;
        --
    END;

    --------------------------------------------------------------------------------
    MEMBER FUNCTION copy RETURN petet_test_case_in_suite IS
    BEGIN
        RETURN NEW petet_test_case_in_suite(self.id,
                                            self.test_suite_id,
                                            self.test_case_id,
                                            CASE WHEN self.test_case IS NULL THEN NULL ELSE
                                            self.test_case.copy() END,
                                            self.position,
                                            self.stop_on_failure,
                                            self.run_modifier,
                                            self.description);
    END;

    --------------------------------------------------------------------------------
    MEMBER FUNCTION equals
    (
        p_obj_in  IN petet_test_case_in_suite,
        p_deep_in IN VARCHAR2 DEFAULT 'N' --pete_core.g_NO
    ) RETURN VARCHAR2 --pete_core.typ_YES_NO
     IS
        l_deep_in pete_core.typ_YES_NO := nvl(p_deep_in, pete_core.g_NO);
    BEGIN
        --
        IF (self.id IS NULL AND p_obj_in.id IS NOT NULL)
           OR (self.id IS NOT NULL AND p_obj_in.id IS NULL)
           OR (self.id != p_obj_in.id)
        THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        IF (self.test_suite_id IS NULL AND p_obj_in.test_suite_id IS NOT NULL)
           OR
           (self.test_suite_id IS NOT NULL AND p_obj_in.test_suite_id IS NULL)
           OR (self.test_suite_id != p_obj_in.test_suite_id)
        THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        IF (self.test_case_id IS NULL AND p_obj_in.test_case_id IS NOT NULL)
           OR (self.test_case_id IS NOT NULL AND p_obj_in.test_case_id IS NULL)
           OR (self.test_case_id != p_obj_in.test_case_id)
        THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        IF l_deep_in = pete_core.g_YES
        THEN
            IF (self.test_case IS NULL AND p_obj_in.test_case IS NOT NULL)
               OR (self.test_case IS NOT NULL AND p_obj_in.test_case IS NULL)
               OR
               (self.test_case.equals(p_obj_in  => p_obj_in.test_case,
                                      p_deep_in => l_deep_in) = pete_core.g_NO)
            THEN
                RETURN pete_core.g_NO;
            END IF;
        END IF;
        --
        IF (self.position IS NULL AND p_obj_in.position IS NOT NULL)
           OR (self.position IS NOT NULL AND p_obj_in.position IS NULL)
           OR (self.position != p_obj_in.position)
        THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        IF (self.stop_on_failure IS NULL AND
           p_obj_in.stop_on_failure IS NOT NULL)
           OR (self.stop_on_failure IS NOT NULL AND
           p_obj_in.stop_on_failure IS NULL)
           OR (self.stop_on_failure != p_obj_in.stop_on_failure)
        THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        IF (self.run_modifier IS NULL AND p_obj_in.run_modifier IS NOT NULL)
           OR (self.run_modifier IS NOT NULL AND p_obj_in.run_modifier IS NULL)
           OR (self.run_modifier != p_obj_in.run_modifier)
        THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        IF (self.description IS NULL AND p_obj_in.description IS NOT NULL)
           OR (self.description IS NOT NULL AND p_obj_in.description IS NULL)
           OR (self.description != p_obj_in.description)
        THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        RETURN pete_core.g_YES;
        --
    END;

END;
/
