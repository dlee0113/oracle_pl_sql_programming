DECLARE
/* Different approaches to answering "at least one?" */
   CURSOR empcur
   IS
      SELECT employee_id
        FROM employee_big WHERE department_id = &&2;
   v NUMBER;
   b BOOLEAN;
BEGIN
   sf_timer.set_factor (&&1);
   sf_timer.start_timer;
   FOR i IN 1 .. &&1
   LOOP
      BEGIN
         SELECT employee_id INTO v FROM employee_big 
          WHERE department_id = &&2;
         b := TRUE;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN b := FALSE;
         WHEN TOO_MANY_ROWS THEN b := TRUE;
      END;
   END LOOP;
   sf_timer.show_elapsed_time ('Implicit');

   sf_timer.start_timer;
   FOR i IN 1 .. &&1
   LOOP
      OPEN empcur;
      FETCH empcur INTO v;
      b := empcur%FOUND;
      CLOSE empcur;
   END LOOP;
   sf_timer.show_elapsed_time ('Explicit');

   sf_timer.start_timer;
   FOR i IN 1 .. &&1
   LOOP
      SELECT COUNT(*) INTO v 
        FROM employee_big WHERE department_id = &&2;
      b := v > 0;
   END LOOP;
   sf_timer.show_elapsed_time ('COUNT');

   /* Ohio OUG Contributions.... */
   sf_timer.start_timer;
   FOR i IN 1 .. &&1
   LOOP
      SELECT COUNT(1) INTO v 
        FROM employee_big WHERE department_id = &&2
         AND ROWNUM < 2;
      b := v > 0;
   END LOOP;
   sf_timer.show_elapsed_time ('COUNT ROWNUM<2');

   /* Quest seminar UK 10/99 */
   sf_timer.start_timer;
   FOR i IN 1 .. &&1
   LOOP
      SELECT NULL INTO v FROM dual WHERE
         EXISTS (SELECT 'x' FROM employee_big 
                  WHERE department_id = &&2);
      b := v IS NOT NULL;
   END LOOP;
   sf_timer.show_elapsed_time ('EXISTS');
/*
SQL>  @atleastone 1000 20
Implicit Elapsed: .45 seconds. Factored: .00045 seconds.
Explicit Elapsed: .12 seconds. Factored: .00012 seconds.
COUNT Elapsed: 2.21 seconds. Factored: .00221 seconds.
COUNT ROWNUM<2 Elapsed: .1 seconds. Factored: .0001 seconds.
EXISTS Elapsed: .14 seconds. Factored: .00014 seconds.

SQL>  @atleastone 20000 20
Implicit Elapsed: 8.06 seconds. Factored: .0004 seconds.
Explicit Elapsed: 2.46 seconds. Factored: .00012 seconds.
COUNT Elapsed: 42.21 seconds. Factored: .00211 seconds.
COUNT ROWNUM<2 Elapsed: 2.42 seconds. Factored: .00012 seconds.
EXISTS Elapsed: 2.63 seconds. Factored: .00013 seconds.
*/
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
