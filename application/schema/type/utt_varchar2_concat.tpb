create or replace type body utt_varchar2_concat is

  static function ODCIAggregateInitialize(ctx in out utt_varchar2_concat) return number is
  begin
    ctx := utt_varchar2_concat(null);
    return ODCIConst.Success;
  end;

  member function ODCIAggregateIterate
  (
    self  in out utt_varchar2_concat,
    value in varchar2
  ) return number is
  begin
    if self.text is null
    then
      self.text := value;
    else
      self.text := self.text || value;
    end if;
    return ODCIConst.Success;
  end;

  member function ODCIAggregateTerminate
  (
    self        in utt_varchar2_concat,
    returnValue out varchar2,
    flags       in number
  ) return number is
  begin
    returnValue := self.text;
    return ODCIConst.Success;
  end;

  member function ODCIAggregateMerge
  (
    self in out utt_varchar2_concat,
    ctx2 in utt_varchar2_concat
  ) return number is
  begin
    if ctx2.text is null
    then
      null;
    else
      self.text := self.text || ',' || ctx2.text;
    end if;
    return ODCIConst.Success;
  end;

end;
/
