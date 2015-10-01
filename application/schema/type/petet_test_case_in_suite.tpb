CREATE OR REPLACE TYPE BODY petet_test_case_in_suite AS

    -------------------------------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION petet_test_case_in_suite
    (
        id              IN INTEGER,
        test_suite_id   IN INTEGER,
        test_case_id    IN INTEGER,
        position      IN INTEGER,
        stop_on_failure IN VARCHAR2 DEFAULT 'N',
        run_modifier    IN VARCHAR2 DEFAULT NULL,
        description     IN VARCHAR2 DEFAULT NULL
    ) RETURN SELF AS RESULT IS
    BEGIN
        --
        self.id              := id;
        self.test_suite_id   := test_suite_id;
        self.test_case_id    := test_case_id;
        self.position      := position;
        self.stop_on_failure := stop_on_failure;
        self.run_modifier    := run_modifier;
        self.description     := description;
        --
        RETURN;
        --
    END;

    -------------------------------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION petet_test_case_in_suite
    (
        id              IN INTEGER,
        test_suite_id   IN INTEGER,
        test_case       IN petet_test_case,
        position      IN INTEGER,
        stop_on_failure IN VARCHAR2 DEFAULT 'N',
        run_modifier    IN VARCHAR2 DEFAULT NULL,
        description     IN VARCHAR2 DEFAULT NULL
    ) RETURN SELF AS RESULT IS
    BEGIN
        --
        self.id            := id;
        self.test_suite_id := test_suite_id;
        --
        self.test_case    := test_case;
        self.test_case_id := test_case.id;
        --
        self.position      := position;
        self.stop_on_failure := stop_on_failure;
        self.run_modifier    := run_modifier;
        self.description     := description;
        --
        RETURN;
        --
    END;
END;
/
