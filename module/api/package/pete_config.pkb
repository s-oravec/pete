create or replace package body pete_config as

    --------------------------------------------------------------------------------
    procedure set_show_asserts
    (
        value          in number,
        set_as_default in boolean
    ) is
    begin
        pete_config_impl.set_show_asserts(value, set_as_default);
    end;

    --------------------------------------------------------------------------------
    function get_show_asserts return number is
    begin
        return pete_config_impl.get_show_asserts;
    end;

    --------------------------------------------------------------------------------
    procedure set_show_hook_methods
    (
        value          in boolean,
        set_as_default in boolean
    ) is
    begin
        pete_config_impl.set_show_hook_methods(value, set_as_default);
    end;

    --------------------------------------------------------------------------------
    function get_show_hook_methods return boolean is
    begin
        return pete_config_impl.get_show_hook_methods;
    end;

    --------------------------------------------------------------------------------
    procedure set_show_failures_only
    (
        value          in boolean,
        set_as_default in boolean
    ) is
    begin
        pete_config_impl.set_show_failures_only(value, set_as_default);
    end;

    --------------------------------------------------------------------------------
    function get_show_failures_only return boolean is
    begin
        return pete_config_impl.get_show_failures_only;
    end;

    --------------------------------------------------------------------------------
    procedure set_skip_if_before_hook_fails
    (
        value          in boolean,
        set_as_default in boolean
    ) is
    begin
        pete_config_impl.set_skip_if_before_hook_fails(value, set_as_default);
    end;

    --------------------------------------------------------------------------------
    function get_skip_if_before_hook_fails return boolean is
    begin
        return pete_config_impl.get_skip_if_before_hook_fails;
    end;

    --------------------------------------------------------------------------------
    procedure set_test_package_prefix
    (
        value          in varchar2,
        set_as_default in boolean
    ) is
    begin
        pete_config_impl.set_test_package_prefix(value, set_as_default);
    end;

    --------------------------------------------------------------------------------
    function get_test_package_prefix return varchar2 is
    begin
        return pete_config_impl.get_test_package_prefix;
    end;

    --------------------------------------------------------------------------------
    procedure set_date_format
    (
        value          in varchar2,
        set_as_default in boolean
    ) is
    begin
        pete_config_impl.set_date_format(value, set_as_default);
    end;

    --------------------------------------------------------------------------------
    function get_date_format return varchar2 is
    begin
        return pete_config_impl.get_date_format;
    end;

end;
/
