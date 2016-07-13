CREATE OR REPLACE TYPE petet_test_case_in_case FORCE AS OBJECT
(
    id                  INTEGER,
    parent_test_case_id INTEGER,
    test_case_id        INTEGER,
    test_case           petet_test_case,
    position            NUMBER,
    stop_on_failure     VARCHAR2(1),
    run_modifier        VARCHAR2(30),
    description         VARCHAR2(4000),
--
    CONSTRUCTOR FUNCTION petet_test_case_in_case
    (
        id                  IN INTEGER DEFAULT NULL,
        parent_test_case_id IN INTEGER DEFAULT NULL,
        test_case_id        IN INTEGER DEFAULT NULL,
        test_case           IN petet_test_case DEFAULT NULL,
        position            IN NUMBER DEFAULT -1,
        stop_on_failure     IN VARCHAR2 DEFAULT 'N',
        run_modifier        IN VARCHAR2 DEFAULT NULL,
        description         IN VARCHAR2 DEFAULT NULL
    ) RETURN SELF AS RESULT,

    MEMBER FUNCTION copy RETURN petet_test_case_in_case,

    MEMBER FUNCTION equals
    (
        a_obj_in  IN petet_test_case_in_case,
        a_deep_in IN VARCHAR2 DEFAULT 'N' --pete_core.g_NO
    ) RETURN VARCHAR2 --pete_types.typ_YES_NO
)
/
