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
        --asserts
        --plsql_block or plsql_block_id should be not null
        pete_assert.this(a_value_in   => plsql_block_id IS NOT NULL OR
                                         plsql_block IS NOT NULL,
                         a_comment_in => 'Either PETET_PLSQL_BLOCK_IN_CASE.PLSQL_BLOCK_ID or PETET_PLSQL_BLOCK_IN_CASE.PLSQL_BLOCK should be not null');
        --
        --if both plsql_block and plsql_block_id are defined then plsql_block.id should be set and should be same as pslql_block_id
        IF plsql_block IS NOT NULL
           AND plsql_block_id IS NOT NULL
        THEN
            pete_assert.this(a_value_in   => plsql_block_id = plsql_block.id,
                             a_comment_in => 'PETET_PLSQL_BLOCK_IN_CASE.PLSQL_BLOCK_ID and PETET_PLSQL_BLOCK_IN_CASE.PLSQL_BLOCK.ID should be same');
        END IF;
        --
        --if both input_argument and input_argument_id are defined then input_argument.id should be set and should be same as pslql_block_id
        IF input_argument IS NOT NULL
           AND input_argument_id IS NOT NULL
        THEN
            pete_assert.this(a_value_in   => input_argument_id = input_argument.id,
                             a_comment_in => 'PETET_PLSQL_BLOCK_IN_CASE.INPUT_ARGUMENT_ID and PETET_PLSQL_BLOCK_IN_CASE.INPUT_ARGUMENT.ID should be same');
        END IF;
        --
        --if both expected_result and expected_result_id are defined then expected_result.id should be set and should be same as pslql_block_id
        IF expected_result IS NOT NULL
           AND expected_result_id IS NOT NULL
        THEN
            pete_assert.this(a_value_in   => expected_result_id = expected_result.id,
                             a_comment_in => 'PETET_PLSQL_BLOCK_IN_CASE.EXPECTED_RESULT_ID and PETET_PLSQL_BLOCK_IN_CASE.EXPECTED_RESULT.ID should be same');
        END IF;
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
        a_obj_in  IN petet_plsql_block_in_case,
        a_deep_in IN VARCHAR2 DEFAULT 'N' --pete_core.g_NO
    ) RETURN VARCHAR2 --pete_core.typ_YES_NO
     IS
        l_deep_in pete_core.typ_YES_NO := nvl(a_deep_in, pete_core.g_NO);
    BEGIN
        --
        IF (self.id IS NULL AND a_obj_in.id IS NOT NULL)
           OR (self.id IS NOT NULL AND a_obj_in.id IS NULL)
           OR (self.id != a_obj_in.id)
        THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        IF (self.test_case_id IS NULL AND a_obj_in.test_case_id IS NOT NULL)
           OR (self.test_case_id IS NOT NULL AND a_obj_in.test_case_id IS NULL)
           OR (self.test_case_id != a_obj_in.test_case_id)
        THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        IF (self.plsql_block_id IS NULL AND a_obj_in.plsql_block_id IS NOT NULL)
           OR
           (self.plsql_block_id IS NOT NULL AND a_obj_in.plsql_block_id IS NULL)
           OR (self.plsql_block_id != a_obj_in.plsql_block_id)
        THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        IF l_deep_in = pete_core.g_YES
        THEN
            IF (self.plsql_block IS NULL AND a_obj_in.plsql_block IS NOT NULL)
               OR
               (self.plsql_block IS NOT NULL AND a_obj_in.plsql_block IS NULL)
               OR (self.plsql_block.equals(a_obj_in  => a_obj_in.plsql_block,
                                           a_deep_in => l_deep_in) =
               pete_core.g_NO)
            THEN
                RETURN pete_core.g_NO;
            END IF;
        END IF;
        --
        IF (self.input_argument_id IS NULL AND
           a_obj_in.input_argument_id IS NOT NULL)
           OR (self.input_argument_id IS NOT NULL AND
           a_obj_in.input_argument_id IS NULL)
           OR (self.input_argument_id != a_obj_in.input_argument_id)
        THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        IF l_deep_in = pete_core.g_YES
        THEN
            IF (self.input_argument IS NULL AND
               a_obj_in.input_argument IS NOT NULL)
               OR (self.input_argument IS NOT NULL AND
               a_obj_in.input_argument IS NULL)
               OR (self.input_argument.equals(a_obj_in  => a_obj_in.input_argument,
                                              a_deep_in => l_deep_in) =
               pete_core.g_NO)
            THEN
                RETURN pete_core.g_NO;
            END IF;
        END IF;
        --
        IF (self.expected_result_id IS NULL AND
           a_obj_in.expected_result_id IS NOT NULL)
           OR (self.expected_result_id IS NOT NULL AND
           a_obj_in.expected_result_id IS NULL)
           OR (self.expected_result_id != a_obj_in.expected_result_id)
        THEN
            RETURN pete_core.g_NO;
        END IF;
        --
        IF l_deep_in = pete_core.g_YES
        THEN
            IF (self.expected_result IS NULL AND
               a_obj_in.expected_result IS NOT NULL)
               OR (self.expected_result IS NOT NULL AND
               a_obj_in.expected_result IS NULL)
               OR (self.expected_result.equals(a_obj_in  => a_obj_in.expected_result,
                                               a_deep_in => l_deep_in) =
               pete_core.g_NO)
            THEN
                RETURN pete_core.g_NO;
            END IF;
        END IF;
        --
        IF (self.position IS NULL AND a_obj_in.position IS NOT NULL)
           OR (self.position IS NOT NULL AND a_obj_in.position IS NULL)
           OR (self.position != a_obj_in.position)
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
        RETURN pete_core.g_YES;
        --
    END;
END;
/
