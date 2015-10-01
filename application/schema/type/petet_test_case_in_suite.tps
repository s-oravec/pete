CREATE OR REPLACE TYPE petet_test_case_in_suite FORCE AS OBJECT
(
    id              INTEGER,
    test_suite_id   INTEGER,
    test_case_id    INTEGER,
    test_case       petet_test_case,
    position      INTEGER,
    stop_on_failure VARCHAR2(1),
    run_modifier    VARCHAR2(30),
    description     VARCHAR2(4000),
--
    CONSTRUCTOR FUNCTION petet_test_case_in_suite
    (
        id              IN INTEGER,
        test_suite_id   IN INTEGER,
        test_case_id    IN INTEGER,
        position      IN INTEGER,
        stop_on_failure IN VARCHAR2 DEFAULT 'N',
        run_modifier    IN VARCHAR2 DEFAULT NULL,
        description     IN VARCHAR2 DEFAULT NULL
    ) RETURN SELF AS RESULT,
--
    CONSTRUCTOR FUNCTION petet_test_case_in_suite
    (
        id              IN INTEGER,
        test_suite_id   IN INTEGER,
        test_case       IN petet_test_case,
        position      IN INTEGER,
        stop_on_failure IN VARCHAR2 DEFAULT 'N',
        run_modifier    IN VARCHAR2 DEFAULT NULL,
        description     IN VARCHAR2 DEFAULT NULL
    ) RETURN SELF AS RESULT
)
/
