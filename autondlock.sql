CREATE OR REPLACE PROCEDURE update_salary (dept_in IN NUMBER)
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
   
   CURSOR myemps IS
      SELECT empno FROM emp
       WHERE deptno = dept_in
         FOR UPDATE NOWAIT;

BEGIN
   FOR rec IN myemps
   LOOP
      UPDATE emp SET sal = sal * 2 WHERE empno = rec.empno;
   END LOOP;
   COMMIT;
END;
/
   
BEGIN
   UPDATE emp SET sal = sal * 2;
   update_salary (10);
END;
/   

/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
