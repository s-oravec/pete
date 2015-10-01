CREATE OR REPLACE FORCE view petev_plsql_block AS
SELECT id,
       NAME,
       description,
       owner,
       PACKAGE,
       method,
       anonymous_block,
       petet_plsql_block(id,
                         NAME,
                         description,
                         owner,
                         PACKAGE,
                         method,
                         anonymous_block) AS plsql_block
  FROM pete_plsql_block
;
