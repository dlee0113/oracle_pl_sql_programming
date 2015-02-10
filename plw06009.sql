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