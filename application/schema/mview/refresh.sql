--@&&run_dir_begin

prompt Refreshing mview UTM_METADATA_FUNCTION_RESULT
exec dbms_mview.refresh('UTM_METADATA_FUNCTION_RESULT', 'C');

prompt Refreshing mview UTM_METADATA_MTDS_WTH_REC_ARG
exec dbms_mview.refresh('UTM_METADATA_MTDS_WTH_REC_ARG', 'C');

prompt Refreshing mview UTM_METADATA_ARGUMENTS
exec dbms_mview.refresh('UTM_METADATA_ARGUMENTS', 'C');

prompt Refreshing mview UTM_METADATA_METHODS
exec dbms_mview.refresh('UTM_METADATA_METHODS', 'C'); -- depends on UTM_METADATA_FUNCTION_RESULT

prompt Refreshing mview UTM_METADATA_METHODS_API_TYPES
exec dbms_mview.refresh('UTM_METADATA_METHODS_API_TYPES', 'C'); -- depends on UTM_METADATA_METHODS

--@&&run_dir_end


