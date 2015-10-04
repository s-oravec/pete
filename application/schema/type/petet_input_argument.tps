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
    ) RETURN SELF AS RESULT,

    MEMBER FUNCTION copy RETURN petet_input_argument,

    MEMBER FUNCTION equals
    (
        a_obj_in  IN petet_input_argument,
        a_deep_in IN VARCHAR2 DEFAULT 'N' --pete_core.g_NO
    ) RETURN VARCHAR2 --pete_core.typ_YES_NO

)
/
