
@prepopulate_tickertable.sql

spool parallel_unload_test.txt

@parallel_unload_test.sql

spool off
