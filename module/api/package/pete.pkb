create or replace package body pete as

    type typ_run_result is record(
        run_log_id pete_run_log.id%type,
        result     execution_result_type);

    --------------------------------------------------------------------------------
    procedure init(log_to_dbms_output in boolean) is
    begin
        --
        pete_logger.init(log_to_dbms_output);
        --
    end;

    --------------------------------------------------------------------------------  
    function begin_test
    (
        a_object_name_in  in pete_run_log.object_name%type,
        a_object_type_in  in pete_run_log.object_type%type,
        a_description_in  in pete_run_log.description%type default null,
        parent_run_log_id in integer default null
    ) return pete_run_log.id%type is
    begin
        return pete_core.begin_test(a_object_name_in       => 'Pete:' || a_object_type_in || ':' || a_object_name_in,
                                    a_object_type_in       => pete_core.g_OBJECT_TYPE_PETE,
                                    a_description_in       => a_description_in,
                                    a_parent_run_log_id_in => parent_run_log_id);
    end;

    --------------------------------------------------------------------------------
    procedure end_test
    (
        a_result_in     in execution_result_type,
        a_run_log_id_in in pete_run_log.id%type
    ) is
    begin
        pete_core.end_test(a_run_log_id_in => a_run_log_id_in, a_execution_result_in => a_result_in);
    end;

    --------------------------------------------------------------------------------
    function run_test_suite_impl
    (
        suite_name        in varchar2,
        parent_run_log_id in integer default null
    ) return typ_run_result is
        l_suite_name varchar2(255) := nvl(suite_name, user);
        l_result     typ_run_result;
    begin
        pete_logger.trace('RUN_TEST_SUITE_IMPL: ' || 'suite_name:' || NVL(suite_name, 'NULL') || ', ' || 'parent_run_log_id:' ||
                          nvl(to_char(parent_run_log_id), 'NULL'));
        --
        l_result.run_log_id := begin_test(a_object_name_in  => l_suite_name,
                                          a_object_type_in  => pete_core.g_OBJECT_TYPE_SUITE,
                                          parent_run_log_id => parent_run_log_id);
        --
        l_result.result := pete_convention_runner.run_suite(a_suite_name_in => l_suite_name, a_parent_run_log_id_in => l_result.run_log_id);
        --
        --do not output log if recursive call
        end_test(a_result_in => l_result.result, a_run_log_id_in => l_result.run_log_id);
        --
        return l_result;
        --
    end run_test_suite_impl;

    --------------------------------------------------------------------------------
    procedure run_test_suite
    (
        suite_name        in varchar2,
        parent_run_log_id in integer
    ) is
        l_impl_call_result typ_run_result;
    begin
        l_impl_call_result := run_test_suite_impl(suite_name => suite_name, parent_run_log_id => parent_run_log_id);
        --
        if parent_run_log_id is null then
            pete_logger.output_log(a_run_log_id_in => l_impl_call_result.run_log_id);
        end if;
        --
    end run_test_suite;

    --------------------------------------------------------------------------------
    function run_test_suite
    (
        suite_name        in varchar2,
        parent_run_log_id in integer
    ) return execution_result_type is
        l_impl_call_result typ_run_result;
    begin
        l_impl_call_result := run_test_suite_impl(suite_name => suite_name, parent_run_log_id => parent_run_log_id);
        --
        return l_impl_call_result.result;
        --
    end run_test_suite;

    --------------------------------------------------------------------------------
    function run_test_package_impl
    (
        package_name      in varchar2,
        method_name_like  in varchar2 default null,
        parent_run_log_id in integer default null
    ) return typ_run_result is
        l_result typ_run_result;
    begin
        pete_logger.trace('RUN_TEST_PACKAGE: ' || 'package_name:' || NVL(package_name, 'NULL') || ', ' || 'method_name_like:' ||
                          NVL(method_name_like, 'NULL'));
        if package_name is null then
            raise_application_error(-20000, 'Test package name not specified');
        end if;
        --
        l_result.run_log_id := begin_test(a_object_name_in  => package_name,
                                          a_object_type_in  => pete_core.g_OBJECT_TYPE_PACKAGE,
                                          parent_run_log_id => parent_run_log_id);
        --
        l_result.result := pete_convention_runner.run_package(a_package_name_in      => package_name,
                                                              a_method_name_like_in  => method_name_like,
                                                              a_parent_run_log_id_in => l_result.run_log_id);
    
        --
        --do not output log if recursive call
        end_test(a_result_in => l_result.result, a_run_log_id_in => l_result.run_log_id);
        --
        return l_result;
        --
    end run_test_package_impl;

    --------------------------------------------------------------------------------
    procedure run_test_package
    (
        package_name      varchar2,
        method_name_like  in varchar2 default null,
        parent_run_log_id in integer default null
    ) is
        l_impl_call_result typ_run_result;
    begin
        l_impl_call_result := run_test_package_impl(package_name      => package_name,
                                                    method_name_like  => method_name_like,
                                                    parent_run_log_id => parent_run_log_id);
        --
        if parent_run_log_id is null then
            pete_logger.output_log(a_run_log_id_in => l_impl_call_result.run_log_id);
        end if;
        --
    end run_test_package;

    --------------------------------------------------------------------------------
    function run_test_package
    (
        package_name      in varchar2,
        method_name_like  in varchar2 default null,
        parent_run_log_id in integer default null
    ) return execution_result_type is
        l_impl_call_result typ_run_result;
    begin
        l_impl_call_result := run_test_package_impl(package_name      => package_name,
                                                    method_name_like  => method_name_like,
                                                    parent_run_log_id => parent_run_log_id);
        --
        return l_impl_call_result.result;
        --
    end run_test_package;

    --------------------------------------------------------------------------------
    function run_all_tests_impl(parent_run_log_id in integer default null) return typ_run_result is
        l_result typ_run_result;
    begin
        pete_logger.trace('RUN_ALL_TESTS: ');
        --
        l_result.run_log_id := begin_test(a_object_name_in  => 'Run all test',
                                          a_object_type_in  => pete_core.g_OBJECT_TYPE_PETE,
                                          parent_run_log_id => parent_run_log_id);
        --
        -- run user Conventional suite
        l_result.result := abs(pete_convention_runner.run_suite(a_suite_name_in => user, a_parent_run_log_id_in => l_result.run_log_id)) +
                           abs(l_result.result);
        --
        --do not output log if recursive call
        end_test(a_result_in => l_result.result, a_run_log_id_in => l_result.run_log_id);
        --
        return l_result;
        --
    end run_all_tests_impl;

    --------------------------------------------------------------------------------
    procedure run_all_tests(parent_run_log_id in integer default null) is
        l_impl_call_result typ_run_result;
    begin
        l_impl_call_result := run_all_tests_impl(parent_run_log_id => parent_run_log_id);
        --
        if parent_run_log_id is null then
            pete_logger.output_log(a_run_log_id_in => l_impl_call_result.run_log_id);
        end if;
        --
    end run_all_tests;

    --------------------------------------------------------------------------------
    function run_all_tests(parent_run_log_id in integer default null) return execution_result_type is
        l_impl_call_result typ_run_result;
    begin
        l_impl_call_result := run_all_tests_impl(parent_run_log_id => parent_run_log_id);
        --
        return l_impl_call_result.result;
        --
    end run_all_tests;

    --------------------------------------------------------------------------------
    function run_impl
    (
        suite_name        in varchar2 default null,
        package_name      in varchar2 default null,
        method_name       in varchar2 default null,
        parent_run_log_id in integer default null
    ) return typ_run_result is
        l_cnt integer;
    begin
        pete_logger.trace('RUN: ' || 'suite_name:' || NVL(suite_name, 'NULL') || ', ' || 'package_name:' || NVL(package_name, 'NULL') || ', ' ||
                          'method_name_in:' || NVL(method_name, 'NULL') || ', ' || 'parent_run_log_id:' ||
                          nvl(to_char(parent_run_log_id), 'NULL'));
    
        --
        --check arguments
        -- iba method nema zmysel - potrebuje package
        -- 
        with args as
         (select suite_name as x from dual union all select package_name as x from dual union all select method_name as x from dual)
        select count(x) into l_cnt from args;
        pete_logger.trace('l_cnt ' || l_cnt);
        --
        if l_cnt > 1 and method_name is null then
            raise_application_error(pete.gc_CONFLICTING_INPUT, 'Conflicting input - too many arguments set');
        end if;
        --
        if suite_name is not null then
            return run_test_suite_impl(suite_name => suite_name, parent_run_log_id => parent_run_log_id);
        elsif package_name is not null then
            return run_test_package_impl(package_name      => package_name,
                                         method_name_like  => method_name,
                                         parent_run_log_id => parent_run_log_id);
        else
            raise_application_error(pete.gc_AMBIGUOUS_INPUT, 'Ambiguous input - nothing specified');
        end if;
    
    end run_impl;

    --------------------------------------------------------------------------------
    procedure run
    (
        suite_name        in varchar2 default null,
        package_name      in varchar2 default null,
        method_name       in varchar2 default null,
        parent_run_log_id in integer default null
    ) is
        l_impl_call_result typ_run_result;
    begin
        l_impl_call_result := run_impl(suite_name        => suite_name,
                                       package_name      => package_name,
                                       method_name       => method_name,
                                       parent_run_log_id => parent_run_log_id);
        --
        if parent_run_log_id is null then
            pete_logger.output_log(a_run_log_id_in => l_impl_call_result.run_log_id);
        end if;
        --
    end;

    --------------------------------------------------------------------------------
    function run
    (
        suite_name        in varchar2 default null,
        package_name      in varchar2 default null,
        method_name       in varchar2 default null,
        parent_run_log_id in integer default null
    ) return execution_result_type is
        l_impl_call_result typ_run_result;
    begin
        l_impl_call_result := run_impl(suite_name        => suite_name,
                                       package_name      => package_name,
                                       method_name       => method_name,
                                       parent_run_log_id => parent_run_log_id);
        --
        return l_impl_call_result.result;
        --
    end;

    --------------------------------------------------------------------------------
    procedure set_method_description(description in varchar2) is
    begin
        pete_logger.set_method_description(a_description_in => description);
    end;

end;
/
