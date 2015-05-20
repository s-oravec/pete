CREATE OR REPLACE PACKAGE pete_config AS

    --
    -- Pete config API package
    --


    g_ASSERTS_ALL constant number := 0;
    g_ASSERTS_FAILED constant number := 1;
    g_ASSERTS_NONE constant number := 2;

    --
    -- Sets what type of asserts show at output
    -- 
    -- %argument a_value_in
    -- %argument a_set_as_default if true then the a_value_in is stored in config table PETE_CONFIG and becomes sesssion default
    --
    PROCEDURE set_show_asserts
    (
        a_value_in       IN number,
        a_set_as_default IN BOOLEAN DEFAULT FALSE
    );

    --
    -- returns current settings of show_asserts system parameter
    --
    FUNCTION get_show_asserts RETURN number;


    --Sets if result shows hook methods
    --
    -- %argument a_value_in
    -- %argument a_set_as_default if true then the a_value_in is stored in config table PETE_CONFIG and becomes sesssion default
    --
    procedure set_show_hook_methods   
    (
        a_value_in       IN BOOLEAN,
        a_set_as_default IN BOOLEAN DEFAULT FALSE
    );

    --
    -- returns current settings of show_hook_methods system parameter
    --
    FUNCTION get_show_hook_methods RETURN BOOLEAN;


END;
/
