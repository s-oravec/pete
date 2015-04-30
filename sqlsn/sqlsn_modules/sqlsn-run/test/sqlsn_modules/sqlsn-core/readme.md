# Idea

**SQLSN** should be simple Oracle SQL\*Plus library of scripts, which make SQL\*Plus a little bit more comfortable.

It is a collection of scripts, which I tend to write all over again on each new project. Scripts for managing connections, environments, various action scripts, calling scripts organized in directory structure and so on ...

## Goals

* pure SQL*Plus, at least I will try 
* simple core
* organize scripts in reusable, ideally self-contained modules, with loosely coupled dependencies
* document and test everything

## Module

### Should
* have its own repository
* be self-contained in directory which can be put in `sqlsn_modules` without breaking anything
* be well documented and tested

### Defines
* module variables named `g_<module_name>_%` - other modules may depend on them
* module command scripts named `<module_name>_<command>` - scripts stored in `<module_name>/lib` implementing commands
    
### Uses
* module variables and command scripts defined by other modules
* directory `lib/tmp` for on-the-fly created and executed SQL*Plus scripts which implement missing language constructs


## Feature roadmap

**Core and near-core modules which do not need connection to database**

* sqlsn-core - [done]
* sqlsn-stack - module implementing stack [done]
* sqlsn-log - module implementing simple logging into file [in progress]
* sqlsn-run - module implementing runing scripts/directory trees of scripts [done]

**Modules that manage connections**

* sqlsn-conn - module for connection configurations [in design phase]
* sqlsn-env - module for environment definitions [in design phase]
* sqlsn-log-db - logging into database [in design phase]

**"Music of the Future (word-by-word translation from czech/slovak ;)"**

* module repository with 
    * declarative module dependency
    * (multi)platform (in)dependant scripts that can pull modules from repository

# SQLSN - core

This is the core module - heart of **SQLSN**. Über-simple heart. At least it starts as simple ;) We'll see.

# Usage

Module name is `sqlsn` so in "applications" written using SQLSN substitution variables starting with `g_sqlsn` or `sqlsn` should be avoided.

## Initialize module

Initialize SQLSN core module prior any usage.

````
prompt tell SQLSN core where it is located regarding to THE-SCRIPT
@<path_to_sqlsn_core>/module.sql <path_to_sqlsn_core>
````

e.g.:

````
--in THE-SCRIPT test/test.sql
@../module.sql ".."

````

## Requirements

### g_sqlsn_modules_path

Path to SQLSN modules from THE-SCRIPT. Set it in some `sqlsnrc.sql` script. (Example can be found in `test`)

## Globals

Globals defined by core module

### g_sqlsn_path

Path to SQLSN core from THE-SCRIPT. It is set in `module.sql` script during initilization of sqlsn-core.

## Module command scripts

Command scripts provided by the core module. Path to the script is stored in substition variable, so calling is pretty simple:

````
@&&<module_name>_<command>
````

### sqslsn_require

Loads required module. If modules are placed somwhere else, as default `g_sqlsn_modules_path` than override `g_sqlsn_modules_path` manually.

````
@&&sqlsn_require <module_name>
````

### sqslsn_require_from_path

Loads required module from path.

````
@&&sqlsn_require_from_path "<path/module_name>"
````

### sqlsn_noop

No op command - use it as mock for functionality that is currently not implemented.

````
define future_command = &&sqlsn_noop
````

