create or replace function utf_varchar2_delimited_concat(value in varchar2) return varchar2
  aggregate using utt_varchar2_delimited_concat;
/
