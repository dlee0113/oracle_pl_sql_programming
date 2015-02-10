
set verify off
set serveroutput on

var t1 NUMBER;
var t2 NUMBER;

prompt
prompt Running &1 test with &2 elements...
prompt ===============================================

exec DBMS_SESSION.FREE_UNUSED_USER_MEMORY;

set autotrace traceonly statistics

exec :t1 := DBMS_UTILITY.GET_TIME;
SELECT * FROM TABLE(&1._function(&2));
exec :t2 := DBMS_UTILITY.GET_TIME;

INSERT INTO pipelined_vs_table_tests
   ( function_type, collection_size, pga_memory_used, elapsed_secs )
VALUES
   ( '&1', &2, SYS_CONTEXT('userenv','action'), (:t2-:t1)/100 ); 
COMMIT;

set autotrace off


