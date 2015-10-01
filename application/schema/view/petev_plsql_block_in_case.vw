CREATE OR REPLACE FORCE view petev_plsql_block_in_case AS
SELECT bic.id,
       bic.test_case_id,
       bic.plsql_block_id,
       pb.plsql_block,
       bic.input_argument_id,
       inarg.input_argument,
       bic.expected_result_id,
       er.expected_result,
       bic.position,
       bic.stop_on_failure,
       bic.run_modifier,
       bic.description,
       petet_plsql_block_in_case(bic.id,
                                 bic.test_case_id,
                                 bic.plsql_block_id,
                                 pb.plsql_block,
                                 bic.input_argument_id,
                                 inarg.input_argument,
                                 bic.expected_result_id,
                                 er.expected_result,
                                 bic.position,
                                 bic.stop_on_failure,
                                 bic.run_modifier,
                                 bic.description) AS plsql_block_in_case
  FROM pete_plsql_block_in_case bic
  JOIN petev_plsql_block pb ON (pb.id = bic.plsql_block_id)
  LEFT OUTER JOIN petev_input_argument inarg ON (inarg.id =
                                                bic.input_argument_id)
  LEFT OUTER JOIN petev_expected_result er ON (er.id = bic.expected_result_id)
;
