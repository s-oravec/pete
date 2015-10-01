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
END;
/
