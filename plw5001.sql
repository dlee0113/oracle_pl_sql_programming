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
