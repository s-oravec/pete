CREATE OR REPLACE PACKAGE pete_configuration_runner_adm IS

    --
    -- Sets PLSQL Block
    --   - if a_plsql_block.id is not set, then new block is created and a_plsql_block.id 
    --     contains new id (from petes_plsql_block sequence)
    --   - else PLSQL block definition is updated
    --
    -- %argument a_plsql_block_in PLSQL block object
    --
    -- %throws ge_record_not_found thrown when record being updated is not found
    --
    PROCEDURE set_plsql_block(a_plsql_block_io IN OUT NOCOPY petet_plsql_block);

    --
    -- Deletes PLSQL Block
    --
    -- %argumet a_id_in PLSQL Block identifier
    --
    -- %throws ge_record_not_found thrown when record being deleted is not found
    --
    PROCEDURE del_plsql_block(a_id_in IN pete_plsql_block.id%TYPE);

    --
    -- Gets PLSQL Block
    --
    -- %argument a_id_in PLSQL Block identifier
    --
    FUNCTION get_plsql_block(a_id_in IN pete_plsql_block.id%TYPE)
        RETURN petet_plsql_block;

    --
    -- Sets Input Argument
    --
    --   - if a_input_argument_in.id is not set, then new input argument is created and a_input_argument_in.id
    --     contains new id (from petes_input_argument sequence)
    --   - else input argument definition is updated
    --
    -- %throws ge_record_not_found thrown when record being updated is not found
    --
    -- %argument a_input_argument_in Input Argument
    --
    PROCEDURE set_input_argument(a_input_argument_io IN OUT NOCOPY petet_input_argument);

    --
    -- Deletes Input Argument
    --
    -- %argument a_id_in Input Argument identifier
    --
    -- %throws ge_record_not_found thrown when record being deleted is not found
    --
    PROCEDURE del_input_argument(a_id_in IN pete_input_argument.id%TYPE);

    --
    -- Gets Input Argument
    --
    -- %argument  Input Argument identifier
    FUNCTION get_input_argument(a_id_in IN pete_input_argument.id%TYPE)
        RETURN petet_input_argument;

    --
    -- Sets Expected Result
    --
    --   - if a_expected_result_io.id is not set, then new expected result is created and a_expected_result_io.id
    --     contains new id (from petes_expected_result sequence)
    --   - else expected result definition is updated
    --
    -- %argument a_expected_result_io Expected Result
    --
    -- %throws ge_record_not_found thrown when record being updated is not found
    --
    PROCEDURE set_expected_result(a_expected_result_io IN OUT NOCOPY petet_expected_result);

    --
    -- Deletes Expected Result
    --
    -- %arguemnt a_id_in Expected Result identifier
    --
    -- %throws ge_record_not_found thrown when record being deleted is not found
    --
    PROCEDURE del_expected_result(a_id_in IN pete_expected_result.id%TYPE);

    --
    -- Gets Expected Result
    --
    -- %arguemnt a_id_in Expected Result identifier
    --
    FUNCTION get_expected_result(a_id_in IN pete_expected_result.id%TYPE)
        RETURN petet_expected_result;

    --
    -- Sets PLSQL Block in Test Case relation
    --   - if a_plsql_block_in_case_io.id is not set, then new block in case is created and a_plsql_block_in_case_io.id
    --     contains new id (from petes_plsql_block_in_case sequence)
    --   - else PLSQL block in case definition is updated
    --
    -- %argument a_plsql_block_in_case_io block in case relation object
    --
    -- %throws ge_record_not_found thrown when record being updated is not found
    --
    PROCEDURE set_plsql_block_in_case(a_plsql_block_in_case_io IN OUT NOCOPY petet_plsql_block_in_case);

    FUNCTION get_plsql_block_in_case
    (
        a_id_in                 IN pete_plsql_block_in_case.id%TYPE,
        a_cascade_subobjects_in IN pete_core.typ_YES_NO DEFAULT pete_core.g_NO
    ) RETURN petet_plsql_block_in_case;

    --
    -- Delete PLSQL Block from Test Case
    --
    -- %argument a_id_in PLSLQ Block in Test Case id
    --
    -- %throws ge_record_not_found thrown when record being deleted is not found
    --
    PROCEDURE del_plsql_block_in_case(a_id_in IN pete_plsql_block_in_case.id%TYPE);

    --
    -- Change order of PLSQL Block in Test Case by either offset or to absolute position
    -- position/order is counted from 1 = position of first block
    --
    -- %argument a_id_in
    -- %argument a_position_target_in
    -- %argument a_position_offset_in
    -- -- a_position_target_in xor a_position_offset_in is not null
    --
    PROCEDURE move_plsql_block_in_case
    (
        a_id_in                 IN pete_plsql_block_in_case.id%TYPE,
        a_test_case_id_in       IN pete_plsql_block_in_case.test_case_id%TYPE,
        a_position_target_in IN pete_plsql_block_in_case.position%TYPE DEFAULT NULL,
        a_position_offset_in IN pete_plsql_block_in_case.position%TYPE DEFAULT NULL
    );

    --
    -- Sets Test Case
    --   - if a_test_case_io.id is not set, then new test case is created and a_test_case_io.id
    --     contains new id (from petes_test_case sequence)
    --   - else Test Case definition is updated
    --
    -- %argument a_test_case_io Test Case object
    --
    -- %throws ge_record_not_found thrown when record being updated is not found
    --
    PROCEDURE set_test_case(a_test_case_io IN OUT NOCOPY petet_test_case);

    --
    -- Deletes Test Case - cascading deletes Blocks in Case
    --
    -- %argumet a_id_in Test Case identifier
    --
    -- %throws ge_record_not_found thrown when record being deleted is not found
    --
    PROCEDURE del_test_case(a_id_in IN pete_test_case.id%TYPE);

    --
    -- Gets Test Case
    --
    -- %argument a_id_in Test Case identifier
    --
    FUNCTION get_test_case
    (
        a_id_in                 IN pete_test_case.id%TYPE,
        a_cascade_subobjects_in IN pete_core.typ_YES_NO DEFAULT pete_core.g_NO
    ) RETURN petet_test_case;
    
    --
    -- Sets Test Suite
    --   - if a_test_suite_io.id is not set, then new test suite is created and a_test_suite_io.id
    --     contains new id (from petes_test_suite sequence)
    --   - else Test Suite definition is updated
    --
    -- %argument a_test_suite_io Test Suite object
    --
    -- %throws ge_record_not_found thrown when record being updated is not found
    --
    PROCEDURE set_test_suite(a_test_suite_io IN OUT NOCOPY petet_test_suite);

    --
    -- Deletes Test Suite - cascading deletes Blocks in Suite
    --
    -- %argumet a_id_in Test Suite identifier
    --
    -- %throws ge_record_not_found thrown when record being deleted is not found
    --
    PROCEDURE del_test_suite(a_id_in IN pete_test_suite.id%TYPE);

    --
    -- Gets Test Suite
    --
    -- %argument a_id_in Test Suite identifier
    --
    FUNCTION get_test_suite
    (
        a_id_in                 IN pete_test_suite.id%TYPE,
        a_cascade_subobjects_in IN pete_core.typ_YES_NO DEFAULT pete_core.g_NO
    ) RETURN petet_test_suite;
    

END pete_configuration_runner_adm;
/
