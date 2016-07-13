insert into pete_plsql_block (id, name, anonymous_block) values (1, 'b1', 'declare l_xml_in xmltype := :1; begin :2 := l_xml_in; end;');
commit;

-- simple
-- s0
--  +- b1
insert into pete_test_case (id, name) values (1, 's0');
insert into pete_plsql_block_in_case  (id, test_case_id, plsql_block_id, position) values (1, 1, 1, 1);
commit;

-- path
-- s1
-- +- c1
--    +- c2
--       +- b1

insert into pete_test_case (id, name) values (2, 's1');
insert into pete_test_case (id, name) values (3, 'c1');
insert into pete_test_case (id, name) values (4, 'c2');
insert into pete_test_case_in_case (id, parent_test_case_id, test_case_id, position) values (1, 2, 3, 1);
insert into pete_test_case_in_case (id, parent_test_case_id, test_case_id, position) values (2, 3, 4, 1);
insert into pete_plsql_block_in_case (id, test_case_id, plsql_block_id, position) values (4, 4, 1, 1);
commit;

-- tree simple tree
-- s2
-- +- c3
--    +- b1
-- +- c4
--    +- b1

insert into pete_test_case (id, name) values (5, 's2');
insert into pete_test_case (id, name) values (6, 'c3');
insert into pete_test_case (id, name) values (7, 'c4');
insert into pete_test_case_in_case (id, parent_test_case_id, test_case_id, position) values (3, 5, 6, 1);
insert into pete_test_case_in_case (id, parent_test_case_id, test_case_id, position) values (4, 5, 7, 2);
insert into pete_plsql_block_in_case (id, test_case_id, plsql_block_id, position) values (5, 6, 1, 1);
insert into pete_plsql_block_in_case (id, test_case_id, plsql_block_id, position) values (6, 7, 1, 1);
commit;

-- tree dag
-- s3
-- +- c5
--    +- c6
--       +- b1
-- +- c6

insert into pete_test_case (id, name) values (8, 's3');
insert into pete_test_case (id, name) values (9, 'c5');
insert into pete_test_case (id, name) values (10, 'c6');
insert into pete_test_case_in_case (id, parent_test_case_id, test_case_id, position) values (5, 8, 9, 1);
insert into pete_test_case_in_case (id, parent_test_case_id, test_case_id, position) values (6, 8, 10, 2);
insert into pete_test_case_in_case (id, parent_test_case_id, test_case_id, position) values (7, 9, 10, 1);
insert into pete_plsql_block_in_case (id, test_case_id, plsql_block_id, position) values (7, 10, 1, 1);
commit;

delete from pete_plsql_block_in_case;
delete from pete_test_case_in_case;
delete from pete_test_case;
delete from pete_plsql_block;

alter table pete_test_case_in_case modify parent_test_case_id null;
alter table pete_test_case_in_case modify position null;

insert into pete_test_case_in_case (id, parent_test_case_id, test_case_id, position) values (-1, null, 1, null);
insert into pete_test_case_in_case (id, parent_test_case_id, test_case_id, position) values (-2, null, 2, null);
insert into pete_test_case_in_case (id, parent_test_case_id, test_case_id, position) values (-3, null, 5, null);
insert into pete_test_case_in_case (id, parent_test_case_id, test_case_id, position) values (-4, null, 8, null);

select sys_connect_by_path(tc.name, '/'), level, cic.*
  from pete_test_case_in_case cic
  join pete_test_case tc on (tc.id = cic.test_case_id)
 start with cic.parent_test_case_id is null
connect by cic.parent_test_case_id = prior cic.test_case_id 
;
