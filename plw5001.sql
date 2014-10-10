CREATE OR REPLACE PROCEDURE plw5001
IS
   a   BOOLEAN;
   a   PLS_INTEGER;
BEGIN
   a := 1;   
   DBMS_OUTPUT.put_line ('Will not compile?');
END plw5001;
/

SHOW ERRORS

ALTER SESSION SET plsql_warnings = 'disable:all'
/

CREATE OR REPLACE PROCEDURE plw5001
IS
   a   BOOLEAN;
   a   PLS_INTEGER;
BEGIN
   DBMS_OUTPUT.put_line ('Will not compile?');
END plw5001;
/

ALTER PROCEDURE plw5001 COMPILE plsql_warnings = 'enable:all'
/

SHOW ERRORS



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/

