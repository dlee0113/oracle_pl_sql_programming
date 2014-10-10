CREATE OR REPLACE PROCEDURE runddl (ddl_in in VARCHAR2)
IS
   cur INTEGER:= DBMS_SQL.OPEN_CURSOR;
   fdbk INTEGER;
BEGIN
   DBMS_SQL.PARSE (cur, ddl_in, DBMS_SQL.NATIVE);
   fdbk := DBMS_SQL.EXECUTE (cur);
   DBMS_SQL.CLOSE_CURSOR (cur);
EXCEPTION
   WHEN OTHERS
   THEN   
      DBMS_OUTPUT.PUT_LINE (
         'RunDDL Failure on ' || ddl_in);
      DBMS_OUTPUT.PUT_LINE (SQLERRM);
      DBMS_SQL.CLOSE_CURSOR (cur);
END;
/





/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
