/* This is a demonstration of the IF-THEN-ELSIF example using BETWEEN.
   Note that the salary used in this example is 20,000, and that it
   represents a boundary condition. 20,000 matches the condition for a
   bonus of 1500, and also for a bonus of 1000. Which will it be?*/
DECLARE
  salary NUMBER := 20000;
  employee_id NUMBER := 36325;

  PROCEDURE give_bonus (emp_id IN NUMBER, bonus_amt IN NUMBER) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(emp_id);
    DBMS_OUTPUT.PUT_LINE(bonus_amt);
  END;

BEGIN
IF salary BETWEEN 10000 AND 20000
THEN
   give_bonus(employee_id, 1500);
ELSIF salary BETWEEN 20000 AND 40000
THEN
   give_bonus(employee_id, 1000);
ELSIF salary > 40000
THEN
   give_bonus(employee_id, 500);
ELSE
   give_bonus(employee_id, 0);
END IF;
END;
/



/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
