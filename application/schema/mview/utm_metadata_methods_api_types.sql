create materialized view utm_metadata_methods_api_types as
with temp as
 (select substr(package_name, 1, 10) ||
         lpad(dense_rank() over(partition by substr(package_name, 1, 10) order by package_name),
              3,
              0) as package_name_part,
         'UXP_' || substr(package_name, 1, 23) ||
         lpad(dense_rank() over(partition by substr(package_name, 1, 23) order by package_name),
              3,
              0) as ux_package_name,
         substr(method_name, 1, 10) ||
         lpad(dense_rank() over(partition by package_name,
                   substr(method_name, 1, 10) order by method_name,
                   overload),
              3,
              0) as method_name_part,
         method_name,
         case
           when overload is not null then
            substr(method_name, 1, 30 - 1 - length(to_char(overload))) || '_' || overload
           else
            method_name
         end as ux_method_name,
         package_name,
         subprogram_id,
         overload,
         package_type,
         method_type
    from utm_metadata_methods)
select package_name,
       package_name_part,
       ux_package_name,
       method_name,
       method_name_part,
       ux_method_name,
       'UXI_' || package_name_part || method_name_part as input_type_name,
       'UXO_' || package_name_part || method_name_part as output_type_name,
       subprogram_id,
       overload,
       package_type,
       method_type
  from temp
;


create index utm_metadata_mtds_api_typ_in01
on utm_metadata_methods_api_types(package_name, method_name, subprogram_id)
;
