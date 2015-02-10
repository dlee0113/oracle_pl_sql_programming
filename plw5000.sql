ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL'
/
CREATE OR REPLACE PACKAGE plw5000
IS
   TYPE collection_t IS TABLE OF VARCHAR2 (100);

   PROCEDURE proc (collection_in IN OUT NOCOPY collection_t);
END plw5000;
/
CREATE OR REPLACE PACKAGE BODY plw5000
IS
   PROCEDURE proc (collection_in IN OUT collection_t)
   IS
   BEGIN
      DBMS_OUTPUT.PUT_LINE ('Hello!');
   END proc;
END plw5000;
/

SHOW ERRORS PACKAGE BODY plw5000