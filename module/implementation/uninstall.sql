prompt .. Dropping sequence PETE_RUN_LOG_SEQ
drop sequence pete_run_log_seq;

prompt .. Dropping table PETE_CONFIGURATION
drop table pete_configuration purge;
prompt .. Dropping table PETE_RUN_LOG
drop table pete_run_log purge;

prompt .. Dropping view PETEV_OUTPUT_RUN_LOG
drop view petev_output_run_log;

prompt .. Dropping type PETE_LOG_ITEMS
drop type pete_log_items;
prompt .. Dropping type PETE_LOG_ITEM
drop type pete_log_item;
prompt .. Dropping type PETE_SUM_INTERVAL_IMPL
drop type pete_sum_interval_impl;

prompt .. Dropping function PETE_SUM_INTERVAL
drop function pete_sum_interval;

prompt .. Dropping package PETE_CONVENTION_RUNNER
drop package pete_convention_runner;
prompt .. Dropping package PETE_CORE
drop package pete_core;
prompt .. Dropping package PETE_EXCEPTION
drop package pete_exception;
prompt .. Dropping package PETE_LOGGER
drop package pete_logger;
prompt .. Dropping package PETE_UTILS
drop package pete_utils;
prompt .. Dropping package PETE_TYPES
drop package pete_types;
prompt .. Dropping package PETE_CONFIG_IMPL
drop package pete_config_impl;


