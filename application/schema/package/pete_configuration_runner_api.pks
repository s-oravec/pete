CREATE OR REPLACE PACKAGE pete_configuration_runner_api IS

    --
    -- Creates Pete Configaration Runner PLSQL Block
    --
    -- %argument a_plsql_block_in PLSQL block object
    --   - if a_plsql_block.id is not set, then new block is created and a_plsql_block.id contains new id
    --   - else PLSQL block definition is updated
    --
    procedure set_plsql_block(
        a_obj_plsql_block_in in out nocopy petet_plsql_block
    );

    --
    -- Gets Pete Configuration Runner PLSQL Block
    -- %argument a_id_in
    --
    function get_plsql_block(
        a_id_in in pete_plsql_block.id%type
    ) return petet_plsql_block;




end pete_configuration_runner_api;
/
