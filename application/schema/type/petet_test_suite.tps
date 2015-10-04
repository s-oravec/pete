CREATE OR REPLACE TYPE petet_test_suite FORCE AS OBJECT
(
    id                  INTEGER,
    NAME                VARCHAR2(255),
    stop_on_failure     VARCHAR2(1),
    run_modifier        VARCHAR2(30),
    description         VARCHAR2(255),
    test_cases_in_suite petet_test_cases_in_suite,
--
    CONSTRUCTOR FUNCTION petet_test_suite
    (
        id                  IN INTEGER DEFAULT NULL,
        NAME                IN VARCHAR2,
        stop_on_failure     IN VARCHAR2 DEFAULT 'N',
        run_modifier        IN VARCHAR2 DEFAULT NULL,
        description         IN VARCHAR2 DEFAULT NULL,
        test_cases_in_suite IN petet_test_cases_in_suite DEFAULT NULL
    ) RETURN SELF AS RESULT,

    MEMBER FUNCTION copy RETURN petet_test_suite,

    MEMBER FUNCTION equals
    (
        a_obj_in  IN petet_test_suite,
        a_deep_in IN VARCHAR2 DEFAULT 'N' --pete_core.g_NO
    ) RETURN VARCHAR2 --pete_core.typ_YES_NO
)
/
