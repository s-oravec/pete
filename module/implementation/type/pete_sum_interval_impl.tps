create or replace type pete_sum_interval_impl as object
(

/* type implements oracles data cartridge interface to compute sum of day to second interval values */

  duration interval day to second, --duration accumulator

  constructor function pete_sum_interval_impl return self as result
    parallel_enable,

  static function odciaggregateinitialize(ctx in out pete_sum_interval_impl) return number,

  member function odciaggregateiterate
  (
    self  in out pete_sum_interval_impl,
    value in interval day to second
  ) return number,

  member function odciaggregatedelete
  (
    self  in out pete_sum_interval_impl,
    value in interval day to second
  ) return number,

  member function odciaggregateterminate
  (
    self        in pete_sum_interval_impl,
    returnvalue out interval day to second,
    flags       in number
  ) return number,

  member function odciaggregatemerge
  (
    self in out pete_sum_interval_impl,
    ctx  in pete_sum_interval_impl
  ) return number
)
/
