CREATE OR REPLACE PROCEDURE test_emplu (
   counter          IN   INTEGER
 , employee_id_in   IN   employees.employee_id%TYPE := 138
)
/*

Compare performance of repeated querying of data to
caching in the PGA (packaged collection) and the
new Oracle 11g Result Cache.

Author: Steven Feuerstein

*/
IS
   emprec   employees%ROWTYPE;

   PROCEDURE setup
   IS
   BEGIN
      DBMS_SESSION.free_unused_user_memory ();
      sf_timer.set_factor (counter);
      sf_timer.start_timer;
   END;
BEGIN
   setup ();
   DBMS_OUTPUT.put_line ('PGA before tests are run:');
   my_session.MEMORY (TRUE, FALSE);

   FOR i IN 1 .. counter
   LOOP
      emprec := emplu1.onerow (employee_id_in);
   END LOOP;

   sf_timer.show_elapsed_time ('Execute query each time');
   my_session.MEMORY (TRUE, FALSE);
   --
   setup ();

   FOR i IN 1 .. counter
   LOOP
      emprec := emplu11g.onerow (employee_id_in);
   END LOOP;

   sf_timer.show_elapsed_time ('Oracle 11g result cache');
   my_session.MEMORY (TRUE, FALSE);
   --
   setup ();

   FOR i IN 1 .. counter
   LOOP
      emprec := emplu2.onerow (employee_id_in);
   END LOOP;

   sf_timer.show_elapsed_time ('Cache table in PGA memory');
   my_session.MEMORY (TRUE, FALSE);
END;
/