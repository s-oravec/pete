create or replace type body pete_sum_interval_impl is

    -------------------------------------------------------------------------------------------------
    constructor function pete_sum_interval_impl return self as result
        parallel_enable is
    begin
        return;
    end pete_sum_interval_impl;

    -------------------------------------------------------------------------------------------------
    static function odciaggregateinitialize(ctx in out pete_sum_interval_impl) return number is
    begin
        ctx := pete_sum_interval_impl();
        return odciconst.success;
    end odciaggregateinitialize;

    -------------------------------------------------------------------------------------------------
    member function odciaggregateiterate
    (
        self  in out pete_sum_interval_impl,
        value in interval day to second
    ) return number is
    begin
        if SELF.duration is null then
            SELF.duration := value;
        else
            SELF.duration := SELF.duration + value;
        end if;
        return odciconst.success;
    end odciaggregateiterate;

    -------------------------------------------------------------------------------------------------
    member function odciaggregateterminate
    (
        self        in pete_sum_interval_impl,
        returnvalue out interval day to second,
        flags       in number
    ) return number is
    begin
        returnvalue := SELF.duration;
        return odciconst.success;
    end odciaggregateterminate;

    -------------------------------------------------------------------------------------------------
    member function odciaggregatedelete
    (
        self  in out pete_sum_interval_impl,
        value in interval day to second
    ) return number is
    begin
        SELF.duration := SELF.duration - value;
        return odciconst.success;
    end odciaggregatedelete;

    -------------------------------------------------------------------------------------------------
    member function odciaggregatemerge
    (
        self in out pete_sum_interval_impl,
        ctx  in pete_sum_interval_impl
    ) return number is
    begin
        if ctx.duration is null then
            null;
        else
            SELF.duration := SELF.duration + ctx.duration;
        end if;
        return odciconst.success;
    end odciaggregatemerge;

end;
/
