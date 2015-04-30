prompt Loading required module from path [&1]
whenever oserror exit rollback
@&1./module.sql "&1"
whenever oserror continue
