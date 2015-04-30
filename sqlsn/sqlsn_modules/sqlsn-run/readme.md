# SQLSN - run

Module implements commands for running scripts stored in tree of directories.

# Usage

Module name is `sqlsn-run` so in "applications" written using SQLSN the substitution variables starting with `m_sqlsn_run` or `g_sqlsn_run` should not be used.

## Init

Initialize using

````
@&&sqlsn_require sqlsn-run
````

or

````
@&&sqls_require_from_path "<path>/sqlsn-run"
````

## Globals

Globals defined by stack module

### g_run_path

Current path in directory tree.

### g_run_action

Action performed - it allows you to create different scripts for different actions e.g. 

* `config` for configuration
* `install` for installation
* `uninstall` for uninstallation
* ...

**See:** tests in `test/test_application`

### g_run_script

Name of the script run by module, when `run_dir` command is called.

## Module internals

### stack_path

Stack for storing path during walk thru directory tree

## Module command scripts

Command scripts provided by the `run` module.

### run_dir_begin

Call it at the begining of the script for directory to push path onto stack.

### run_dir `<dir>`

Call it inside the script to run `g_run_script` in subdirectory `<dir>`

### run_script `<path/to/script>`

Run script with relative path from current script.

### run_dir_end

Call it at the end of the script for directory to pop path from the stack.

---
bump!