CREATE OR REPLACE TYPE petet_plsql_block_in_case FORCE AS OBJECT
(
    id                 INTEGER,
    test_case_id       INTEGER,
    plsql_block_id     INTEGER,
    plsql_block        petet_plsql_block,
    input_argument_id  INTEGER,
    input_argument     petet_input_argument,
    expected_result_id INTEGER,
    expected_result    petet_expected_result,
    position           NUMBER,
    stop_on_failure    VARCHAR2(1),
    run_modifier       VARCHAR2(30),
    description        VARCHAR2(4000),
--
-- if both <obj> and <obj>_id are set, then <obj> has precedence and <obj>_id is set as <obj>.id
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
        position           IN NUMBER DEFAULT -1, --pete_configuration_runner_adm.g_ORDER_FIRST
        stop_on_failure    IN VARCHAR2 DEFAULT 'N', --pete_core.g_NO
        run_modifier       IN VARCHAR2 DEFAULT NULL,
        description        IN VARCHAR2 DEFAULT NULL
    ) RETURN SELF AS RESULT,

    MEMBER FUNCTION copy RETURN petet_plsql_block_in_case,

    MEMBER FUNCTION equals
    (
        a_obj_in  IN petet_plsql_block_in_case,
        a_deep_in IN VARCHAR2 DEFAULT 'N' --pete_core.g_NO
    ) RETURN VARCHAR2 --pete_core.typ_YES_NO

)
/
