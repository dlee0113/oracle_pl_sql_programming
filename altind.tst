BEGIN
   /* Show the conflict resolution logic with a tiny hash table
      whose starting value is right at the end of the valid range. */
   altind.trc (2**31-5, 20);
   altind.loadcache;
   altind.notrc;
   altind.loadcache;
END;
/

CREATE OR REPLACE PROCEDURE altind_compare (
   counter IN INTEGER,
   ename_in IN VARCHAR2
   )
/* Compare performance of hash scan and full table scan. */
IS
   emprec employee%ROWTYPE;
BEGIN
   sf_timer.set_factor (counter);
   sf_timer.start_timer;
   FOR i IN 1 .. counter
   LOOP
      emprec := altind.onerow (ename_in, TRUE);
      IF i = 1
      THEN
         do.pl /* do.pkg */ (emprec.employee_id);
      END IF;
   END LOOP;
   sf_timer.show_elapsed_time ('Hash');
   
   sf_timer.set_factor (counter);
   sf_timer.start_timer;
   FOR i IN 1 .. counter
   LOOP
      emprec := altind.onerow (ename_in, FALSE);
      IF i = 1
      THEN
         do.pl /* do.pkg */ (emprec.employee_id);
      END IF;
   END LOOP;
   sf_timer.show_elapsed_time ('Full index-by scan');
   
   sf_timer.set_factor (counter);
   sf_timer.start_timer;
   FOR i IN 1 .. counter
   LOOP
      emprec := altind.onerow_dbind (ename_in);
      IF i = 1
      THEN
         do.pl /* do.pkg */ (emprec.employee_id);
      END IF;
   END LOOP;
   sf_timer.show_elapsed_time ('Indexed DB lookup');
   
   sf_timer.set_factor (counter);
   sf_timer.start_timer;
   FOR i IN 1 .. counter
   LOOP
      emprec := altind.onerow_dbnoind (ename_in);
      IF i = 1
      THEN
         do.pl /* do.pkg */ (emprec.employee_id);
      END IF;
   END LOOP;
   sf_timer.show_elapsed_time ('Non-indexed DB lookup');
END;
/

BEGIN
   do.pl /* do.pkg */ ('Testing for SMITH');
   altind_compare (1000, 'SMITH');
END;
/

BEGIN
   do.pl /* do.pkg */ ('Testing for WEST');
   altind_compare (1000, 'WEST');
END;
/

BEGIN
   do.pl /* do.pkg */ ('Testing for MURRAY');
   altind_compare (1000, 'MURRAY');
END;
/

/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
