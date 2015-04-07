create materialized view utm_metadata_arguments as
select case
         when argument_name is null
              and data_type is null then
          'P_DUMMY'
         else
          nvl(argument_name, 'RESULT')
       end type_attr_name,
       'l_' || substr(case
                       when argument_name is null
                            and data_type is null then
                        'P_DUMMY'
                       else
                        nvl(argument_name, 'RESULT')
                     end,
                     1,
                     28) as local_helper_name,
       case
         when data_type is null
              or data_type = 'BINARY_INTEGER' then
          'INTEGER'
         when data_type = 'ROWID' then
          'VARCHAR2' -- rowidtochar/chartorowid
         when data_type = 'RAW' then
          'VARCHAR2' -- rawtohex/hextoraw
         when data_type = 'VARCHAR2' then
          'VARCHAR2'
         when data_type = 'REF CURSOR' then
          'XMLTYPE'
         when data_type = 'OPAQUE/XMLTYPE' then
          'XMLTYPE'
         when data_type in ('OBJECT', 'TABLE') then
          type_name
         else
          data_type
       end type_attr_type,
       case
         when data_type = 'ROWID' then
          64 -- rowidtochar/chartorowid
         when data_type = 'RAW' then
          4000 -- rawtohex/hextoraw
         when data_type in 'VARCHAR2' then
          4000
         else
          null
       end type_attr_length,
       object_name as method_name,
       nvl(package_name, 'USERPROCS') as package_name,
       object_id,
       overload,
       subprogram_id,
       argument_name,
       position,
       sequence,
       data_level,
       data_type,
       defaulted,
       --long default_value,
       default_length,
       in_out,
       data_length,
       data_precision,
       data_scale,
       radix,
       character_set_name,
       type_owner,
       type_name,
       type_subname,
       type_link,
       pls_type,
       char_length,
       char_used
       --12c ,origin_con_id
  from user_arguments a
;

create index utm_metadata_arguments_in01 on
utm_metadata_arguments(package_name, method_name, subprogram_id)
;
