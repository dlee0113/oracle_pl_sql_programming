
set serveroutput on
set timing on

ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL = 0;

prompt
prompt Running pipelined in a loop...
prompt ===============================================

BEGIN
   FOR i IN 1 .. 100000 LOOP
      FOR r IN (SELECT * FROM TABLE(pipelined_function(10))) LOOP
         NULL;
      END LOOP;
   END LOOP;
END;
/

prompt
prompt Running table in a loop...
prompt ===============================================

BEGIN
   FOR i IN 1 .. 100000 LOOP
      FOR r IN (SELECT * FROM TABLE(table_function(10))) LOOP
         NULL;
      END LOOP;
   END LOOP;
END;
/



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/


