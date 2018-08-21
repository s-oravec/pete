create or replace package pete_config_impl as

    --
    -- Pete configuration API package
    -- setters and getters for accessing Pete configuration
    -- Use a_set_as_default = TRUE to store setting permanently in PETE_CONFIGURATION table
    --

    --
    -- Sets what type of asserts show at output
    -- 
    -- %argument a_value_in
    -- %argument a_set_as_default if true then the a_value_in is stored in config table PETE_CONFIGURATION and becomes sesssion default
    --
    procedure set_show_asserts
    (
        a_value_in       in number default pete_config.SHOW_ASSERTS_DEFAULT,
        a_set_as_default in boolean default false
    );

    --
    -- returns current settings of show_asserts system parameter
    --
    function get_show_asserts return number;

    --
    -- Sets if default logger output shows hook methods
    --
    -- %argument a_value_in
    -- %argument a_set_as_default if true then the a_value_in is stored in config table PETE_CONFIGURATION and becomes sesssion default
    --
    procedure set_show_hook_methods
    (
        a_value_in       in boolean default pete_config.SHOW_HOOK_METHODS_DEFAULT,
        a_set_as_default in boolean default false
    );

    --
    -- returns current settings of show_hook_methods system parameter
    --
    function get_show_hook_methods return boolean;

    --
    -- Sets if default logger outpu shows failed packages/methods, scripts/cases/blocks only
    --
    -- %argument a_value_in
    -- %argument a_set_as_default if true then the a_value_in is stored in config table PETE_CONFIGURATION and becomes sesssion default
    --
    procedure set_show_failures_only
    (
        a_value_in       in boolean default pete_config.SHOW_FAILURES_ONLY_DEFAULT,
        a_set_as_default in boolean default false
    );

    --
    -- returns current settings of show_failures_only system parameter
    --
    function get_show_failures_only return boolean;

    --
    -- Skip test if before hook fails
    -- - skip all methods if before_all method fails
    -- - skip next method if before_each method fails
    --------------------------------------------------------------------------------
    --
    g_SKIP_IF_BFR_HOOK_FAILS_DFLT constant boolean := false;

    --
    -- Sets if test methods are skipped after before hook method fails
    --
    -- %argument a_value_in
    -- %argument a_set_as_default if true then the a_value_in is stored in config table PETE_CONFIGURATION and becomes sesssion default
    --
    procedure set_skip_if_before_hook_fails
    (
        a_value_in       in boolean default g_SKIP_IF_BFR_HOOK_FAILS_DFLT,
        a_set_as_default in boolean default false
    );

    --
    -- returns current settings of skip_if_before_hook_fails system parameter
    --
    function get_skip_if_before_hook_fails return boolean;

    --
    -- Sets prefix for test packages
    --
    -- %argument a_value_in
    -- %argument a_set_as_default if true then the a_value_in is stored in config table PETE_CONFIGURATION and becomes sesssion default
    --
    procedure set_test_package_prefix
    (
        a_value_in       in varchar2 default pete_config.TEST_PACKAGE_PREFIX_DEFAULT,
        a_set_as_default in boolean default false
    );

    --
    -- returns current settings of show_hook_methods system parameter
    --
    function get_test_package_prefix return varchar2;

    --
    -- sets date format used by Pete
    --
    -- %argument a_value_in
    -- %argument a_set_as_default if true then the a_value_in is stored in config table PETE_CONFIGURATION and becomes sesssion default
    --
    procedure set_date_format
    (
        a_value_in       in varchar2 default pete_config.DATE_FORMAT_DEFAULT,
        a_set_as_default in boolean default false
    );

    --
    -- returns current settings of date_format system parameter
    --
    function get_date_format return varchar2;

end;
/
