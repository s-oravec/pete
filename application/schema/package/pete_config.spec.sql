CREATE OR REPLACE PACKAGE pete_config AS

    --
    -- Pete config API package
    --

    --
    -- Show asserts
    --------------------------------------------------------------------------------
    g_ASSERTS_ALL    CONSTANT NUMBER := 0;
    g_ASSERTS_FAILED CONSTANT NUMBER := 1;
    g_ASSERTS_NONE   CONSTANT NUMBER := 2;

    g_SHOW_ASSERTS_DEFAULT CONSTANT NUMBER := g_ASSERTS_FAILED;

    --
    -- Sets what type of asserts show at output
    -- 
    -- %argument a_value_in
    -- %argument a_set_as_default if true then the a_value_in is stored in config table PETE_CONFIG and becomes sesssion default
    --
    PROCEDURE set_show_asserts
    (
        a_value_in       IN NUMBER DEFAULT g_SHOW_ASSERTS_DEFAULT,
        a_set_as_default IN BOOLEAN DEFAULT FALSE
    );

    --
    -- returns current settings of show_asserts system parameter
    --
    FUNCTION get_show_asserts RETURN NUMBER;

    --
    -- Show hook methods
    --------------------------------------------------------------------------------
    g_SHOW_HOOK_METHODS_DEFAULT CONSTANT BOOLEAN := FALSE;

    --
    -- Sets if default logger output shows hook methods
    --
    -- %argument a_value_in
    -- %argument a_set_as_default if true then the a_value_in is stored in config table PETE_CONFIG and becomes sesssion default
    --
    PROCEDURE set_show_hook_methods
    (
        a_value_in       IN BOOLEAN DEFAULT g_SHOW_HOOK_METHODS_DEFAULT,
        a_set_as_default IN BOOLEAN DEFAULT FALSE
    );

    --
    -- returns current settings of show_hook_methods system parameter
    --
    FUNCTION get_show_hook_methods RETURN BOOLEAN;

    --
    -- Show failed packages/methods, scripts/cases/blocks only
    --------------------------------------------------------------------------------
    g_SHOW_FAILURES_ONLY_DEFAULT CONSTANT BOOLEAN := FALSE;

    --
    -- Sets if default logger outpu shows failed packages/methods, scripts/cases/blocks only
    --
    -- %argument a_value_in
    -- %argument a_set_as_default if true then the a_value_in is stored in config table PETE_CONFIG and becomes sesssion default
    --
    PROCEDURE set_show_failures_only
    (
        a_value_in       IN BOOLEAN DEFAULT g_SHOW_FAILURES_ONLY_DEFAULT,
        a_set_as_default IN BOOLEAN DEFAULT FALSE
    );

    --
    -- returns current settings of show_failures_only system parameter
    --
    FUNCTION get_show_failures_only RETURN BOOLEAN;

    --
    -- Skip test if before hook fails
    -- - skip all methods if before_all method fails
    -- - skip next method if before_each method fails
    --------------------------------------------------------------------------------
    g_SKIP_IF_BFR_HOOK_FAILS_DFLT CONSTANT BOOLEAN := FALSE;

    --
    -- Sets if test methods are skipped after before hook method fails
    --
    -- %argument a_value_in
    -- %argument a_set_as_default if true then the a_value_in is stored in config table PETE_CONFIG and becomes sesssion default
    --
    PROCEDURE set_skip_if_before_hook_fails
    (
        a_value_in       IN BOOLEAN DEFAULT g_SKIP_IF_BFR_HOOK_FAILS_DFLT,
        a_set_as_default IN BOOLEAN DEFAULT FALSE
    );

    --
    -- returns current settings of skip_if_before_hook_fails system parameter
    --
    FUNCTION get_skip_if_before_hook_fails RETURN BOOLEAN;

    --
    -- Test package prefix
    --------------------------------------------------------------------------------
    --

    g_TEST_PACKAGE_PREFIX_DEFAULT CONSTANT VARCHAR2(30) := 'UT_';

    --
    -- Sets prefix for test packages
    --
    -- %argument a_value_in
    -- %argument a_set_as_default if true then the a_value_in is stored in config table PETE_CONFIG and becomes sesssion default
    --
    PROCEDURE set_test_package_prefix
    (
        a_value_in       IN VARCHAR2 DEFAULT g_TEST_PACKAGE_PREFIX_DEFAULT,
        a_set_as_default IN BOOLEAN DEFAULT FALSE
    );

    --
    -- returns current settings of show_hook_methods system parameter
    --
    FUNCTION get_test_package_prefix RETURN VARCHAR2;

    --
    -- Date format
    --------------------------------------------------------------------------------
    --

    g_DATE_FORMAT_DEFAULT CONSTANT VARCHAR2(30) := 'yyyy-mm-dd hh24:mi:ss';

    --
    -- Sets prefix for test packages
    --
    -- %argument a_value_in
    -- %argument a_set_as_default if true then the a_value_in is stored in config table PETE_CONFIG and becomes sesssion default
    --
    PROCEDURE set_date_format
    (
        a_value_in       IN VARCHAR2 DEFAULT g_DATE_FORMAT_DEFAULT,
        a_set_as_default IN BOOLEAN DEFAULT FALSE
    );

    --
    -- returns current settings of show_hook_methods system parameter
    --
    FUNCTION get_date_format RETURN VARCHAR2;

END;
/
