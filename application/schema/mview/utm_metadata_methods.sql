create materialized view utm_metadata_methods as
select case
         when object_type in ('PROCEDURE', 'FUNCTION') then
          'USERPROCS'
         else
          object_name
       end as package_name,
       case
         when object_type in ('PROCEDURE', 'FUNCTION') then
          object_name
         else
          procedure_name
       end as method_name,
       subprogram_id,
       overload,
       object_type as package_type,
       nvl2((select 1
              from utm_metadata_function_result a
             where ((a.package_name = p.object_name and a.object_name = p.procedure_name and
                   a.SUBPROGRAM_ID = p.SUBPROGRAM_ID) or
                   (a.package_name is null and p.object_name is null and
                   a.object_name = p.procedure_name and a.SUBPROGRAM_ID = p.SUBPROGRAM_ID))),
            'FUNCTION',
            case
              when object_type in ('PROCEDURE', 'FUNCTION') then
               object_type
              else
               'PROCEDURE'
            end) as method_type
  from user_procedures p
 where not (procedure_name is null and object_type = 'PACKAGE') -- package spec
   and not exists (select *
          from utm_metadata_mtds_wth_rec_arg m
         where case
                 when p.object_type in ('PROCEDURE', 'FUNCTION') then
                  'USERPROCS'
                 else
                  p.object_name
               end = m.package_name
           and case
                 when p.object_type in ('PROCEDURE', 'FUNCTION') then
                  p.object_name
                 else
                  p.procedure_name
               end = m.method_name
           and p.subprogram_id = m.subprogram_id)
;

create unique index utm_metadata_methods_pk on
  utm_metadata_methods(package_name, method_name, subprogram_id)
;
