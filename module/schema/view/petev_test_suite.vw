CREATE OR REPLACE FORCE view petev_test_suite AS
SELECT ts.id,
       ts.name,
       ts.stop_on_failure,
       ts.run_modifier,
       ts.description,
       petet_test_suite(ts.id,
                        ts.name,
                        ts.stop_on_failure,
                        ts.run_modifier,
                        ts.description,
                        (SELECT CAST(COLLECT(cis.test_case_in_suite) AS
                                     petet_test_cases_in_suite)
                           FROM petev_test_case_in_suite cis
                          WHERE cis.test_suite_id = ts.id)) AS test_suite
  FROM pete_test_suite ts;
