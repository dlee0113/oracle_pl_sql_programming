@@emplu.pkg
CREATE OR REPLACE PROCEDURE test_emplu (
   counter IN INTEGER, empno_in IN emp.empno%TYPE := 7788)
IS
   emprec employee%ROWTYPE;
BEGIN
   sf_timer.set_factor (counter);
   sf_timer.start_timer;
   FOR i IN 1 .. counter
   LOOP
      emprec := emplu1.onerow (empno_in);
   END LOOP;
   sf_timer.show_elapsed_time ('database table');

   sf_timer.set_factor (counter);
   sf_timer.start_timer;
   FOR i IN 1 .. counter
   LOOP
      emprec := emplu2.onerow (empno_in);
   END LOOP;
   sf_timer.show_elapsed_time ('index-by table');
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
