CREATE OR REPLACE TYPE petet_test_case FORCE AS OBJECT
(
    id                   INTEGER,
    NAME                 VARCHAR2(255),
    description          VARCHAR2(4000),
    plsql_blocks_in_case petet_plsql_blocks_in_case,
--
    CONSTRUCTOR FUNCTION petet_test_case
    (
        id                   IN INTEGER DEFAULT NULL,
        NAME                 IN VARCHAR2,
        description          IN VARCHAR2 DEFAULT NULL,
        plsql_blocks_in_case IN petet_plsql_blocks_in_case DEFAULT NULL
    ) RETURN SELF AS RESULT,

    MEMBER FUNCTION copy RETURN petet_test_case,

    MEMBER FUNCTION equals
    (
        a_obj_in  IN petet_test_case,
        a_deep_in IN VARCHAR2 DEFAULT 'N' --pete_core.g_NO
    ) RETURN VARCHAR2 --pete_types.typ_YES_NO

)
/
