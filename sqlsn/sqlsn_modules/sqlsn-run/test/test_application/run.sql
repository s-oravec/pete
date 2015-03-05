@&&run_dir_begin

prompt
prompt * case [run should work on tree of directories]
@&&run_dir run_tree

prompt
prompt * case [scripts should run in ancestor directory]
@&&run_dir run_script_in_ancestor

prompt
prompt * case [scripts should run in sub directory]
@&&run_dir run_script_in_sub

prompt
prompt * case [scripts should run in sibling directory]
@&&run_dir run_script_in_sibling

@&&run_dir_end