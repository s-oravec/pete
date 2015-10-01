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
        position        IN NUMBER DEFAULT -1,
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
        self.position     := nvl(position, -1); -- pete_configuration_runner_api.g_ORDER_FIRST
        self.stop_on_failure := nvl(stop_on_failure, 'N'); -- pete_core.g_NO
        self.run_modifier    := run_modifier;
        self.description     := description;
        --
        RETURN;
        --
    END;
END;
/
