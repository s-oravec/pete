--init sqlsn
@sqlsnrc.sql

--require stack module from path
@&&sqlsn_require_from_path ".."

--test init and load
@@sqlsn-should-init
@@stack-module-should-load

--stack implementation
@@create-should-work
@@push-should-work
@@pop-should-work
@@push-and-pop-should-work
@@two-stacks-should-work


--TODO:
-- @@push-to-not-created-should-not-work
-- @@pop-from-not-created-should-not-work
-- @@create-again-should-not-work

--TODO:
-- test that it works as module required by other module

exit
