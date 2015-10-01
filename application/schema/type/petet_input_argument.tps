CREATE OR REPLACE TYPE petet_input_argument FORCE AS OBJECT
(
    id          INTEGER,
    NAME        VARCHAR2(255),
    VALUE       XMLTYPE,
    description VARCHAR2(255),
--
    CONSTRUCTOR FUNCTION petet_input_argument
    (
        id          IN INTEGER DEFAULT NULL,
        NAME        IN VARCHAR2,
        VALUE       IN XMLTYPE DEFAULT NULL,
        description IN VARCHAR2 DEFAULT NULL
    ) RETURN SELF AS RESULT
)
/
