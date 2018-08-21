create or replace function pete_sum_interval(duration interval day to second) return interval day to second
  parallel_enable
  aggregate using pete_sum_interval_impl;
/
