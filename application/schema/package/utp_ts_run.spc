create or replace package utp_ts_run is
  /* Package for running unit tests
  */

  /* Subtype for boolean stored as Y/N
  */
  subtype gtyp_string_boolean is char(1);
  -- Yes, true
  gc_true  constant gtyp_string_boolean := 'Y';
  -- No, false
  gc_false constant gtyp_string_boolean := 'N';

  /* Run test case identified by test case id
  
  %param p_id Test case identifier - ut_test_case.id
  */
  procedure run_test_case(p_id in ut_test_case.id%type);

  /* Run test case identified by test case code - ut_test_case.code
  
  %param p_code Test case code - ut_test_case.code
  */
  procedure run_test_case(p_code ut_test_case.code%type);

  /* Run test script identified by test script identifier - ut_test_script.id
  
  %param p_id test script identifier - ut_test_script.id
  */
  procedure run_test_script(p_id ut_test_script.id%type);

  /* Run test script identified by test script code - ut_test_script.code
  
  %param p_code  test script code - ut_test_script.code
  */
  procedure run_test_script(p_code ut_test_script.code%type);

  /* Run all test scripts
  
  %param p_catch_exception  boolean - ('Y','N') 'Y' - continue executing scripts after exception
  */
  procedure run_all_test_scripts(p_catch_exception in gtyp_string_boolean default gc_true);

end utp_ts_run;
/
