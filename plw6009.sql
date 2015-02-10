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