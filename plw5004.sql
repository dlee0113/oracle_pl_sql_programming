ALTER SESSION SET plsql_warnings = 'ENABLE:ALL'
/

CREATE OR REPLACE PROCEDURE plw5004
IS
   INTEGER   NUMBER;

   PROCEDURE TO_CHAR
   IS
   BEGIN
      INTEGER := 10;
   END TO_CHAR;
BEGIN
   TO_CHAR;
END plw5004;
/

SHOW errors procedure plw5004



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
