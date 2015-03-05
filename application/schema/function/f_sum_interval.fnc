create or replace function f_sum_interval(duration interval day to second) return interval day to second
  parallel_enable
  aggregate using t_sum_interval;
/

