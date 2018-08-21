create or replace package pete_utils as

    function get_enquoted_schema_name(a_schema_name_in in varchar2) return varchar2;
    function get_sql_schema_name(a_schema_name_in in varchar2) return varchar2;

    function get_enquoted_schema_name(a_package_name_in in varchar2) return varchar2;
    function get_sql_schema_name(a_package_name_in in varchar2) return varchar2;

    function get_enquoted_package_name(a_package_name_in in varchar2) return varchar2;
    function get_sql_package_name(a_package_name_in in varchar2) return varchar2;

end;
/
