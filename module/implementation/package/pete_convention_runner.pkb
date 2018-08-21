create or replace package body pete_convention_runner as

    --
    --wrapper for dynamic SQL
    --
    procedure execute_sql(a_sql_in in varchar2) is
    begin
        pete_logger.trace(a_trace_message_in => 'EXEC IMM:' || a_sql_in);
        execute immediate a_sql_in;
    end;

    -- TODO: move to config
    --------------------------------------------------------------------------------
    function get_tst_pkg_regexp return varchar2 is
    begin
        --TODO escape
        return '^' || pete_config.get_test_package_prefix || '.*';
    end;

    --------------------------------------------------------------------------------
    function get_tst_pkg_only_regexp return varchar2 is
    begin
        --TODO escape
        return '^' || pete_config.get_test_package_prefix || 'OO.*';
    end;

    --------------------------------------------------------------------------------
    function get_method_name_only_regexp return varchar2 is
    begin
        return '^OO.*';
    end;

    --------------------------------------------------------------------------------
    function get_method_name_skip_regexp return varchar2 is
    begin
        return '^XX.*';
    end;

    --------------------------------------------------------------------------------
    -- returns true if package exists. Case sensitive
    function package_exists(a_package_name_in in pete_types.typ_object_name) return boolean is
        l_owner        pete_types.typ_object_name;
        l_package_name pete_types.typ_object_name;
    begin
        -- NoFormat Start
        pete_logger.trace('PACKAGE_EXISTS: ' ||
                          'a_package_name_in:' || NVL(a_package_name_in, 'NULL'));
        -- NoFormat End
        l_owner        := pete_utils.get_sql_schema_name(a_package_name_in => a_package_name_in);
        l_package_name := pete_utils.get_sql_package_name(a_package_name_in => a_package_name_in);
        --
        for ii in (select null
                     from all_objects uo
                    where object_type = 'PACKAGE'
                      and owner = l_owner
                      and object_name = l_package_name) loop
            pete_logger.trace('returns true');
            return true;
        end loop;
        --
        pete_logger.trace('returns false');
        return false;
        --
    end;

    --------------------------------------------------------------------------------
    function package_has_method
    (
        a_package_name_in in pete_types.typ_object_name,
        a_method_name_in  in pete_types.typ_object_name
    ) return boolean is
        l_owner        pete_types.typ_object_name;
        l_package_name pete_types.typ_object_name;
        l_method_name  pete_types.typ_object_name;
    begin
        -- NoFormat Start
        pete_logger.trace('PACKAGE_HAS_METHOD: ' ||
                          'a_package_name_in:' || NVL(a_package_name_in, 'NULL') || ', ' ||
                          'a_method_name_in:' || NVL(a_method_name_in, 'NULL'));
        -- NoFormat End
        l_owner        := pete_utils.get_sql_schema_name(a_package_name_in => a_package_name_in);
        l_package_name := pete_utils.get_sql_package_name(a_package_name_in => a_package_name_in);
        l_method_name  := replace(dbms_assert.enquote_name(a_method_name_in), '"');
        --
        for ii in (select 1
                     from all_procedures
                    where owner = l_owner
                      and object_name = l_package_name
                      and procedure_name = l_method_name) loop
            pete_logger.trace('returns true');
            return true;
        end loop;
        --
        pete_logger.trace('returns false');
        return false;
        --
    end package_has_method;

    --------------------------------------------------------------------------------
    function run_hook_method
    (
        a_package_name_in      in pete_types.typ_object_name,
        a_hook_method_name_in  in pete_types.typ_object_name,
        a_parent_run_log_id_in in pete_run_log.parent_id%type
    ) return pete_types.typ_execution_result is
    begin
        -- NoFormat Start
        pete_logger.trace('RUN_HOOK_METHOD: ' ||
                          'a_package_name_in:' || NVL(a_package_name_in, 'NULL') || ', ' ||
                          'a_hook_method_name_in:' || NVL(a_hook_method_name_in, 'NULL') || ', ' ||
                          'a_parent_run_log_id_in:' || NVL(TO_CHAR(a_parent_run_log_id_in), 'NULL'));
        -- NoFormat End
        if package_has_method(a_package_name_in => a_package_name_in, a_method_name_in => a_hook_method_name_in) then
            pete_logger.trace('has hook method, execute');
            return run_method(a_package_name_in      => a_package_name_in,
                              a_method_name_in       => a_hook_method_name_in,
                              a_object_type_in       => pete_core.g_OBJECT_TYPE_HOOK,
                              a_description_in       => a_hook_method_name_in,
                              a_parent_run_log_id_in => a_parent_run_log_id_in);
        else
            pete_logger.trace('doesn''t have hook method, do nothing');
            return pete_core.g_SUCCESS;
        end if;
    end;

    --------------------------------------------------------------------------------
    function run_method
    (
        a_package_name_in      in pete_types.typ_object_name,
        a_method_name_in       in pete_types.typ_object_name,
        a_object_type_in       in pete_types.typ_object_type,
        a_description_in       in pete_types.typ_description default null,
        a_parent_run_log_id_in in pete_run_log.parent_id%type default null
    ) return pete_types.typ_execution_result is
        l_sql        varchar2(500);
        l_run_log_id integer;
        l_result     pete_types.typ_execution_result := pete_core.g_SUCCESS;
        l_dummy      varchar2(93);
    begin
        l_run_log_id := pete_core.begin_test(a_object_name_in       => a_package_name_in || '.' || a_method_name_in,
                                             a_object_type_in       => a_object_type_in,
                                             a_description_in       => a_description_in,
                                             a_parent_run_log_id_in => a_parent_run_log_id_in);
        --
        l_dummy := dbms_assert.SQL_OBJECT_NAME(a_package_name_in);
    
        l_sql := 'begin ' || a_package_name_in || '.' || a_method_name_in || ';end;';
        execute_sql(a_sql_in => l_sql);
        --
        pete_core.end_test(a_run_log_id_in => l_run_log_id);
        --
        return l_result;
        --
    exception
        when others then
            l_result := pete_core.g_FAILURE;
            pete_core.end_test(a_run_log_id_in => l_run_log_id, a_execution_result_in => l_result, a_error_code_in => sqlcode);
            --
            return l_result;
            --
    end run_method;

    --------------------------------------------------------------------------------
    function run_package
    (
        a_package_name_in      in pete_types.typ_object_name,
        a_method_name_like_in  in pete_types.typ_object_name default null,
        a_description_in       in pete_types.typ_description default null,
        a_parent_run_log_id_in in pete_run_log.parent_id%type default null
    ) return pete_types.typ_execution_result is
        l_result     pete_types.typ_execution_result := pete_core.g_SUCCESS;
        l_run_log_id integer;
        --
        --l_method_only_regexp varchar2(255) := get_method_name_only_regexp;
        --l_method_skip_regexp varchar2(255) := get_method_name_skip_regexp;
        --
        l_before_all_result  pete_types.typ_execution_result := pete_core.g_SUCCESS;
        l_before_each_result pete_types.typ_execution_result := pete_core.g_SUCCESS;
        --
        l_something_run boolean := false;
        --
        --l_owner pete_types.typ_object_name;
        --l_package_name pete_types.typ_object_name;
        --
        cursor lcrs_tested_methods
        (
            a_owner              in pete_types.typ_object_name,
            a_package_name       in pete_types.typ_object_name,
            a_method_only_regexp in varchar2,
            a_method_skip_regexp in varchar2
        ) is
            -- NoFormat Start
            WITH
            allProcedures as (select /*+ materialize */ * from all_procedures where owner = a_owner and object_name = a_package_name),
            allArguments  as (select /*+ materialize */ * from all_arguments  where owner = a_owner and package_name = a_package_name),
            convention_runner_procedures AS
             (SELECT /*+ materialize */
                     procedure_name,
                     subprogram_id,
                     SUM(CASE WHEN REGEXP_LIKE(UPPER(procedure_name), upper(a_method_only_regexp)) THEN 1 ELSE 0 END) over() AS oo_method
                FROM allProcedures up
               WHERE 1 = 1
                 --ignore hooks
                 AND procedure_name NOT IN ('BEFORE_ALL', 'BEFORE_EACH', 'AFTER_ALL', 'AFTER_EACH')
                 --a_method_name_like_in filter
                 AND (a_method_name_like_in IS NULL OR upper(procedure_NAME) LIKE upper(a_method_name_like_in))
                 AND procedure_name IS NOT NULL
                 --skipped methods
                 AND not regexp_like(upper(procedure_name), upper(a_method_skip_regexp))
                    -- it is not a function or a procedure with out/in_out arguments
                    -- or a procedure in argument without default value
                 AND NOT EXISTS
               (SELECT 1
                  FROM allArguments ua
                 WHERE ua.object_name = up.procedure_name
                   AND ( --function result or out, in/out argument in procedure
                        (ua.in_out IN ('OUT', 'IN/OUT')) OR
                       --procedure argument without default value
                        (ua.argument_name IS NOT NULL AND ua.defaulted = 'N')))
             )
            SELECT '"' || procedure_name || '"' as procedure_name
              FROM convention_runner_procedures
             WHERE (oo_method = 0) --no oo method in packge
                OR --some oo methods
                   (oo_method > 0 AND REGEXP_LIKE(UPPER(procedure_name), upper(a_method_only_regexp)))
             ORDER BY subprogram_id;
            -- NoFormat End
        type typ_tested_methods_tab is table of lcrs_tested_methods%rowtype;
        ltab_tested_methods typ_tested_methods_tab;
        --
    begin
        --
        -- NoFormat Start
        pete_logger.trace('RUN_PACKAGE: ' ||
                          'a_package_name_in:' || NVL(a_package_name_in, 'NULL') || ', ' ||
                          'a_method_name_like_in:' || NVL(a_method_name_like_in, 'NULL') || ', ' ||
                          'a_description_in:' || NVL(a_description_in, 'NULL') || ', ' ||
                          'a_parent_run_log_id_in:' || NVL(TO_CHAR(a_parent_run_log_id_in), 'NULL'));
        -- NoFormat End
        --l_owner := pete_utils.get_sql_schema_name(a_package_name_in => a_package_name_in);
        --l_package_name := pete_utils.get_sql_package_name(a_package_name_in => a_package_name_in);
        --
        l_run_log_id := pete_core.begin_test(a_object_name_in       => a_package_name_in,
                                             a_object_type_in       => pete_core.g_OBJECT_TYPE_PACKAGE,
                                             a_description_in       => a_description_in,
                                             a_parent_run_log_id_in => a_parent_run_log_id_in);
        pete_logger.trace('l_run_log_id ' || l_run_log_id);
        --
        if package_exists(a_package_name_in => a_package_name_in) then
            <<test>>
            begin
                pete_logger.trace('package exists');
                l_before_all_result := run_hook_method(a_package_name_in      => a_package_name_in,
                                                       a_hook_method_name_in  => 'BEFORE_ALL',
                                                       a_parent_run_log_id_in => l_run_log_id);
                l_result            := ABS(l_before_all_result) + ABS(l_result);
                pete_logger.trace('l_result: ' || l_result);
                if (l_before_all_result = pete_core.g_SUCCESS --before_all succeeded
                   or not pete_config.get_skip_if_before_hook_fails --continue if before_all failed
                   ) then
                    pete_logger.trace('looping over methods');
                    open lcrs_tested_methods(a_owner              => pete_utils.get_sql_schema_name(a_package_name_in => a_package_name_in),
                                             a_package_name       => pete_utils.get_sql_package_name(a_package_name_in => a_package_name_in),
                                             a_method_only_regexp => get_method_name_only_regexp,
                                             a_method_skip_regexp => get_method_name_skip_regexp);
                    fetch lcrs_tested_methods bulk collect
                        into ltab_tested_methods;
                    close lcrs_tested_methods;
                    <<tested_methods_loop>>
                    for iterator in 1 .. ltab_tested_methods.count loop
                        pete_logger.trace('run method ' || ltab_tested_methods(iterator).procedure_name || ' - before_each hook');
                        l_before_each_result := run_hook_method(a_package_name_in      => a_package_name_in,
                                                                a_hook_method_name_in  => 'BEFORE_EACH',
                                                                a_parent_run_log_id_in => l_run_log_id);
                        l_result             := ABS(l_before_each_result) + ABS(l_result);
                        pete_logger.trace('l_result: ' || l_result);
                        --
                        if l_before_each_result = pete_core.g_SUCCESS --before_each succeeded
                           or not pete_config.get_skip_if_before_hook_fails --continue if before_each failed
                         then
                            pete_logger.trace('run method ' || ltab_tested_methods(iterator).procedure_name);
                            l_result        := ABS(run_method(a_package_name_in      => a_package_name_in,
                                                              a_method_name_in       => ltab_tested_methods(iterator).procedure_name,
                                                              a_object_type_in       => pete_core.g_OBJECT_TYPE_METHOD,
                                                              a_parent_run_log_id_in => l_run_log_id)) + ABS(l_result);
                            l_something_run := true;
                        else
                            pete_logger.trace('method ' || ltab_tested_methods(iterator).procedure_name ||
                                              ' skipped - as before_each failed');
                        end if;
                        --
                        pete_logger.trace('run method ' || ltab_tested_methods(iterator).procedure_name || ' - after_each hook');
                        l_result := ABS(run_hook_method(a_package_name_in      => a_package_name_in,
                                                        a_hook_method_name_in  => 'AFTER_EACH',
                                                        a_parent_run_log_id_in => l_run_log_id)) + ABS(l_result);
                    end loop tested_methods_loop;
                else
                    pete_logger.trace('before_all failed - skipping all tests');
                end if;
            exception
                when others then
                    --TODO log error
                    pete_logger.trace('ERROR>' || sqlerrm);
                    pete_logger.trace('ERROR STACK>' || chr(10) || dbms_utility.format_error_stack);
                    pete_logger.trace('ERROR BACKTRACE>' || chr(10) || dbms_utility.format_error_backtrace);
                    l_result := pete_core.g_FAILURE;
            end test;
        
            --after all hook
            l_result := abs(l_result) + abs(run_hook_method(a_package_name_in      => a_package_name_in,
                                                            a_hook_method_name_in  => 'AFTER_ALL',
                                                            a_parent_run_log_id_in => l_run_log_id));
        
        else
            pete_logger.trace('unknown package  ' || a_package_name_in);
            l_result := pete_core.g_FAILURE;
        end if;
    
        if (not l_something_run and a_method_name_like_in is not null) then
            pete_logger.trace('nothing executed, even if I wanted -> failure');
            l_result := pete_core.g_FAILURE;
        end if;
    
        pete_logger.trace('l_result: ' || l_result);
    
        pete_core.end_test(a_run_log_id_in => l_run_log_id, a_execution_result_in => l_result);
        --
        return l_result;
        --
    end run_package;

    --------------------------------------------------------------------------------
    function run_suite
    (
        a_suite_name_in        in pete_types.typ_object_name default user,
        a_description_in       in pete_types.typ_description default null,
        a_parent_run_log_id_in in pete_run_log.parent_id%type default null
    ) return pete_types.typ_execution_result is
        l_result     pete_types.typ_execution_result := pete_core.g_SUCCESS;
        l_run_log_id integer;
        --
        --l_tst_pkg_only_regexp varchar2(255) := get_tst_pkg_only_regexp;
        --l_tst_pkg_regexp      varchar2(255) := get_tst_pkg_regexp;
        --l_method_only_regexp  varchar2(255) := get_method_name_only_regexp;
        --l_method_skip_regexp  varchar2(255) := get_method_name_skip_regexp;
        --
        -- NoFormat Start
        CURSOR lcrs_tested_packages(
            a_owner_in            in pete_types.typ_object_name,
            a_tst_pkg_regexp      in varchar2,
            a_tst_pkg_only_regexp in varchar2,
            a_method_only_regexp  in varchar2,
            a_method_skip_regexp  in varchar2
        ) IS
            WITH
                 allProcedures as (select * from all_procedures where owner = a_owner_in and REGEXP_LIKE(object_name, a_tst_pkg_regexp)),
                 allArguments  as (select * from all_arguments  where owner = a_owner_in and REGEXP_LIKE(package_name, a_tst_pkg_regexp)),
                 convention_runner_procedures AS
                 (SELECT /*+ materialize */
                         owner,
                         object_name,
                         procedure_name,
                         SUM(CASE WHEN REGEXP_LIKE(object_name, a_tst_pkg_only_regexp) THEN 1 ELSE 0 END) OVER() AS oo_package,
                         SUM(CASE WHEN REGEXP_LIKE(procedure_name, a_method_only_regexp) THEN 1 ELSE 0 END) OVER() AS oo_method
                    FROM allProcedures up
                   WHERE procedure_name IS NOT NULL
                     --skipped methods
                     --AND procedure_name NOT LIKE 'XX%'
                     AND NOT REGEXP_LIKE(procedure_name, a_method_skip_regexp)
                        -- it is not a function or a procedure with out/in_out arguments
                        -- or a procedure in argument without default value
                     AND NOT EXISTS
                   (SELECT 1
                      FROM allArguments ua
                     WHERE ua.object_name = up.procedure_name
                       AND ua.package_name = up.object_name
                       AND ( --function result or out, in/out argument in procedure
                            (ua.in_out IN ('OUT', 'IN/OUT')) OR
                           --procedure argument without default value
                            (ua.argument_name IS NOT NULL AND ua.defaulted = 'N')))
                 )
                SELECT DISTINCT '"' || owner || '"."' || object_name || '"' AS package_name
                  FROM convention_runner_procedures
                 WHERE (oo_method = 0 AND oo_package = 0) --no oo object
                    OR --oo package or oo method
                       ((oo_package > 0 AND REGEXP_LIKE(object_name, a_tst_pkg_only_regexp)) OR
                       (oo_method > 0 AND REGEXP_LIKE(procedure_name, a_method_only_regexp)))
                 ORDER BY package_name;
        -- NoFormat End
        --
    begin
        --
        -- NoFormat Start
        pete_logger.trace('RUN_SUITE: ' ||
                          'a_suite_name_in:' || NVL(a_suite_name_in, 'NULL') || ', ' ||
                          'a_description_in:' || NVL(a_description_in, 'NULL') || ', ' ||
                          'a_parent_run_log_id_in:' || NVL(TO_CHAR(a_parent_run_log_id_in), 'NULL'));
        -- NoFormat End
        l_run_log_id := pete_core.begin_test(a_object_name_in       => a_suite_name_in,
                                             a_object_type_in       => pete_core.g_OBJECT_TYPE_SUITE,
                                             a_description_in       => a_description_in,
                                             a_parent_run_log_id_in => a_parent_run_log_id_in);
        pete_logger.trace('l_run_log_id ' || l_run_log_id);
        --
        l_result := ABS(run_hook_method(a_package_name_in      => a_suite_name_in || '.PETE_BEFORE_ALL',
                                        a_hook_method_name_in  => 'RUN',
                                        a_parent_run_log_id_in => l_run_log_id)) + ABS(l_result);
        --
        <<tested_packages_loop>>
        for lrec_test_package in lcrs_tested_packages(a_owner_in            => pete_utils.get_sql_schema_name(a_schema_name_in => a_suite_name_in),
                                                      a_tst_pkg_regexp      => get_tst_pkg_regexp,
                                                      a_tst_pkg_only_regexp => get_tst_pkg_only_regexp,
                                                      a_method_only_regexp  => get_method_name_only_regexp,
                                                      a_method_skip_regexp  => get_method_name_skip_regexp) loop
            --
            pete_logger.trace('run package ' || lrec_test_package.package_name);
            l_result := ABS(run_hook_method(a_package_name_in      => a_suite_name_in || '.PETE_BEFORE_EACH',
                                            a_hook_method_name_in  => 'RUN',
                                            a_parent_run_log_id_in => l_run_log_id)) + ABS(l_result);
            --
            l_result := ABS(run_package(a_package_name_in => lrec_test_package.package_name, a_parent_run_log_id_in => l_run_log_id)) +
                        ABS(l_result);
            --
            l_result := ABS(run_hook_method(a_package_name_in      => a_suite_name_in || '.PETE_AFTER_EACH',
                                            a_hook_method_name_in  => 'RUN',
                                            a_parent_run_log_id_in => l_run_log_id)) + ABS(l_result);
            --
        end loop tested_packages_loop;
        --
        l_result := ABS(run_hook_method(a_package_name_in      => a_suite_name_in || '.PETE_AFTER_ALL',
                                        a_hook_method_name_in  => 'RUN',
                                        a_parent_run_log_id_in => l_run_log_id)) + ABS(l_result);
        --
        pete_logger.trace('l_result: ' || l_result);
        pete_core.end_test(a_run_log_id_in => l_run_log_id, a_execution_result_in => l_result);
        --
        return l_result;
        --
    end;

end;
/
