/* This is an IF-THEN-ELSIF demonstration similar to that in
   ch04_if01.sql, but this time we use < and > rather than BETWEEN
   in order to eliminate any overlap between conditions. */
DECLARE
  salary NUMBER := 20000;
  employee_id NUMBER := 36325;

  PROCEDURE give_bonus (emp_id IN NUMBER, bonus_amt IN NUMBER) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(emp_id);
    DBMS_OUTPUT.PUT_LINE(bonus_amt);
  END;

BEGIN
IF salary >= 10000 AND salary <= 20000
THEN
   give_bonus(employee_id, 1500);
ELSIF salary > 20000 AND salary <= 40000
THEN
   give_bonus(employee_id, 1000);
ELSIF salary > 40000
THEN
   give_bonus(employee_id, 500);
END IF;
END;
/



/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
