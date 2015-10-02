CREATE OR REPLACE TYPE BODY petet_plsql_block_in_case AS

    -------------------------------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION petet_plsql_block_in_case
    (
        id                 IN INTEGER DEFAULT NULL,
        test_case_id       IN INTEGER DEFAULT NULL,
        plsql_block_id     IN INTEGER DEFAULT NULL,
        plsql_block        IN petet_plsql_block DEFAULT NULL,
        input_argument_id  IN INTEGER DEFAULT NULL,
        input_argument     IN petet_input_argument DEFAULT NULL,
        expected_result_id IN INTEGER DEFAULT NULL,
        expected_result    IN petet_expected_result DEFAULT NULL,
        position           IN NUMBER DEFAULT -1,
        stop_on_failure    IN VARCHAR2 DEFAULT 'N',
        run_modifier       IN VARCHAR2 DEFAULT NULL,
        description        IN VARCHAR2 DEFAULT NULL
    ) RETURN SELF AS RESULT IS
    BEGIN
        --
        self.id           := id;
        self.test_case_id := test_case_id;
        --
        self.plsql_block := plsql_block;
        IF plsql_block IS NOT NULL
        THEN
            self.plsql_block_id := plsql_block.id;
        ELSE
            self.plsql_block_id := plsql_block_id;
        END IF;
        --
        self.input_argument := input_argument;
        IF input_argument IS NOT NULL
        THEN
            self.input_argument_id := input_argument.id;
        ELSE
            self.input_argument_id := input_argument_id;
        END IF;
        --
        self.expected_result := expected_result;
        IF expected_result IS NOT NULL
        THEN
            self.expected_result_id := expected_result.id;
        ELSE
            self.expected_result_id := expected_result_id;
        END IF;
        --
        --TODO: move constant definition to pete_core
        self.position        := nvl(position, -1); -- pete_configuration_runner_api.g_ORDER_FIRST
        self.stop_on_failure := nvl(stop_on_failure, 'N'); -- pete_core.g_NO
        self.run_modifier    := run_modifier;
        self.description     := description;
        --
        RETURN;
        --
    END;

    --------------------------------------------------------------------------------
    MEMBER FUNCTION copy RETURN petet_plsql_block_in_case IS
    BEGIN
        RETURN NEW petet_plsql_block_in_case(self.id,
                                             self.test_case_id,
                                             self.plsql_block_id,
                                             CASE WHEN self.plsql_block IS NULL THEN NULL ELSE
                                             self.plsql_block.copy() END,
                                             self.input_argument_id,
                                             CASE WHEN
                                             self.input_argument IS NULL THEN NULL ELSE
                                             self.input_argument.copy() END,
                                             self.expected_result_id,
                                             CASE WHEN
                                             self.expected_result IS NULL THEN NULL ELSE
                                             self.expected_result.copy() END,
                                             self.position,
                                             self.stop_on_failure,
                                             self.run_modifier,
                                             self.description);
    END;

    --------------------------------------------------------------------------------
    MEMBER FUNCTION equals
    (
        p_obj_in  IN petet_plsql_block_in_case,
        p_deep_in IN VARCHAR2 DEFAULT 'N' --pete_core.g_NO
    ) RETURN VARCHAR2 --pete_core.typ_YES_NO
     IS
        l_deep_in pete_core.typ_YES_NO := nvl(p_deep_in, pete_core.g_NO);
    BEGIN
        --
        IF NOT
            (self.id = p_obj_in.id OR (self.id IS NULL AND p_obj_in.id IS NULL))
        THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        IF NOT (self.test_case_id = p_obj_in.test_case_id OR
            (self.test_case_id IS NULL AND p_obj_in.test_case_id IS NULL))
        THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        IF NOT
            (self.plsql_block_id = p_obj_in.plsql_block_id OR
            (self.plsql_block_id IS NULL AND p_obj_in.plsql_block_id IS NULL))
        THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        IF l_deep_in = pete_core.g_YES
        THEN
            IF NOT ((self.plsql_block IS NULL AND p_obj_in.plsql_block IS NULL) OR
                self.plsql_block.equals(p_obj_in  => p_obj_in.plsql_block,
                                            p_deep_in => l_deep_in) =
                pete_core.g_YES)
            THEN
                RETURN pete_core.g_NO;
            END IF;
        END IF;
        --
        IF NOT (self.input_argument_id = p_obj_in.input_argument_id OR
            (self.input_argument_id IS NULL AND
            p_obj_in.input_argument_id IS NULL))
        THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        IF l_deep_in = pete_core.g_YES
        THEN
            IF NOT ((self.input_argument IS NULL AND
                p_obj_in.input_argument IS NULL) OR self.input_argument.equals(p_obj_in  => p_obj_in.input_argument,
                                                                                   p_deep_in => l_deep_in) =
                pete_core.g_YES)
            THEN
                RETURN pete_core.g_NO;
            END IF;
        END IF;
        --
        IF NOT (self.expected_result_id = p_obj_in.expected_result_id OR
            (self.expected_result_id IS NULL AND
            p_obj_in.expected_result_id IS NULL))
        THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        IF l_deep_in = pete_core.g_YES
        THEN
            IF NOT ((self.expected_result IS NULL AND
                p_obj_in.expected_result IS NULL) OR self.expected_result.equals(p_obj_in  => p_obj_in.expected_result,
                                                                                     p_deep_in => l_deep_in) =
                pete_core.g_YES)
            THEN
                RETURN pete_core.g_NO;
            END IF;
        END IF;
        --
        IF NOT (self.position = p_obj_in.position OR
            (self.position IS NULL AND p_obj_in.position IS NULL))
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
        RETURN pete_core.g_YES;
        --
    END;
END;
/
