@&&run_dir_begin

@&&run_dir table
@&&run_dir sequence
@&&run_dir type
@&&run_dir function
@&&run_dir view
@&&run_dir package

prompt Compiling invalid objects
begin
  dbms_utility.compile_schema(schema => user, compile_all => false);
end;
/

@&&run_dir grant

@&&run_dir_end
