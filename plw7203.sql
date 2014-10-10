ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL'
/
CREATE OR REPLACE PACKAGE plw7203
IS
   TYPE collection_t IS TABLE OF VARCHAR2 (100);

   PROCEDURE proc (collection_in IN OUT collection_t);
END plw7203;
/

SHOW ERRORS PACKAGE BODY plw7203



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
