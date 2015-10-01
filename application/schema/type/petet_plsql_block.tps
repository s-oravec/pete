CREATE OR REPLACE TYPE petet_plsql_block FORCE AS OBJECT
(
    id              INTEGER,
    NAME            VARCHAR2(255),
    description     VARCHAR2(255),
    owner           VARCHAR2(32),
    PACKAGE         VARCHAR2(32),
    method          VARCHAR2(32),
    anonymous_block CLOB,
--
    CONSTRUCTOR FUNCTION petet_plsql_block
    (
        id              IN INTEGER DEFAULT NULL,
        NAME            IN VARCHAR2,
        description     IN VARCHAR2 DEFAULT NULL,
        owner           IN VARCHAR2 DEFAULT NULL,
        PACKAGE         IN VARCHAR2 DEFAULT NULL,
        method          IN VARCHAR2 DEFAULT NULL,
        anonymous_block IN CLOB DEFAULT NULL
    ) RETURN SELF AS RESULT
)
/
