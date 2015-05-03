CREATE OR REPLACE PACKAGE pete_config AS

    --
    -- Pete config API package
    --

    --
    -- Sets if result shows only failed asserts (true) or all (false).
    -- 
    -- %param a_value_in
    -- %param a_set_as_default if true then the a_value_in is stored in config table PETE_CONFIG and becomes sesssion default
    --
    PROCEDURE set_show_failures_only
    (
        a_value_in       IN BOOLEAN,
        a_set_as_default IN BOOLEAN DEFAULT FALSE
    );

    --
    -- returns current settings of show_failures_only system parameter
    --
    FUNCTION get_show_failures_only RETURN BOOLEAN;

END;
/
