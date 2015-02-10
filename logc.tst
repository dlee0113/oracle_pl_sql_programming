/* Demonstrates nesting of auton transactions. */

DROP table emp2;
CREATE TABLE emp2 as select * from emp;

CREATE OR REPLACE PROCEDURE test_auton
IS
   PROCEDURE auton
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      DELETE
        FROM emp2;
      DBMS_OUTPUT.PUT_LINE ('emp2 ' || tabcount ('emp2'));
      log81.saveline (0, 'Deleted all from emp2');
      ROLLBACK;
   END;
BEGIN
   DBMS_OUTPUT.PUT_LINE ('emp2 ' || tabcount ('emp2'));
   DBMS_OUTPUT.PUT_LINE ('log81tab ' || tabcount ('log81tab'));
   auton;
   DBMS_OUTPUT.PUT_LINE ('emp2 ' || tabcount ('emp2'));
   DBMS_OUTPUT.PUT_LINE ('log81tab ' || tabcount ('log81tab'));
END;
/

/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
