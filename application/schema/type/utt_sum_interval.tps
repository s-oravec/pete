create or replace type utt_sum_interval as object
(

/* type implements oracles data cartridge interface to compute sum of day to second interval values */

  duration interval day to second, --duration accumulator

  constructor function utt_sum_interval return self as result
    parallel_enable,

  static function odciaggregateinitialize(ctx in out utt_sum_interval) return number,

  member function odciaggregateiterate
  (
    self  in out utt_sum_interval,
    value in interval day to second
  ) return number,

  member function odciaggregatedelete
  (
    self  in out utt_sum_interval,
    value in interval day to second
  ) return number,

  member function odciaggregateterminate
  (
    self        in utt_sum_interval,
    returnvalue out interval day to second,
    flags       in number
  ) return number,

  member function odciaggregatemerge
  (
    self in out utt_sum_interval,
    ctx  in utt_sum_interval
  ) return number
)
/
