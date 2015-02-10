CREATE OR REPLACE PROCEDURE test_fullname (
   counter IN INTEGER
 , empno_in IN emp.empno%TYPE := 7788
)
IS
   l_name fullname_pkg.fullname_t;
BEGIN
   sf_timer.set_factor (counter);
   sf_timer.start_timer;

   FOR i IN 1 .. counter
   LOOP
      l_name := fullname_pkg.fullname (empno_in);
   END LOOP;

   sf_timer.show_elapsed_time ('function in SQL');
   sf_timer.set_factor (counter);
   sf_timer.start_timer;

   FOR i IN 1 .. counter
   LOOP
      l_name := fullname_pkg.fullname_explicit (empno_in);
   END LOOP;

   sf_timer.show_elapsed_time ('explicit function in SQL');
   sf_timer.set_factor (counter);
   sf_timer.start_timer;

   FOR i IN 1 .. counter
   LOOP
      l_name := fullname_pkg.fullname_twosteps (empno_in);
   END LOOP;

   sf_timer.show_elapsed_time ('function in PLSQL');
/*
SQL> exec test_fullname(10000)
function in SQL Elapsed: 1.38 seconds. Factored: .00014 seconds.
explicit function in SQL Elapsed: 1.43 seconds. Factored: .00014 seconds.
function in PLSQL Elapsed: .72 seconds. Factored: .00007 seconds.

SQL> exec test_fullname(100000)
function in SQL Elapsed: 13.01 seconds. Factored: .00013 seconds.
explicit function in SQL Elapsed: 14.38 seconds. Factored: .00014 seconds.
function in PLSQL Elapsed: 7.28 seconds. Factored: .00007 seconds.
*/
END;
/
