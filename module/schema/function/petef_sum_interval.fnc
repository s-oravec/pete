create or replace function petef_sum_interval(duration interval day to second) return interval day to second
  parallel_enable
  aggregate using petet_sum_interval;
/
