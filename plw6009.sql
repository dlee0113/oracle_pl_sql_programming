ALTER SESSION SET plsql_warnings = 'enable:all'
/

CREATE OR REPLACE PROCEDURE plw6009_demo
AS
BEGIN
   DBMS_OUTPUT.put_line ('I am here!');
   RAISE NO_DATA_FOUND;
EXCEPTION
   WHEN OTHERS
   THEN
      NULL;
END plw6009_demo;
/



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
