CREATE OR REPLACE PACKAGE BODY pete_utils AS

    --------------------------------------------------------------------------------
    function get_enquoted_schema_name(a_schema_name_in in varchar2) return varchar2
    is
    begin
        if a_schema_name_in is null then
            return dbms_assert.ENQUOTE_NAME(user);
        else
            return dbms_assert.ENQUOTE_NAME(a_schema_name_in);
        end if;
    end;

    --------------------------------------------------------------------------------
    function get_sql_schema_name(a_schema_name_in in varchar2) return varchar2
    is
    begin
        return replace(get_enquoted_schema_name(a_schema_name_in => a_schema_name_in), '"');
    end;

    --------------------------------------------------------------------------------
    function get_enquoted_schema_name(a_package_name_in in varchar2) return varchar2
    is
    begin
        if a_package_name_in is null then
            return null;
        elsif instr(a_package_name_in, '.') = 0 then
            return dbms_assert.ENQUOTE_NAME(user);
        else
            return dbms_assert.ENQUOTE_NAME(substr(a_package_name_in, 1, instr(a_package_name_in, '.') -1));
        end if;
    end;

    --------------------------------------------------------------------------------
    function get_sql_schema_name(a_package_name_in in varchar2) return varchar2
    is
    begin
        return replace(get_enquoted_schema_name(a_package_name_in => a_package_name_in), '"');
    end;

    --------------------------------------------------------------------------------
    function get_enquoted_package_name(a_package_name_in in varchar2) return varchar2
    is
    begin
        if a_package_name_in is null then
            return null;
        elsif instr(a_package_name_in, '.') = 0 then
            return dbms_assert.ENQUOTE_NAME(a_package_name_in);
        else
            return dbms_assert.ENQUOTE_NAME(substr(a_package_name_in, instr(a_package_name_in, '.') + 1));
        end if;
    end;

    --------------------------------------------------------------------------------
    function get_sql_package_name(a_package_name_in in varchar2) return varchar2
    is
    begin
        return replace(get_enquoted_package_name(a_package_name_in => a_package_name_in), '"');
    end;

END;
/
