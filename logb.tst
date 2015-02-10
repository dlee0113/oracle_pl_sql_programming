/* Analyzes overhead of auton transactions. */
CREATE OR REPLACE PROCEDURE test_auton (
   counter IN INTEGER)
IS
   b BOOLEAN;
BEGIN
   ROLLBACK;

   sf_timer.set_factor (counter);
   sf_timer.start_timer;
   FOR repind IN 1 .. counter
   LOOP
      log81.putline (repind, 'Wow! ' || repind || ' just happened.');
   END LOOP;
   sf_timer.show_elapsed_time ('One transaction');

   ROLLBACK;
   
   sf_timer.start_timer;
   FOR repind IN 1 .. counter
   LOOP
       log81.saveline (repind, 
          'Wow! ' || repind || ' just happened.');
   END LOOP;
   sf_timer.show_elapsed_time ('Auton transaction');

   ROLLBACK;
   
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
