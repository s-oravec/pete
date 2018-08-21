create or replace package body pete_config_impl as

    C_TRUE  varchar2(10) := 'TRUE';
    C_FALSE varchar2(10) := 'FALSE';

    SHOW_ASSERTS   varchar2(30) := 'SHOW_ASSERTS';
    g_show_asserts number;

    SHOW_HOOK_METHODS   varchar2(30) := 'SHOW_HOOK_METHODS';
    g_show_hook_methods boolean;

    SHOW_FAILURES_ONLY   varchar2(30) := 'SHOW_FAILURES_ONLY';
    g_show_failures_only boolean;

    SKIP_IF_BEFORE_HOOK_FAILS   varchar2(30) := 'SKIP_IF_BEFORE_HOOK_FAILS';
    g_skip_if_before_hook_fails boolean;

    TEST_PACKAGE_PREFIX   varchar2(30) := 'TEST_PACKAGE_PREFIX';
    g_test_package_prefix varchar2(30);

    DATE_FORMAT   varchar2(30) := 'DATE_FORMAT';
    g_date_format varchar2(30);

    -- reads value from config table
    --------------------------------------------------------------------------------
    function get_param
    (
        a_key_in           in pete_configuration.key%type,
        a_default_value_in in pete_configuration.value%type default null
    ) return pete_configuration.value%type is
    begin
        for config in (select value from pete_configuration c where Key = a_key_in) loop
            return config.value;
        end loop;
        --
        return a_default_value_in;
        --
    end get_param;

    --------------------------------------------------------------------------------
    function get_boolean_param
    (
        a_key_in           in pete_configuration.key%type,
        a_default_value_in in boolean
    ) return boolean is
        l_Value pete_configuration.value%type;
    begin
        l_Value := get_param(a_key_in);
    
        if (l_Value = C_TRUE) then
            return true;
        elsif (l_Value = C_FALSE) then
            return false;
        else
            return a_default_value_in;
        end if;
    
    end;

    --writes a value into the config table
    --------------------------------------------------------------------------------
    procedure set_param
    (
        a_key_in   in pete_configuration.key%type,
        a_value_in in pete_configuration.value%type
    ) is
        pragma autonomous_transaction;
    begin
        merge into pete_configuration c
        using (select a_key_in key2, a_value_in value2 from dual) D
        on (c.key = d.key2)
        when matched then
            update set c.value = d.value2
        when not matched then
            insert (Key, value) values (d.key2, d.value2);
        commit;
    end set_param;

    --wrapper for boolean params
    --------------------------------------------------------------------------------
    procedure set_boolean_param
    (
        a_key_in   in pete_configuration.key%type,
        a_value_in in boolean
    ) is
        l_table_value varchar2(10);
    begin
        if (a_value_in) then
            l_table_value := C_TRUE;
        else
            l_table_value := C_FALSE;
        end if;
        set_param(a_key_in, l_table_value);
    end;

    --------------------------------------------------------------------------------
    procedure set_show_asserts
    (
        a_value_in       in number,
        a_set_as_default in boolean default false
    ) is
    
    begin
        g_show_asserts := a_value_in;
        if (a_set_as_default) then
            set_param(SHOW_ASSERTS, a_value_in);
        end if;
    end;

    --------------------------------------------------------------------------------
    function get_show_asserts return number is
    begin
        return g_show_asserts;
    end;

    --------------------------------------------------------------------------------
    procedure set_show_hook_methods
    (
        a_value_in       in boolean,
        a_set_as_default in boolean default false
    ) is
    
    begin
        g_show_hook_methods := a_value_in;
        if (a_set_as_default) then
            set_boolean_param(SHOW_HOOK_METHODS, a_value_in);
        end if;
    end;

    --------------------------------------------------------------------------------
    function get_show_hook_methods return boolean is
    begin
        return g_show_hook_methods;
    end;

    --------------------------------------------------------------------------------
    procedure set_show_failures_only
    (
        a_value_in       in boolean,
        a_set_as_default in boolean default false
    ) is
    
    begin
        g_show_failures_only := a_value_in;
        if (a_set_as_default) then
            set_boolean_param(SHOW_FAILURES_ONLY, a_value_in);
        end if;
    end;

    --------------------------------------------------------------------------------
    function get_show_failures_only return boolean is
    begin
        return g_show_failures_only;
    end;

    --------------------------------------------------------------------------------
    procedure set_skip_if_before_hook_fails
    (
        a_value_in       in boolean default g_SKIP_IF_BFR_HOOK_FAILS_DFLT,
        a_set_as_default in boolean default false
    ) is
    begin
        g_skip_if_before_hook_fails := a_value_in;
        if (a_set_as_default) then
            set_boolean_param(SKIP_IF_BEFORE_HOOK_FAILS, a_value_in);
        end if;
    end;

    --------------------------------------------------------------------------------
    function get_skip_if_before_hook_fails return boolean is
    begin
        return g_skip_if_before_hook_fails;
    end;

    --------------------------------------------------------------------------------
    procedure set_test_package_prefix
    (
        a_value_in       in varchar2 default pete_config.TEST_PACKAGE_PREFIX_DEFAULT,
        a_set_as_default in boolean default false
    ) is
    begin
        g_test_package_prefix := a_value_in;
        if a_set_as_default then
            set_param(TEST_PACKAGE_PREFIX, a_value_in);
        end if;
    end;

    --------------------------------------------------------------------------------
    function get_test_package_prefix return varchar2 is
    begin
        return g_test_package_prefix;
    end;

    --------------------------------------------------------------------------------
    procedure set_date_format
    (
        a_value_in       in varchar2 default pete_config.DATE_FORMAT_DEFAULT,
        a_set_as_default in boolean default false
    ) is
    begin
        g_date_format := a_value_in;
        if a_set_as_default then
            set_param(DATE_FORMAT, a_value_in);
        end if;
    end;

    --------------------------------------------------------------------------------
    function get_date_format return varchar2 is
    begin
        return g_date_format;
    end;

    --------------------------------------------------------------------------------
    procedure init is
    begin
        --show asserts
        g_show_asserts := get_param(a_key_in => SHOW_ASSERTS, a_default_value_in => pete_config.SHOW_ASSERTS_DEFAULT);
        --show hook methods
        g_show_hook_methods := get_boolean_param(a_key_in => SHOW_HOOK_METHODS, a_default_value_in => pete_config.SHOW_HOOK_METHODS_DEFAULT);
        --show failures only
        g_show_failures_only := get_boolean_param(a_key_in           => SHOW_FAILURES_ONLY,
                                                  a_default_value_in => pete_config.SHOW_FAILURES_ONLY_DEFAULT);
    
        --show failures only
        g_skip_if_before_hook_fails := get_boolean_param(a_key_in           => SKIP_IF_BEFORE_HOOK_FAILS,
                                                         a_default_value_in => pete_config.SKIP_IF_BFR_HOOK_FAILS_DFLT);
    
        --test package prefix
        g_test_package_prefix := get_param(a_key_in => TEST_PACKAGE_PREFIX, a_default_value_in => pete_config.TEST_PACKAGE_PREFIX_DEFAULT);
        --date format
        g_date_format := get_param(a_key_in => DATE_FORMAT, a_default_value_in => pete_config.DATE_FORMAT_DEFAULT);
    end init;

begin
    init;
end;
/
