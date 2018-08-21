create or replace package pete_assert as

    --
    -- Pete assert package
    --

    --
    -- Basic assert procedure. Every other procedure transforms it's arguments and calls this one
    --
    -- %argument a_value_in value, that is expected to be true
    -- %argument a_comment_in comment in case of failing assert
    --
    procedure this
    (
        a_value_in      in boolean,
        a_comment_in    in varchar2 default null,
        a_plsql_unit_in in varchar2 default null,
        a_plsql_line_in integer default null
    );

    -- 
    -- Group of assert procedure for testing null values
    --
    procedure is_null
    (
        a_value_in      in number,
        a_comment_in    in varchar2 default null,
        a_plsql_unit_in in varchar2 default null,
        a_plsql_line_in integer default null
    );

    function is_null(a_value_in in number) return boolean;

    procedure is_null
    (
        a_value_in      in varchar2,
        a_comment_in    in varchar2 default null,
        a_plsql_unit_in in varchar2 default null,
        a_plsql_line_in integer default null
    );

    function is_null(a_value_in in varchar2) return boolean;

    procedure is_null
    (
        a_value_in      in date,
        a_comment_in    in varchar2 default null,
        a_plsql_unit_in in varchar2 default null,
        a_plsql_line_in integer default null
    );

    function is_null(a_value_in in date) return boolean;

    -- 
    -- Group of assert procedure for testing null values
    --
    procedure is_not_null
    (
        a_value_in      in number,
        a_comment_in    in varchar2 default null,
        a_plsql_unit_in in varchar2 default null,
        a_plsql_line_in integer default null
    );

    function is_not_null(a_value_in in number) return boolean;

    procedure is_not_null
    (
        a_value_in      in varchar2,
        a_comment_in    in varchar2 default null,
        a_plsql_unit_in in varchar2 default null,
        a_plsql_line_in integer default null
    );

    function is_not_null(a_value_in in varchar2) return boolean;

    procedure is_not_null
    (
        a_value_in      in date,
        a_comment_in    in varchar2 default null,
        a_plsql_unit_in in varchar2 default null,
        a_plsql_line_in integer default null
    );

    function is_not_null(a_value_in in date) return boolean;

    --
    -- This assert procedure always succeeds. It's usefull to log, that something has
    -- happened if it is difficult to test it's value
    --
    procedure pass
    (
        a_comment_in    in varchar2 default null,
        a_plsql_unit_in in varchar2 default null,
        a_plsql_line_in integer default null
    );

    function pass return boolean;

    --
    -- This assert procedure always fails. It's usefull in a branch of code where the
    -- program should never enter. E.g. in an exception block
    --
    procedure fail
    (
        a_comment_in    in varchar2 default null,
        a_plsql_unit_in in varchar2 default null,
        a_plsql_line_in integer default null
    );

    function fail return boolean;

    --
    -- Group of assert procedures for testing equality of input arguments
    -- Nulls are considered equal
    --
    procedure eq
    (
        a_expected_in   in number,
        a_actual_in     in number,
        a_comment_in    in varchar2 default null,
        a_plsql_unit_in in varchar2 default null,
        a_plsql_line_in integer default null
    );

    function eq
    (
        a_expected_in in number,
        a_actual_in   in number
    ) return boolean;

    procedure eq
    (
        a_expected_in   in varchar2,
        a_actual_in     in varchar2,
        a_comment_in    in varchar2 default null,
        a_plsql_unit_in in varchar2 default null,
        a_plsql_line_in integer default null
    );

    function eq
    (
        a_expected_in in varchar2,
        a_actual_in   in varchar2
    ) return boolean;

    procedure eq
    (
        a_expected_in   in date,
        a_actual_in     in date,
        a_comment_in    in varchar2 default null,
        a_plsql_unit_in in varchar2 default null,
        a_plsql_line_in integer default null
    );

    function eq
    (
        a_expected_in in date,
        a_actual_in   in date
    ) return boolean;

    procedure eq
    (
        a_expected_in   in boolean,
        a_actual_in     in boolean,
        a_comment_in    in varchar2 default null,
        a_plsql_unit_in in varchar2 default null,
        a_plsql_line_in integer default null
    );

    function eq
    (
        a_expected_in in boolean,
        a_actual_in   in boolean
    ) return boolean;

    procedure eq
    (
        a_expected_in   in sys.xmltype,
        a_actual_in     in sys.xmltype,
        a_comment_in    in varchar2 default null,
        a_plsql_unit_in in varchar2 default null,
        a_plsql_line_in integer default null
    );

    function eq
    (
        a_expected_in in sys.xmltype,
        a_actual_in   in sys.xmltype
    ) return boolean;

end pete_assert;
/
