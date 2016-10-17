CREATE OR REPLACE FORCE view petev_test_case_in_suite AS
SELECT cis.id,
       cis.test_suite_id,
       cis.test_case_id,
       tc.test_case,
       cis.position,
       cis.stop_on_failure,
       cis.run_modifier,
       cis.description,
       petet_test_case_in_suite(cis.id,
                                cis.test_suite_id,                                
                                cis.test_case_id,
                                tc.test_case,
                                cis.position,
                                cis.stop_on_failure,
                                cis.run_modifier,
                                cis.description) AS test_case_in_suite
  FROM pete_test_case_in_suite cis
  JOIN petev_test_case tc ON (tc.id = cis.test_case_id);
