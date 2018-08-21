create or replace package body pete_assert is

    gc_null     constant varchar2(4) := 'NULL';
    gc_not_null constant varchar2(10) := 'NOT NULL';

    gc_diff_window_size constant number := 20;
    --
    -- converts a boolean value to a string representation - 'TRUE', 'FALSE', 'NULL'
    --------------------------------------------------------------------------------
    function bool2char(a_bool_in in boolean) return varchar2 is
    begin
        if (a_bool_in) then
            return 'TRUE';
        elsif (not a_bool_in) then
            return 'FALSE';
        else
            return 'NULL';
        end if;
    end;

    --
    -- parse formated call stack and get stack before call of assert package
    --------------------------------------------------------------------------------  
    function get_call_stack_before_assert return varchar2 is
        l_stack    varchar2(32767);
        l_from_pos number;
        --TODO: use precompiler directives here to get package name or set as literal during installation      
        lc_ASSERT_PACKAGE constant varchar2(61) := user || '.PETE_ASSERT';
        l_Result varchar2(32767);
    begin
        pete_logger.trace('GET_CALL_STACK_BEFORE_ASSERT');
        --
        l_stack := dbms_utility.format_call_stack;
        pete_logger.trace('stack: ' || chr(10) || l_stack);
        -- find las occurence of lc_ASSERT_PACKAGE in stack
        l_from_pos := 1;
        while INSTR(l_stack, lc_ASSERT_PACKAGE, l_from_pos) > 0 loop
            l_from_pos := INSTR(l_stack, lc_ASSERT_PACKAGE, l_from_pos) + LENGTH(lc_ASSERT_PACKAGE) + 1;
        end loop;
        --
        l_Result := trim(SUBSTR(l_stack, l_from_pos));
        pete_logger.trace('GET_CALL_STACK_BEFORE_ASSERT> ' || chr(10) || l_Result);
        return l_Result;
        --
    end;

    --
    --TODO: review: what is use for this?
    --TODO: reviewed: it was used to display package and linenumber of an assert - to locate it easily. This feature was killed during the refactoring
    --------------------------------------------------------------------------------
    procedure get_assert_caller_info
    (
        a_object_name_out out varchar2,
        a_plsq_line_out   out number
    ) is
        l_stack varchar2(32767);
    begin
        pete_logger.trace('GET_ASSERT_CALLER_INFO');
        l_stack           := get_call_stack_before_assert;
        a_object_name_out := trim(REGEXP_SUBSTR(l_stack, '([xa-f0-9]+[ ]+)([0-9]+)(.*)', 1, 1, 'i', 3));
        a_plsq_line_out   := TO_NUMBER(REGEXP_SUBSTR(l_stack, '([xa-f0-9]+[ ]+)([0-9]+)(.*)', 1, 1, 'i', 2));
        pete_logger.trace('GET_ASSERT_CALLER_INFO> a_object_name_out:' || a_object_name_out || ', a_plsq_line_out:' || a_plsq_line_out);
    end;

    --------------------------------------------------------------------------------
    procedure this
    (
        a_value_in      in boolean,
        a_comment_in    in varchar2,
        a_expected_in   in varchar2,
        a_actual_in     in varchar2,
        a_plsql_unit_in in varchar2,
        a_plsql_line_in in integer
    ) is
        l_plsql_unit varchar2(255);
        l_plsql_line integer;
    begin
        -- NoFormat Start
        pete_logger.trace('THIS: ' ||
                          'a_value_in:' || NVL(CASE WHEN a_value_in THEN 'TRUE' WHEN NOT a_value_in THEN 'FALSE' ELSE NULL END, 'NULL') || ', ' ||
                          'a_comment_in:' || NVL(a_comment_in, 'NULL') || ', ' ||
                          'a_expected_in:' || NVL(a_expected_in, 'NULL') || ', ' ||
                          'a_actual_in:' || NVL(a_actual_in, 'NULL'));
        -- NoFormat End
        if a_value_in then
            pete_logger.trace('assert this - true');
            --
            --log assert only when running in test
            if pete_core.get_last_run_log_id is not null then
                if a_plsql_unit_in is null then
                    get_assert_caller_info(a_object_name_out => l_plsql_unit, a_plsq_line_out => l_plsql_line);
                end if;
                pete_logger.log_assert(a_result_in     => true,
                                       a_comment_in    => a_comment_in,
                                       a_plsql_unit_in => nvl(a_plsql_unit_in, l_plsql_unit),
                                       a_plsql_line_in => nvl(a_plsql_line_in, l_plsql_line));
            end if;
        
        else
            pete_logger.trace('assert this - false');
            --
            --log assert only when running in test
            if pete_core.get_last_run_log_id is not null then
                if a_plsql_unit_in is null then
                    get_assert_caller_info(a_object_name_out => l_plsql_unit, a_plsq_line_out => l_plsql_line);
                end if;
                pete_logger.log_assert(a_result_in     => false,
                                       a_comment_in    => a_comment_in,
                                       a_plsql_unit_in => nvl(a_plsql_unit_in, l_plsql_unit),
                                       a_plsql_line_in => nvl(a_plsql_line_in, l_plsql_line));
            end if;
            --
            raise_application_error(-20000,
                                    'Assertion failed: ' || a_comment_in || CHR(10) || --
                                    'Expected:' || a_expected_in || CHR(10) || --
                                    'Actual:  ' || a_actual_in);
        end if;
    end;

    procedure this
    (
        a_value_in      in boolean,
        a_comment_in    in varchar2 default null,
        a_plsql_unit_in in varchar2 default null,
        a_plsql_line_in integer default null
    ) is
    begin
        this(a_value_in      => a_value_in,
             a_comment_in    => NVL(a_comment_in, 'Expected value to be true'),
             a_expected_in   => 'TRUE',
             a_actual_in     => bool2char(a_value_in),
             a_plsql_unit_in => a_plsql_unit_in,
             a_plsql_line_in => a_plsql_line_in);
    end;

    -- 
    -- Group of assert procedure for testing null values
    --------------------------------------------------------------------------------
    function is_null(a_value_in in number) return boolean is
    begin
        return a_value_in is null;
    end;

    --------------------------------------------------------------------------------
    procedure is_null
    (
        a_value_in      in number,
        a_comment_in    in varchar2 default null,
        a_plsql_unit_in in varchar2 default null,
        a_plsql_line_in integer default null
        
    ) is
    begin
        this(is_null(a_value_in => a_value_in),
             NVL(a_comment_in, a_value_in || ' is expected to be null.'),
             gc_null,
             TO_CHAR(a_value_in),
             a_plsql_unit_in,
             a_plsql_line_in);
    end;

    --------------------------------------------------------------------------------
    function is_null(a_value_in in varchar2) return boolean is
    begin
        return a_value_in is null;
    end;

    --------------------------------------------------------------------------------
    procedure is_null
    (
        a_value_in      in varchar2,
        a_comment_in    in varchar2 default null,
        a_plsql_unit_in in varchar2 default null,
        a_plsql_line_in integer default null
    ) is
    begin
        this(is_null(a_value_in => a_value_in),
             NVL(a_comment_in, a_value_in || ' is expected to be null.'),
             gc_null,
             a_value_in,
             a_plsql_unit_in,
             a_plsql_line_in);
    end;

    --------------------------------------------------------------------------------
    function is_null(a_value_in in date) return boolean is
    begin
        return a_value_in is null;
    end;

    --------------------------------------------------------------------------------
    procedure is_null
    (
        a_value_in      in date,
        a_comment_in    in varchar2 default null,
        a_plsql_unit_in in varchar2 default null,
        a_plsql_line_in integer default null
    ) is
    begin
        this(is_null(a_value_in => a_value_in),
             NVL(a_comment_in, a_value_in || ' is expected to be null.'),
             gc_null,
             TO_CHAR(a_value_in, pete_config.get_date_format),
             a_plsql_unit_in,
             a_plsql_line_in);
    end;

    -- 
    -- Group of assert procedure for testing null values
    --------------------------------------------------------------------------------
    function is_not_null(a_value_in in number) return boolean is
    begin
        return a_value_in is not null;
    end;

    procedure is_not_null
    (
        a_value_in      in number,
        a_comment_in    in varchar2 default null,
        a_plsql_unit_in in varchar2 default null,
        a_plsql_line_in integer default null
    ) is
    begin
        this(is_not_null(a_value_in => a_value_in),
             NVL(a_comment_in, a_value_in || ' is expected to be not null.'),
             gc_not_null,
             TO_CHAR(a_value_in),
             a_plsql_unit_in,
             a_plsql_line_in);
    end;

    --------------------------------------------------------------------------------
    function is_not_null(a_value_in in varchar2) return boolean is
    begin
        return a_value_in is not null;
    end;

    --------------------------------------------------------------------------------
    procedure is_not_null
    (
        a_value_in      in varchar2,
        a_comment_in    in varchar2 default null,
        a_plsql_unit_in in varchar2 default null,
        a_plsql_line_in integer default null
    ) is
    begin
        this(is_not_null(a_value_in => a_value_in),
             NVL(a_comment_in, a_value_in || ' is expected to be not null.'),
             gc_not_null,
             a_value_in,
             a_plsql_unit_in,
             a_plsql_line_in);
    end;

    --------------------------------------------------------------------------------
    function is_not_null(a_value_in in date) return boolean is
    begin
        return a_value_in is not null;
    end;

    --------------------------------------------------------------------------------
    procedure is_not_null
    (
        a_value_in      in date,
        a_comment_in    in varchar2 default null,
        a_plsql_unit_in in varchar2 default null,
        a_plsql_line_in integer default null
    ) is
    begin
        this(is_not_null(a_value_in => a_value_in),
             NVL(a_comment_in, a_value_in || ' is expected to be not null.'),
             gc_not_null,
             TO_CHAR(a_value_in, pete_config.get_date_format),
             a_plsql_unit_in,
             a_plsql_line_in);
    end;

    --
    -- This assert procedure always succeeds. It's usefull to log, that something has
    -- happened if it is difficult to test it's value
    --------------------------------------------------------------------------------
    function pass return boolean is
    begin
        return true;
    end;

    --------------------------------------------------------------------------------
    procedure pass
    (
        a_comment_in    in varchar2 default null,
        a_plsql_unit_in in varchar2 default null,
        a_plsql_line_in integer default null
    ) is
    begin
        this(pass, NVL(a_comment_in, 'Passed!!!'), null, null, a_plsql_unit_in, a_plsql_line_in);
    end;

    --
    -- This assert procedure always fails. It's usefull in a branch of code where the
    -- program should never enter. E.g. in an exception block
    --------------------------------------------------------------------------------
    function fail return boolean is
    begin
        return false;
    end;

    --------------------------------------------------------------------------------
    procedure fail
    (
        a_comment_in    in varchar2 default null,
        a_plsql_unit_in in varchar2 default null,
        a_plsql_line_in integer default null
    ) is
    begin
        this(fail, NVL(a_comment_in, 'You shall not pass!!!'), 'FAIL', 'FAIL!!!', a_plsql_unit_in, a_plsql_line_in);
    end;

    --
    -- Group of assert procedures for testing equality of input arguments
    -- Nulls are considered equal
    --------------------------------------------------------------------------------
    function eq
    (
        a_expected_in number,
        a_actual_in   number
    ) return boolean is
    begin
        return a_expected_in = a_actual_in or(a_expected_in is null and a_actual_in is null);
    end;

    --------------------------------------------------------------------------------
    procedure eq
    (
        a_expected_in   number,
        a_actual_in     number,
        a_comment_in    varchar2 default null,
        a_plsql_unit_in in varchar2 default null,
        a_plsql_line_in integer default null
    ) is
    begin
        -- NoFormat Start
        this(a_value_in        => eq(a_expected_in => a_expected_in, a_actual_in => a_actual_in),
             a_comment_in      => NVL(a_comment_in, to_char(a_actual_in) || ' is expected to be equal to ' || to_char(a_expected_in)),
             a_expected_in     => to_char(a_expected_in),
             a_actual_in       => to_char(a_actual_in),
             a_plsql_unit_in => a_plsql_unit_in,
             a_plsql_line_in         => a_plsql_line_in);
        -- NoFormat End
    end;

    --------------------------------------------------------------------------------
    function eq
    (
        a_expected_in varchar2,
        a_actual_in   varchar2
    ) return boolean is
    begin
        return a_expected_in = a_actual_in or(a_expected_in is null and a_actual_in is null);
    end;

    --------------------------------------------------------------------------------
    procedure eq
    (
        a_expected_in   varchar2,
        a_actual_in     varchar2,
        a_comment_in    varchar2 default null,
        a_plsql_unit_in in varchar2 default null,
        a_plsql_line_in integer default null
    ) is
    begin
        -- TODO: to_char(date, format) - format to pete_config
        -- NoFormat Start
        this(a_value_in    => eq(a_expected_in => a_expected_in, a_actual_in => a_actual_in),
             a_comment_in  => NVL(a_comment_in, a_actual_in || ' is expected to be equal to ' || a_expected_in),
             a_expected_in => a_expected_in,
             a_actual_in   => a_actual_in,
             a_plsql_unit_in => a_plsql_unit_in,
             a_plsql_line_in         => a_plsql_line_in);
        -- NoFormat End
    end;

    --------------------------------------------------------------------------------
    function eq
    (
        a_expected_in date,
        a_actual_in   date
    ) return boolean is
    begin
        return a_expected_in = a_actual_in or(a_expected_in is null and a_actual_in is null);
    end;

    --------------------------------------------------------------------------------
    procedure eq
    (
        a_expected_in   date,
        a_actual_in     date,
        a_comment_in    varchar2 default null,
        a_plsql_unit_in in varchar2 default null,
        a_plsql_line_in integer default null
    ) is
    begin
        -- TODO: to_char(date, format) - format to pete_config
        -- NoFormat Start
        this(a_value_in    => eq(a_expected_in => a_expected_in, a_actual_in => a_actual_in),
             a_comment_in  => NVL(a_comment_in, to_char(a_actual_in) || ' is expected to be equal to ' || to_char(a_expected_in)),
             a_expected_in => to_char(a_expected_in),
             a_actual_in   => to_char(a_actual_in),
             a_plsql_unit_in => a_plsql_unit_in,
             a_plsql_line_in         => a_plsql_line_in);
        -- NoFormat End
    end;

    --------------------------------------------------------------------------------
    function eq
    (
        a_expected_in boolean,
        a_actual_in   boolean
    ) return boolean is
    begin
        return a_expected_in = a_actual_in or(a_expected_in is null and a_actual_in is null);
    end;

    --------------------------------------------------------------------------------
    procedure eq
    (
        a_expected_in   boolean,
        a_actual_in     boolean,
        a_comment_in    varchar2 default null,
        a_plsql_unit_in in varchar2 default null,
        a_plsql_line_in integer default null
    ) is
    begin
        -- NoFormat Start
        this(a_value_in    => eq(a_expected_in => a_expected_in, a_actual_in => a_actual_in),
             a_comment_in  => NVL(a_comment_in, bool2char(a_actual_in) || ' is expected to be equal to ' || bool2char(a_expected_in)),
             a_expected_in => bool2char(a_expected_in),
             a_actual_in   => bool2char(a_actual_in),
             a_plsql_unit_in => a_plsql_unit_in,
             a_plsql_line_in         => a_plsql_line_in);
        -- NoFormat End
    end;

    --------------------------------------------------------------------------------
    function eq
    (
        a_expected_in in sys.xmltype,
        a_actual_in   in sys.xmltype
    ) return boolean is
    begin
        if (a_expected_in is null and a_actual_in is not null or a_expected_in is not null and a_actual_in is null) then
            return false;
        elsif (a_expected_in is null and a_actual_in is null) then
            return true;
        else
            return a_expected_in.extract('/').getclobval = a_actual_in.extract('/').getclobval;
        end if;
    end;

    -- 
    -- helper procedure which finds beginning of difference between char representation
    -- of two non empty xmltypes. It returns position of first difference
    function get_diff_position
    (
        a_xml_in  in xmltype,
        a_xml2_in xmltype
    ) return number is
    
        l_clob   clob;
        l_clob2  clob;
        l_Result number;
        l_POS    number;
        l_max    number;
        l_step   number;
        l_nahoru boolean;
    begin
    
        l_clob  := a_xml_in.extract('/').getclobval();
        l_clob2 := a_xml2_in.extract('/').getclobval();
        l_max   := (length(l_clob) + length(l_clob2)) / 2;
        --smallest greater power of 2
        l_max    := power(2, ceil(log(2, l_max)));
        l_step   := l_max / 2;
        l_POS    := l_max;
        l_nahoru := false;
        while l_step >= 1 loop
            if (l_nahoru) then
                l_POS := l_POS + l_step;
            else
                l_POS := l_POS - l_step;
            end if;
            if (substr(l_clob, 1, l_POS) = substr(l_clob2, 1, l_POS)) then
                l_nahoru := true;
            else
                l_nahoru := false;
            end if;
            l_step := l_step / 2;
        end loop;
        if (l_nahoru) then
            return l_POS + 1;
        else
            return l_POS;
        end if;
        /*                FOR x IN 1 .. length(l_clob)
                        LOOP
                            IF (substr(l_clob, x, 1) <> substr(l_clob2, x, 1))
                            THEN
                                l_result := x;
                                EXIT;
                            END IF;
                        END LOOP;
        */
        return l_Result;
    end;

    --------------------------------------------------------------------------------
    procedure eq
    (
        a_expected_in   in sys.xmltype,
        a_actual_in     in sys.xmltype,
        a_comment_in    in varchar2 default null,
        a_plsql_unit_in in varchar2 default null,
        a_plsql_line_in integer default null
    ) is
        l_this    boolean;
        l_comment varchar2(500) := a_comment_in;
        l_Diff    number;
    begin
        l_this := eq(a_expected_in => a_expected_in, a_actual_in => a_actual_in);
        if l_this then
            if l_comment is null then
                if a_expected_in is null then
                    l_comment := 'exmpty xmlType equals empty xmlType';
                else
                    l_comment := 'xmlTypes equals each other';
                end if;
            end if;
            this(a_value_in => l_this, a_comment_in => l_comment);
        else
            -- not equal
            if (a_expected_in is null) then
                this(a_value_in      => l_this,
                     a_comment_in    => NVL(a_comment_in,
                                            substr(a_actual_in.extract('/').getclobval, 1, 100) || '... is expected to be equal to <NULL>'),
                     a_expected_in   => '<NULL>',
                     a_actual_in     => substr(a_actual_in.extract('/').getclobval, 1, 100) || '...',
                     a_plsql_unit_in => a_plsql_unit_in,
                     a_plsql_line_in => a_plsql_line_in);
            elsif (a_actual_in is null) then
                this(a_value_in      => l_this,
                     a_comment_in    => NVL(a_comment_in,
                                            '<NULL> is expected to be equal to ' || substr(a_actual_in.extract('/').getclobval, 1, 100) ||
                                            '...'),
                     a_expected_in   => substr(a_actual_in.extract('/').getclobval, 1, 100) || '...',
                     a_actual_in     => '<NULL>',
                     a_plsql_unit_in => a_plsql_unit_in,
                     a_plsql_line_in => a_plsql_line_in);
            else
                --         find_difference(a_xml_in => a_expected_in, a_xml2_in => a_actual_in, a_diff_from => l_from, a_diff_to => l_to);
                l_Diff := get_diff_position(a_xml_in => a_expected_in, a_xml2_in => a_actual_in);
                this(a_value_in      => l_this,
                     a_comment_in    => NVL(a_comment_in,
                                            substr(a_actual_in.extract('/').getclobval, 1, 100) || '...' || chr(10) ||
                                            'is expected to be equal to: ' || substr(a_expected_in.extract('/').getclobval, 1, 100) || '...' ||
                                            chr(10)),
                     a_expected_in   => substr(a_expected_in.extract('/').getclobval,
                                               greatest(l_Diff - gc_diff_window_size / 2, 1),
                                               gc_diff_window_size),
                     a_actual_in     => substr(a_actual_in.extract('/').getclobval,
                                               greatest(l_Diff - gc_diff_window_size / 2, 1),
                                               gc_diff_window_size) || chr(10) || 'Difference starts at position ' || l_Diff,
                     a_plsql_unit_in => a_plsql_unit_in,
                     a_plsql_line_in => a_plsql_line_in);
            end if;
        end if;
    end;

end;
/
