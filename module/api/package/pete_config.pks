create or replace package pete_config as

    --
    -- Pete configuration API package
    -- setters and getters for accessing Pete configuration
    -- Use set_as_default = TRUE to persist setting
    --

    --
    -- Show asserts in output log
    --------------------------------------------------------------------------------
    --
    ASSERTS_ALL    constant number := 0;
    ASSERTS_FAILED constant number := 1;
    ASSERTS_NONE   constant number := 2;

    SHOW_ASSERTS_DEFAULT constant number := ASSERTS_FAILED;

    --
    -- Sets what type of asserts show at output
    -- 
    -- %argument value
    -- %argument set_as_default if true then the value is stored in config table PETE_CONFIGURATION and becomes sesssion default
    --
    procedure set_show_asserts
    (
        value          in number default SHOW_ASSERTS_DEFAULT,
        set_as_default in boolean default false
    );

    --
    -- returns current settings of show_asserts system parameter
    --
    function get_show_asserts return number;

    --
    -- Show hook methods in output log
    --------------------------------------------------------------------------------
    --
    SHOW_HOOK_METHODS_DEFAULT constant boolean := false;

    --
    -- Sets if default logger output shows hook methods
    --
    -- %argument value
    -- %argument set_as_default if true then the value is stored in config table PETE_CONFIGURATION and becomes sesssion default
    --
    procedure set_show_hook_methods
    (
        value          in boolean default SHOW_HOOK_METHODS_DEFAULT,
        set_as_default in boolean default false
    );

    --
    -- returns current settings of show_hook_methods system parameter
    --
    function get_show_hook_methods return boolean;

    --
    -- Show failed packages/methods, scripts/cases/blocks only in output log
    --------------------------------------------------------------------------------
    --
    SHOW_FAILURES_ONLY_DEFAULT constant boolean := false;

    --
    -- Sets if default logger outpu shows failed packages/methods, scripts/cases/blocks only
    --
    -- %argument value
    -- %argument set_as_default if true then the value is stored in config table PETE_CONFIGURATION and becomes sesssion default
    --
    procedure set_show_failures_only
    (
        value          in boolean default SHOW_FAILURES_ONLY_DEFAULT,
        set_as_default in boolean default false
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
    SKIP_IF_BFR_HOOK_FAILS_DFLT constant boolean := false;

    --
    -- Sets if test methods are skipped after before hook method fails
    --
    -- %argument value
    -- %argument set_as_default if true then the value is stored in config table PETE_CONFIGURATION and becomes sesssion default
    --
    procedure set_skip_if_before_hook_fails
    (
        value          in boolean default SKIP_IF_BFR_HOOK_FAILS_DFLT,
        set_as_default in boolean default false
    );

    --
    -- returns current settings of skip_if_before_hook_fails system parameter
    --
    function get_skip_if_before_hook_fails return boolean;

    --
    -- Test package prefix
    --------------------------------------------------------------------------------
    --
    TEST_PACKAGE_PREFIX_DEFAULT constant varchar2(30) := 'UT_';

    --
    -- Sets prefix for test packages
    --
    -- %argument value
    -- %argument set_as_default if true then the value is stored in config table PETE_CONFIGURATION and becomes sesssion default
    --
    procedure set_test_package_prefix
    (
        value          in varchar2 default TEST_PACKAGE_PREFIX_DEFAULT,
        set_as_default in boolean default false
    );

    --
    -- returns current settings of show_hook_methods system parameter
    --
    function get_test_package_prefix return varchar2;

    --
    -- Date format
    --------------------------------------------------------------------------------
    --
    DATE_FORMAT_DEFAULT constant varchar2(30) := 'yyyy-mm-dd hh24:mi:ss';

    --
    -- sets date format used by Pete
    --
    -- %argument value
    -- %argument set_as_default if true then the value is stored in config table PETE_CONFIGURATION and becomes sesssion default
    --
    procedure set_date_format
    (
        value          in varchar2 default DATE_FORMAT_DEFAULT,
        set_as_default in boolean default false
    );

    --
    -- returns current settings of date_format system parameter
    --
    function get_date_format return varchar2;

end;
/
