CREATE OR REPLACE PACKAGE BODY pete_configuration_runner_api IS

    -------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE set_plsql_block(a_plsql_block_io IN OUT NOCOPY petet_plsql_block) IS
    BEGIN
        IF a_plsql_block_io.id IS NULL
        THEN
            --
            a_plsql_block_io.id := petes_plsql_block.nextval;
            --
            INSERT INTO pete_plsql_block
            VALUES
                (a_plsql_block_io.id,
                 a_plsql_block_io.name,
                 a_plsql_block_io.description,
                 a_plsql_block_io.owner,
                 a_plsql_block_io.package,
                 a_plsql_block_io.method,
                 a_plsql_block_io.anonymous_block);
            --
        ELSE
            -- TODO: try to dbms_sql.parse the anobnymous block
            -- TODO: dbms_assert  owner, package, name
            UPDATE pete_plsql_block
               SET NAME            = a_plsql_block_io.name,
                   description     = a_plsql_block_io.description,
                   owner           = a_plsql_block_io.owner,
                   PACKAGE         = a_plsql_block_io.package,
                   method          = a_plsql_block_io.method,
                   anonymous_block = a_plsql_block_io.anonymous_block
             WHERE id = a_plsql_block_io.id;
            --
            IF SQL%ROWCOUNT = 0
            THEN
                raise_application_error(gc_RECORD_NOT_FOUND,
                                        'Record not found. {"id":"' ||
                                        a_plsql_block_io.id || '"} ');
            END IF;
            --
        END IF;
    END;

    -------------------------------------------------------------------------------------------------------------------------------
    FUNCTION get_plsql_block(a_id_in IN pete_plsql_block.id%TYPE)
        RETURN petet_plsql_block IS
        l_result petet_plsql_block;
    BEGIN
        --
        SELECT petet_plsql_block(id,
                                 NAME,
                                 description,
                                 owner,
                                 PACKAGE,
                                 method,
                                 anonymous_block)
          INTO l_result
          FROM pete_plsql_block
         WHERE id = a_id_in;
        --
        RETURN l_result;
        --
    END;

    -------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE del_plsql_block(a_id_in IN pete_plsql_block.id%TYPE) IS
    BEGIN
        --
        DELETE FROM pete_plsql_block WHERE id = a_id_in;
        --
        IF SQL%ROWCOUNT = 0
        THEN
            raise_application_error(gc_RECORD_NOT_FOUND,
                                    'Record not found. {"id":"' || a_id_in ||
                                    '"} ');
        END IF;
        --
    END;

    -------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE set_input_argument(a_input_argument_io IN OUT NOCOPY petet_input_argument) IS
    BEGIN
        IF a_input_argument_io.id IS NULL
        THEN
            --
            a_input_argument_io.id := petes_input_argument.nextval;
            --
            INSERT INTO pete_input_argument
            VALUES
                (a_input_argument_io.id,
                 a_input_argument_io.name,
                 a_input_argument_io.value,
                 a_input_argument_io.description);
            --
        ELSE
            UPDATE pete_input_argument
               SET NAME        = a_input_argument_io.name,
                   VALUE       = a_input_argument_io.value,
                   description = a_input_argument_io.description
             WHERE id = a_input_argument_io.id;
            --
            IF SQL%ROWCOUNT = 0
            THEN
                raise_application_error(gc_RECORD_NOT_FOUND,
                                        'Record not found. {"id":"' ||
                                        a_input_argument_io.id || '"} ');
            END IF;
            --
        END IF;
    END;

    -------------------------------------------------------------------------------------------------------------------------------
    FUNCTION get_input_argument(a_id_in IN pete_input_argument.id%TYPE)
        RETURN petet_input_argument IS
        l_result petet_input_argument;
    BEGIN
        --
        SELECT petet_input_argument(id, NAME, VALUE, description)
          INTO l_result
          FROM pete_input_argument
         WHERE id = a_id_in;
        --
        RETURN l_result;
    END;

    -------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE del_input_argument(a_id_in IN pete_input_argument.id%TYPE) IS
    BEGIN
        --
        DELETE FROM pete_input_argument WHERE id = a_id_in;
        --
        IF SQL%ROWCOUNT = 0
        THEN
            raise_application_error(gc_RECORD_NOT_FOUND,
                                    'Record not found. {"id":"' || a_id_in ||
                                    '"} ');
        END IF;
        --
    END;

    -------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE set_expected_result(a_expected_result_io IN OUT petet_expected_result) IS
    BEGIN
        IF a_expected_result_io.id IS NULL
        THEN
            --
            a_expected_result_io.id := petes_expected_result.nextval;
            --
            INSERT INTO pete_expected_result
                (id, NAME, VALUE, description)
            VALUES
                (a_expected_result_io.id,
                 a_expected_result_io.name,
                 a_expected_result_io.value,
                 a_expected_result_io.description);
            --
        ELSE
            UPDATE pete_expected_result
               SET NAME        = a_expected_result_io.name,
                   VALUE       = a_expected_result_io.value,
                   description = a_expected_result_io.description
             WHERE id = a_expected_result_io.id;
            --
            IF SQL%ROWCOUNT = 0
            THEN
                raise_application_error(gc_RECORD_NOT_FOUND,
                                        'Record not found. {"id":"' ||
                                        a_expected_result_io.id || '"} ');
            END IF;
            --
        END IF;
    END;

    -------------------------------------------------------------------------------------------------------------------------------
    FUNCTION get_expected_result(a_id_in IN pete_expected_result.id%TYPE)
        RETURN petet_expected_result IS
        l_result petet_expected_result;
    BEGIN
        --
        SELECT petet_expected_result(id, NAME, VALUE, description)
          INTO l_result
          FROM pete_expected_result
         WHERE id = a_id_in;
        --
        RETURN l_result;
    END;

    -------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE del_expected_result(a_id_in IN pete_expected_result.id%TYPE) IS
    BEGIN
        --
        DELETE FROM pete_expected_result WHERE id = a_id_in;
        --
        IF SQL%ROWCOUNT = 0
        THEN
            raise_application_error(gc_RECORD_NOT_FOUND,
                                    'Record not found. {"id":"' || a_id_in ||
                                    '"} ');
        END IF;
        --
    END;

    -------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE sort_blocks_impl(a_test_case_id_in IN pete_plsql_block_in_case.test_case_id%TYPE) IS
    BEGIN
        --
        MERGE INTO pete_plsql_block_in_case t
        USING (SELECT id, ROWNUM AS new_position
                 FROM pete_plsql_block_in_case
                WHERE test_case_id = a_test_case_id_in
                ORDER BY position) s
        ON (t.id = s.id)
        WHEN MATCHED THEN
            UPDATE SET t.position = s.new_position;
        --
    END;

    -------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE set_plsql_block_in_case(a_plsql_block_in_case_io IN OUT NOCOPY petet_plsql_block_in_case) IS
    BEGIN
        --
        --if sub-objects are defined
        --plsql_block
        IF a_plsql_block_in_case_io.plsql_block IS NOT NULL
        THEN
            --
            --save object
            set_plsql_block(a_plsql_block_io => a_plsql_block_in_case_io.plsql_block);
            --
            --update id
            a_plsql_block_in_case_io.plsql_block_id := a_plsql_block_in_case_io.plsql_block.id;
        END IF;
        --
        --input_argument
        IF a_plsql_block_in_case_io.input_argument IS NOT NULL
        THEN
            --
            --save object
            set_input_argument(a_input_argument_io => a_plsql_block_in_case_io.input_argument);
            --
            --update id
            a_plsql_block_in_case_io.input_argument_id := a_plsql_block_in_case_io.input_argument.id;
        END IF;
        --
        --expected_result
        IF a_plsql_block_in_case_io.expected_result IS NOT NULL
        THEN
            --
            --save object
            set_expected_result(a_expected_result_io => a_plsql_block_in_case_io.expected_result);
            --
            --update id
            a_plsql_block_in_case_io.expected_result_id := a_plsql_block_in_case_io.expected_result.id;
        END IF;
        --
        --set object
        IF a_plsql_block_in_case_io.id IS NULL
        THEN
            --
            a_plsql_block_in_case_io.id := petes_plsql_block_in_case.nextval;
            --
            INSERT INTO pete_plsql_block_in_case
            VALUES
                (a_plsql_block_in_case_io.id,
                 a_plsql_block_in_case_io.test_case_id,
                 a_plsql_block_in_case_io.plsql_block_id,
                 a_plsql_block_in_case_io.input_argument_id,
                 a_plsql_block_in_case_io.expected_result_id,
                 a_plsql_block_in_case_io.position,
                 a_plsql_block_in_case_io.stop_on_failure,
                 a_plsql_block_in_case_io.run_modifier,
                 a_plsql_block_in_case_io.description);
            --                
        ELSE
            UPDATE pete_plsql_block_in_case
               SET id                 = a_plsql_block_in_case_io.id,
                   test_case_id       = a_plsql_block_in_case_io.test_case_id,
                   plsql_block_id     = a_plsql_block_in_case_io.plsql_block_id,
                   input_argument_id  = a_plsql_block_in_case_io.input_argument_id,
                   expected_result_id = a_plsql_block_in_case_io.expected_result_id,
                   position           = a_plsql_block_in_case_io.position,
                   stop_on_failure    = a_plsql_block_in_case_io.stop_on_failure,
                   run_modifier       = a_plsql_block_in_case_io.run_modifier,
                   description        = a_plsql_block_in_case_io.description
             WHERE id = a_plsql_block_in_case_io.id;
            --
            IF SQL%ROWCOUNT = 0
            THEN
                raise_application_error(gc_RECORD_NOT_FOUND,
                                        'Record not found. {"id":"' ||
                                        a_plsql_block_in_case_io.id || '"} ');
            END IF;
            --
        END IF;
        --
        sort_blocks_impl(a_test_case_id_in => a_plsql_block_in_case_io.test_case_id);
        --
    END;

    --------------------------------------------------------------------------------
    FUNCTION get_plsql_block_in_case
    (
        a_id_in                 IN pete_plsql_block_in_case.id%TYPE,
        a_cascade_subobjects_in IN pete_core.typ_YES_NO DEFAULT pete_core.g_NO
    ) RETURN petet_plsql_block_in_case IS
        l_result petet_plsql_block_in_case;
    BEGIN
        --
        IF a_cascade_subobjects_in = pete_core.g_NO
        THEN
            SELECT petet_plsql_block_in_case(id                 => bic.id,
                                             test_case_id       => bic.test_case_id,
                                             plsql_block_id     => bic.plsql_block_id,
                                             input_argument_id  => bic.input_argument_id,
                                             expected_result_id => bic.expected_result_id,
                                             position           => bic.position,
                                             stop_on_failure    => bic.stop_on_failure,
                                             run_modifier       => bic.run_modifier,
                                             description        => bic.description)
              INTO l_result
              FROM pete_plsql_block_in_case bic
             WHERE bic.id = a_id_in;
        ELSE
            SELECT petet_plsql_block_in_case(id                 => bic.id,
                                             test_case_id       => bic.test_case_id,
                                             plsql_block_id     => pb.id,
                                             plsql_block        => CASE
                                                                       WHEN pb.id IS NOT NULL THEN
                                                                        petet_plsql_block(id              => pb.id,
                                                                                          NAME            => pb.name,
                                                                                          description     => pb.description,
                                                                                          owner           => pb.owner,
                                                                                          PACKAGE         => pb.package,
                                                                                          method          => pb.method,
                                                                                          anonymous_block => pb.anonymous_block)
                                                                   END,
                                             input_argument_id  => inarg.id,
                                             input_argument     => CASE
                                                                       WHEN inarg.id IS NOT NULL THEN
                                                                        petet_input_argument(id          => inarg.id,
                                                                                             NAME        => inarg.name,
                                                                                             VALUE       => inarg.value,
                                                                                             description => inarg.description)
                                                                   END,
                                             expected_result_id => er.id,
                                             expected_result    => CASE
                                                                       WHEN er.id IS NOT NULL THEN
                                                                        petet_expected_result(id          => er.id,
                                                                                              NAME        => er.name,
                                                                                              VALUE       => er.value,
                                                                                              description => er.description)
                                                                   END,
                                             position           => bic.position,
                                             stop_on_failure    => bic.stop_on_failure,
                                             run_modifier       => bic.run_modifier,
                                             description        => bic.description)
              INTO l_result
              FROM pete_plsql_block_in_case bic
              JOIN pete_plsql_block pb ON (pb.id = bic.plsql_block_id)
              LEFT OUTER JOIN pete_input_argument inarg ON (inarg.id =
                                                           bic.input_argument_id)
              LEFT OUTER JOIN pete_expected_result er ON (er.id =
                                                         bic.expected_result_id)
             WHERE bic.id = a_id_in;
        END IF;
        --
        RETURN l_result;
        --
    END;

    -------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE del_plsql_block_in_case(a_id_in IN pete_plsql_block_in_case.id%TYPE) IS
    BEGIN
        --
        DELETE FROM pete_plsql_block WHERE id = a_id_in;
        --
        IF SQL%ROWCOUNT = 0
        THEN
            raise_application_error(gc_RECORD_NOT_FOUND,
                                    'Record not found. {"id":"' || a_id_in ||
                                    '"} ');
        END IF;
        --
        sort_blocks_impl(a_test_case_id_in => a_id_in);
        --
    END;

    -------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE move_plsql_block_in_case
    (
        a_id_in              IN pete_plsql_block_in_case.id%TYPE,
        a_test_case_id_in    IN pete_plsql_block_in_case.test_case_id%TYPE,
        a_position_target_in IN pete_plsql_block_in_case.position%TYPE DEFAULT NULL,
        a_position_offset_in IN pete_plsql_block_in_case.position%TYPE DEFAULT NULL
    ) IS
        l_test_cast_id pete_plsql_block_in_case.test_case_id%TYPE;
    BEGIN
        --
        -- check input arguments xor
        IF (a_position_target_in IS NULL AND a_position_offset_in IS NULL)
           OR (a_position_target_in IS NOT NULL AND
           a_position_offset_in IS NOT NULL)
        THEN
            raise_application_error(-20001,
                                    'Either Block Order Target or Block Order Offset hes to be set');
        END IF;
        --
        -- change order of that specific block
        UPDATE pete_plsql_block_in_case
           SET position = --
                CASE
                    WHEN a_position_target_in IS NOT NULL THEN
                     CASE a_position_target_in
                         WHEN pete_core.g_ORDER_FIRST THEN
                          0.5
                         WHEN pete_core.g_ORDER_LAST THEN
                          (SELECT MAX(position) + 0.5
                             FROM pete_plsql_block_in_case
                            WHERE test_case_id = a_test_case_id_in)
                         ELSE
                          a_position_target_in - 0.5
                     END
                    WHEN a_position_offset_in IS NOT NULL THEN
                     position + a_position_offset_in +
                     (sign(a_position_offset_in) * 0.5)
                END
         WHERE id = a_id_in
        RETURNING test_case_id INTO l_test_cast_id;
        --
        -- sort blocks in case
        sort_blocks_impl(a_test_case_id_in => l_test_cast_id);
        --
    END;

    -------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE set_test_case(a_test_case_io IN OUT petet_test_case) IS
    BEGIN
        --
        IF a_test_case_io.id IS NULL
        THEN
            --
            a_test_case_io.id := petes_plsql_block_in_case.nextval;
            --
            INSERT INTO pete_test_case
            VALUES
                (a_test_case_io.id,
                 a_test_case_io.name,
                 a_test_case_io.description);
            --
        ELSE
            UPDATE pete_test_case
               SET id          = a_test_case_io.id,
                   NAME        = a_test_case_io.name,
                   description = a_test_case_io.description
             WHERE id = a_test_case_io.id;
            --
            IF SQL%ROWCOUNT = 0
            THEN
                raise_application_error(gc_RECORD_NOT_FOUND,
                                        'Record not found. {"id":"' ||
                                        a_test_case_io.id || '"} ');
            END IF;
            --
        END IF;
        --
        --if PLSQL Blocks in Test Case object are defined
        IF a_test_case_io.plsql_blocks_in_case IS NOT NULL
           AND a_test_case_io.plsql_blocks_in_case.count > 0
        THEN
            --
            -- delete old
            DELETE FROM pete_plsql_block_in_case
             WHERE test_case_id = a_test_case_io.id;
            --
            --set new
            FOR position IN a_test_case_io.plsql_blocks_in_case.first .. a_test_case_io.plsql_blocks_in_case.last
            LOOP
                --
                --set order and Test Case id
                a_test_case_io.plsql_blocks_in_case(position).position := position;
                a_test_case_io.plsql_blocks_in_case(position).test_case_id := a_test_case_io.id;
                --
                --set
                set_plsql_block_in_case(a_plsql_block_in_case_io => a_test_case_io.plsql_blocks_in_case(position));
            END LOOP;
        END IF;
        --
    END;

    -------------------------------------------------------------------------------------------------------------------------------
    FUNCTION get_test_case
    (
        a_id_in                 IN pete_test_case.id%TYPE,
        a_cascade_subobjects_in IN pete_core.typ_YES_NO DEFAULT pete_core.g_NO
    ) RETURN petet_test_case IS
        l_result petet_test_case;
    BEGIN
        --
        IF a_cascade_subobjects_in = pete_core.g_NO
        THEN
            SELECT petet_test_case(id, NAME, description)
              INTO l_result
              FROM pete_test_case
             WHERE id = a_id_in;
        ELSE
            -- NoFormat Start
            SELECT petet_test_case(
                       id                   => tc.id,
                       NAME                 => tc.NAME,
                       description          => tc.description,
                       plsql_blocks_in_case => (SELECT CAST(COLLECT(
                           petet_plsql_block_in_case(
                               id                 => bic.id,
                               test_case_id       => bic.test_case_id,
                               plsql_block_id     => pb.id,
                               plsql_block        => CASE WHEN pb.id IS NOT NULL THEN
                                                          petet_plsql_block(id              => pb.id,
                                                                            NAME            => pb.name,
                                                                            description     => pb.description,
                                                                            owner           => pb.owner,
                                                                            PACKAGE         => pb.package,
                                                                            method          => pb.method,
                                                                            anonymous_block => pb.anonymous_block)
                                                     END,
                               input_argument_id  => inarg.id,
                               input_argument     => CASE WHEN inarg.id IS NOT NULL THEN
                                                          petet_input_argument(id          => inarg.id,
                                                                               NAME        => inarg.name,
                                                                               VALUE       => inarg.value,
                                                                               description => inarg.description)
                                                     END,
                               expected_result_id => er.id,
                               expected_result    => CASE WHEN er.id IS NOT NULL THEN
                                                          petet_expected_result(id          => er.id,
                                                                                NAME        => er.name,
                                                                                VALUE       => er.value,
                                                                                description => er.description)
                                                     END,
                               position        => bic.position,
                               stop_on_failure    => bic.stop_on_failure,
                               run_modifier       => bic.run_modifier,
                               description        => bic.description)) AS
                         petet_plsql_blocks_in_case)
                                                 FROM pete_plsql_block_in_case bic
                                                 JOIN pete_plsql_block pb ON (pb.id =
                                                                             bic.plsql_block_id)
                                                 LEFT OUTER JOIN pete_input_argument inarg ON (inarg.id =
                                                                                              bic.input_argument_id)
                                                 LEFT OUTER JOIN pete_expected_result er ON (er.id =
                                                                                            bic.expected_result_id)
                                                WHERE bic.test_case_id = a_id_in))
              INTO l_result
              FROM pete_test_case tc
             WHERE tc.id = a_id_in;
             -- NoFormat End
        END IF;
        --
        RETURN l_result;
        --
    END;

    -------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE del_test_case(a_id_in IN pete_test_case.id%TYPE) IS
    BEGIN
        --
        -- delete PLSQL Blocks in Test Case
        DELETE FROM pete_plsql_block_in_case WHERE test_case_id = a_id_in;
        --
        -- delete Test Case
        DELETE FROM pete_test_case WHERE id = a_id_in;
        --
        IF SQL%ROWCOUNT = 0
        THEN
            raise_application_error(gc_RECORD_NOT_FOUND,
                                    'Record not found. {"id":"' || a_id_in ||
                                    '"} ');
        END IF;
        --
    END;

    -------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE sort_cases_impl(a_test_suite_id_in IN pete_test_case_in_suite.test_case_id%TYPE) IS
    BEGIN
        --
        MERGE INTO pete_test_case_in_suite t
        USING (SELECT id, ROWNUM AS new_position
                 FROM pete_test_case_in_suite
                WHERE test_suite_id = a_test_suite_id_in
                ORDER BY position) s
        ON (t.id = s.id)
        WHEN MATCHED THEN
            UPDATE SET t.position = s.new_position;
        --
    END;

    -------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE move_test_case_in_suite
    (
        a_id_in              IN pete_test_case_in_suite.id%TYPE,
        a_test_suite_id_in   IN pete_test_case_in_suite.test_case_id%TYPE,
        a_position_target_in IN pete_test_case_in_suite.position%TYPE DEFAULT NULL,
        a_position_offset_in IN pete_test_case_in_suite.position%TYPE DEFAULT NULL
    ) IS
        l_test_suite_id pete_test_case_in_suite.test_suite_id%TYPE;
    BEGIN
        --
        -- check input arguments xor
        IF (a_position_target_in IS NULL AND a_position_offset_in IS NULL)
           OR (a_position_target_in IS NOT NULL AND
           a_position_offset_in IS NOT NULL)
        THEN
            raise_application_error(-20001,
                                    'Either Test Case Order Target or Test Case Order Offset hes to be set');
        END IF;
        --
        -- change order of that specific case
        UPDATE pete_test_case_in_suite
           SET position = --
                CASE
                    WHEN a_position_target_in IS NOT NULL THEN
                     CASE a_position_target_in
                         WHEN pete_core.g_ORDER_FIRST THEN
                          0.5
                         WHEN pete_core.g_ORDER_LAST THEN
                          (SELECT MAX(position) + 0.5
                             FROM pete_test_case_in_suite
                            WHERE test_suite_id = a_test_suite_id_in)
                         ELSE
                          a_position_target_in - 0.5
                     END
                    WHEN a_position_offset_in IS NOT NULL THEN
                     position + a_position_offset_in +
                     (sign(a_position_offset_in) * 0.5)
                END
         WHERE id = a_id_in
        RETURNING test_suite_id INTO l_test_suite_id;
        --
        -- sort cases in suite
        sort_cases_impl(a_test_suite_id_in => l_test_suite_id);
        --
    END;

    --------------------------------------------------------------------------------  
    PROCEDURE set_test_case_in_suite(a_test_case_in_suite_io IN OUT petet_test_case_in_suite) IS
    BEGIN
        NULL;
    END;

    -------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE set_test_suite(a_test_suite_io IN OUT petet_test_suite) IS
    BEGIN
        --
        IF a_test_suite_io.id IS NULL
        THEN
            --
            a_test_suite_io.id := petes_test_suite.nextval;
            --
            INSERT INTO pete_test_suite
            VALUES
                (a_test_suite_io.id,
                 a_test_suite_io.name,
                 a_test_suite_io.stop_on_failure,
                 a_test_suite_io.run_modifier,
                 a_test_suite_io.description);
            --
        ELSE
            UPDATE pete_test_suite
               SET id              = a_test_suite_io.id,
                   NAME            = a_test_suite_io.name,
                   stop_on_failure = a_test_suite_io.stop_on_failure,
                   run_modifier    = a_test_suite_io.run_modifier,
                   description     = a_test_suite_io.description
             WHERE id = a_test_suite_io.id;
            --
            IF SQL%ROWCOUNT = 0
            THEN
                raise_application_error(gc_RECORD_NOT_FOUND,
                                        'Record not found. {"id":"' ||
                                        a_test_suite_io.id || '"} ');
            END IF;
            --
        END IF;
        --
        --if Test Cases in Test Suite object are defined
        IF a_test_suite_io.test_cases_in_suite IS NOT NULL
           AND a_test_suite_io.test_cases_in_suite.count > 0
        THEN
            --
            -- delete old
            DELETE FROM pete_test_case_in_suite
             WHERE test_suite_id = a_test_suite_io.id;
            --
            --set new
            FOR position IN a_test_suite_io.test_cases_in_suite.first .. a_test_suite_io.test_cases_in_suite.last
            LOOP
                --
                --set order and Test suite id
                a_test_suite_io.test_cases_in_suite(position).position := position;
                a_test_suite_io.test_cases_in_suite(position).test_suite_id := a_test_suite_io.id;
                --
                --set
                set_test_case_in_suite(a_test_case_in_suite_io => a_test_suite_io.test_cases_in_suite(position));
            END LOOP;
        END IF;
        --
    END;

    -------------------------------------------------------------------------------------------------------------------------------
    FUNCTION get_test_suite
    (
        a_id_in                 IN pete_test_suite.id%TYPE,
        a_cascade_subobjects_in IN pete_core.typ_YES_NO DEFAULT pete_core.g_NO
    ) RETURN petet_test_suite IS
        l_result petet_test_suite;
    BEGIN
        --
        IF a_cascade_subobjects_in = pete_core.g_NO
        THEN
            SELECT petet_test_suite(id,
                                    NAME,
                                    stop_on_failure,
                                    run_modifier,
                                    description)
              INTO l_result
              FROM pete_test_suite
             WHERE id = a_id_in;
        ELSE
            -- NoFormat Start
            NULL;
             -- NoFormat End
        END IF;
        --
        RETURN l_result;
        --
    END;

    -------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE del_test_suite(a_id_in IN pete_test_suite.id%TYPE) IS
    BEGIN
        --
        -- delete PLSQL Blocks in Test suite
        DELETE FROM pete_test_case_in_suite WHERE test_suite_id = a_id_in;
        --
        -- delete Test suite
        DELETE FROM pete_test_suite WHERE id = a_id_in;
        --
        IF SQL%ROWCOUNT = 0
        THEN
            raise_application_error(gc_RECORD_NOT_FOUND,
                                    'Record not found. {"id":"' || a_id_in ||
                                    '"} ');
        END IF;
        --
    END;

END pete_configuration_runner_api;
/
