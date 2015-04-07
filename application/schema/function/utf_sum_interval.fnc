create or replace function utf_sum_interval(duration interval day to second) return interval day to second
  parallel_enable
  aggregate using utt_sum_interval;
/
