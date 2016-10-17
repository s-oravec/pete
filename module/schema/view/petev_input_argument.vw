CREATE OR REPLACE FORCE VIEW petev_input_argument AS
SELECT id,
       NAME,
       VALUE,
       description,
       petet_input_argument(id, NAME, VALUE, description) AS input_argument
  FROM pete_input_argument
;
