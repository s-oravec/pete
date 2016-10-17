CREATE OR REPLACE FORCE view petev_expected_result AS
SELECT id,
       NAME,
       VALUE,
       description,
       petet_expected_result(id, NAME, VALUE, description) AS expected_result
  FROM pete_expected_result
;
