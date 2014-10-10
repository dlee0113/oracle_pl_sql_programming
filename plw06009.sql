ALTER SESSION SET plsql_warnings = 'ENABLE:ALL'
/

CREATE OR REPLACE FUNCTION plw6009
   RETURN PLS_INTEGER
AS
   l_count   PLS_INTEGER;
BEGIN
   SELECT COUNT ( * )
     INTO l_count
     FROM DUAL
    WHERE 1 = 2;

   RETURN l_count;
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line ('Error!');
      RETURN 0;
END plw6009;
/

SHOW ERRORS FUNCTION plw6009



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
