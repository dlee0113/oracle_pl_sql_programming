
spool pipelined_vs_table_test.txt

TRUNCATE TABLE pipelined_vs_table_tests;

-- push out the memory max beyond current allocation
DECLARE
   nt varchar2_ntt := varchar2_ntt();
BEGIN
   FOR i IN 1 .. 10000 LOOP
      nt.EXTEND;
      nt(nt.LAST) := RPAD('x',4000);
   END LOOP;
END;
/

@pipelined_vs_table_test pipelined 10
@pipelined_vs_table_test table 10
@pipelined_vs_table_test pipelined 100
@pipelined_vs_table_test table 100
@pipelined_vs_table_test pipelined 1000
@pipelined_vs_table_test table 1000
@pipelined_vs_table_test pipelined 10000
@pipelined_vs_table_test table 10000
@pipelined_vs_table_test pipelined 100000
@pipelined_vs_table_test table 100000
@pipelined_vs_table_test pipelined 500000
@pipelined_vs_table_test table 500000

SELECT *
FROM   pipelined_vs_table_tests
ORDER  BY
       collection_size
,      function_type;

spool off


