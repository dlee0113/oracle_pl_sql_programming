DROP TABLE query_trace;

CREATE TABLE query_trace (
   table_name VARCHAR2(30),
   rowid_info ROWID,
   queried_by VARCHAR2(30),
   queried_at DATE
   );
   
CREATE OR REPLACE FUNCTION traceit (
   tab IN VARCHAR2,
   rowid_in IN ROWID)
   RETURN INTEGER
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   INSERT INTO query_trace VALUES (tab, rowid_in, USER, SYSDATE);
   COMMIT;
   RETURN 0;
END;
/

SELECT ename, traceit ('emp', ROWID)
  FROM emp;

SELECT table_name, rowid_info, queried_by, 
       TO_CHAR (queried_at, 'HH:MI:SS') queried_at
  FROM query_trace;















/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
