create or replace package body pete as

    type typ_run_result is record(
        run_log_id pete_run_log.id%type,
        result     execution_result_type);

    --------------------------------------------------------------------------------
    procedure init(a_log_to_dbms_output_in in boolean) is
    begin
        --
        pete_logger.init(a_log_to_dbms_output_in => a_log_to_dbms_output_in);
        --
    end;

    --------------------------------------------------------------------------------  
    function begin_test
    (
        a_object_name_in       in pete_run_log.object_name%type,
        a_object_type_in       in pete_run_log.object_type%type,
        a_description_in       in pete_run_log.description%type default null,
        a_parent_run_log_id_in in integer default null
    ) return pete_run_log.id%type is
    begin
        return pete_core.begin_test(a_object_name_in       => 'Pete:' || a_object_type_in || ':' || a_object_name_in,
                                    a_object_type_in       => pete_core.g_OBJECT_TYPE_PETE,
                                    a_description_in       => a_description_in,
                                    a_parent_run_log_id_in => a_parent_run_log_id_in);
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
        a_suite_name_in        in varchar2,
        a_parent_run_log_id_in in integer default null
    ) return typ_run_result is
        l_suite_name varchar2(255) := nvl(a_suite_name_in, user);
        l_result     typ_run_result;
    begin
        pete_logger.trace('RUN_TEST_SUITE_IMPL: ' || 'a_suite_name_in:' || NVL(a_suite_name_in, 'NULL') || ', ' ||
                          'a_parent_run_log_id_in:' || nvl(to_char(a_parent_run_log_id_in), 'NULL'));
        --
        l_result.run_log_id := begin_test(a_object_name_in       => l_suite_name,
                                          a_object_type_in       => pete_core.g_OBJECT_TYPE_SUITE,
                                          a_parent_run_log_id_in => a_parent_run_log_id_in);
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
        a_suite_name_in        in varchar2,
        a_parent_run_log_id_in in integer
    ) is
        l_impl_call_result typ_run_result;
    begin
        l_impl_call_result := run_test_suite_impl(a_suite_name_in => a_suite_name_in, a_parent_run_log_id_in => a_parent_run_log_id_in);
        --
        if a_parent_run_log_id_in is null then
            pete_logger.output_log(a_run_log_id_in => l_impl_call_result.run_log_id);
        end if;
        --
    end run_test_suite;

    --------------------------------------------------------------------------------
    function run_test_suite
    (
        a_suite_name_in        in varchar2,
        a_parent_run_log_id_in in integer
    ) return execution_result_type is
        l_impl_call_result typ_run_result;
    begin
        l_impl_call_result := run_test_suite_impl(a_suite_name_in => a_suite_name_in, a_parent_run_log_id_in => a_parent_run_log_id_in);
        --
        return l_impl_call_result.result;
        --
    end run_test_suite;

    --------------------------------------------------------------------------------
    function run_test_package_impl
    (
        a_package_name_in      in varchar2,
        a_method_name_like_in  in varchar2 default null,
        a_parent_run_log_id_in in integer default null
    ) return typ_run_result is
        l_result typ_run_result;
    begin
        pete_logger.trace('RUN_TEST_PACKAGE: ' || 'a_package_name_in:' || NVL(a_package_name_in, 'NULL') || ', ' ||
                          'a_method_name_like_in:' || NVL(a_method_name_like_in, 'NULL'));
        if a_package_name_in is null then
            raise_application_error(-20000, 'Test package name not specified');
        end if;
        --
        l_result.run_log_id := begin_test(a_object_name_in       => a_package_name_in,
                                          a_object_type_in       => pete_core.g_OBJECT_TYPE_PACKAGE,
                                          a_parent_run_log_id_in => a_parent_run_log_id_in);
        --
        l_result.result := pete_convention_runner.run_package(a_package_name_in      => a_package_name_in,
                                                              a_method_name_like_in  => a_method_name_like_in,
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
        a_package_name_in      varchar2,
        a_method_name_like_in  in varchar2 default null,
        a_parent_run_log_id_in in integer default null
    ) is
        l_impl_call_result typ_run_result;
    begin
        l_impl_call_result := run_test_package_impl(a_package_name_in      => a_package_name_in,
                                                    a_method_name_like_in  => a_method_name_like_in,
                                                    a_parent_run_log_id_in => a_parent_run_log_id_in);
        --
        if a_parent_run_log_id_in is null then
            pete_logger.output_log(a_run_log_id_in => l_impl_call_result.run_log_id);
        end if;
        --
    end run_test_package;

    --------------------------------------------------------------------------------
    function run_test_package
    (
        a_package_name_in      in varchar2,
        a_method_name_like_in  in varchar2 default null,
        a_parent_run_log_id_in in integer default null
    ) return execution_result_type is
        l_impl_call_result typ_run_result;
    begin
        l_impl_call_result := run_test_package_impl(a_package_name_in      => a_package_name_in,
                                                    a_method_name_like_in  => a_method_name_like_in,
                                                    a_parent_run_log_id_in => a_parent_run_log_id_in);
        --
        return l_impl_call_result.result;
        --
    end run_test_package;

    --------------------------------------------------------------------------------
    function run_all_tests_impl(a_parent_run_log_id_in in integer default null) return typ_run_result is
        l_result typ_run_result;
    begin
        pete_logger.trace('RUN_ALL_TESTS: ');
        --
        l_result.run_log_id := begin_test(a_object_name_in       => 'Run all test',
                                          a_object_type_in       => pete_core.g_OBJECT_TYPE_PETE,
                                          a_parent_run_log_id_in => a_parent_run_log_id_in);
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
    procedure run_all_tests(a_parent_run_log_id_in in integer default null) is
        l_impl_call_result typ_run_result;
    begin
        l_impl_call_result := run_all_tests_impl(a_parent_run_log_id_in => a_parent_run_log_id_in);
        --
        if a_parent_run_log_id_in is null then
            pete_logger.output_log(a_run_log_id_in => l_impl_call_result.run_log_id);
        end if;
        --
    end run_all_tests;

    --------------------------------------------------------------------------------
    function run_all_tests(a_parent_run_log_id_in in integer default null) return execution_result_type is
        l_impl_call_result typ_run_result;
    begin
        l_impl_call_result := run_all_tests_impl(a_parent_run_log_id_in => a_parent_run_log_id_in);
        --
        return l_impl_call_result.result;
        --
    end run_all_tests;

    --------------------------------------------------------------------------------
    function run_impl
    (
        a_suite_name_in        in varchar2 default null,
        a_package_name_in      in varchar2 default null,
        a_method_name_in       in varchar2 default null,
        a_case_name_in         in varchar2 default null,
        a_parent_run_log_id_in in integer default null
    ) return typ_run_result is
        l_cnt integer;
    begin
        pete_logger.trace('RUN: ' || 'a_suite_name_in:' || NVL(a_suite_name_in, 'NULL') || ', ' || 'a_package_name_in:' ||
                          NVL(a_package_name_in, 'NULL') || ', ' || 'a_method_name_in:' || NVL(a_method_name_in, 'NULL') || ', ' ||
                          'a_case_name_in:' || NVL(a_case_name_in, 'NULL') || ', ' || 'a_style_conventional_in:' ||
                          'a_parent_run_log_id_in:' || nvl(to_char(a_parent_run_log_id_in), 'NULL'));
    
        --
        --check arguments
        -- iba method nema zmysel - potrebuje package
        -- 
        with args as
         (select a_suite_name_in as x
            from dual
          union all
          select a_package_name_in as x
            from dual
          union all
          select a_method_name_in as x
            from dual
          union all
          select a_case_name_in as x
            from dual)
        select count(x) into l_cnt from args;
        pete_logger.trace('l_cnt ' || l_cnt);
        --
        if l_cnt > 1 and a_method_name_in is null then
            raise_application_error(pete.gc_CONFLICTING_INPUT, 'Conflicting input - too many arguments set');
        end if;
        --
        if a_suite_name_in is not null then
            return run_test_suite_impl(a_suite_name_in => a_suite_name_in, a_parent_run_log_id_in => a_parent_run_log_id_in);
        elsif a_package_name_in is not null then
            return run_test_package_impl(a_package_name_in      => a_package_name_in,
                                         a_method_name_like_in  => a_method_name_in,
                                         a_parent_run_log_id_in => a_parent_run_log_id_in);
        else
            raise_application_error(pete.gc_AMBIGUOUS_INPUT, 'Ambiguous input - nothing specified');
        end if;
    
    end run_impl;

    --------------------------------------------------------------------------------
    procedure run
    (
        a_suite_name_in        in varchar2 default null,
        a_package_name_in      in varchar2 default null,
        a_method_name_in       in varchar2 default null,
        a_parent_run_log_id_in in integer default null
    ) is
        l_impl_call_result typ_run_result;
    begin
        l_impl_call_result := run_impl(a_suite_name_in        => a_suite_name_in,
                                       a_package_name_in      => a_package_name_in,
                                       a_method_name_in       => a_method_name_in,
                                       a_parent_run_log_id_in => a_parent_run_log_id_in);
        --
        if a_parent_run_log_id_in is null then
            pete_logger.output_log(a_run_log_id_in => l_impl_call_result.run_log_id);
        end if;
        --
    end;

    --------------------------------------------------------------------------------
    function run
    (
        a_suite_name_in        in varchar2 default null,
        a_package_name_in      in varchar2 default null,
        a_method_name_in       in varchar2 default null,
        a_parent_run_log_id_in in integer default null
    ) return execution_result_type is
        l_impl_call_result typ_run_result;
    begin
        l_impl_call_result := run_impl(a_suite_name_in        => a_suite_name_in,
                                       a_package_name_in      => a_package_name_in,
                                       a_method_name_in       => a_method_name_in,
                                       a_parent_run_log_id_in => a_parent_run_log_id_in);
        --
        return l_impl_call_result.result;
        --
    end;

    --------------------------------------------------------------------------------
    procedure set_method_description(a_description_in in varchar2) is
    begin
        pete_logger.set_method_description(a_description_in => a_description_in);
    end;

end;
/
