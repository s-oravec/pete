create or replace type petet_sum_interval as object
(

/* type implements oracles data cartridge interface to compute sum of day to second interval values */

  duration interval day to second, --duration accumulator

  constructor function petet_sum_interval return self as result
    parallel_enable,

  static function odciaggregateinitialize(ctx in out petet_sum_interval) return number,

  member function odciaggregateiterate
  (
    self  in out petet_sum_interval,
    value in interval day to second
  ) return number,

  member function odciaggregatedelete
  (
    self  in out petet_sum_interval,
    value in interval day to second
  ) return number,

  member function odciaggregateterminate
  (
    self        in petet_sum_interval,
    returnvalue out interval day to second,
    flags       in number
  ) return number,

  member function odciaggregatemerge
  (
    self in out petet_sum_interval,
    ctx  in petet_sum_interval
  ) return number
)
/
