/* Formatted on 2002/04/24 14:49 (Formatter Plus v4.6.6) */
CREATE OR REPLACE PROCEDURE show_no_exc_sections
IS 
   CURSOR check_for_exc (nm IN VARCHAR2)
   IS
      SELECT line
        FROM user_source
       WHERE NAME = nm AND INSTR (UPPER (text), 'EXCEPTION') > 0;

   check_rec   check_for_exc%ROWTYPE;
BEGIN
   FOR obj_rec IN (SELECT object_name, object_type
                     FROM user_objects
                    WHERE object_type IN ('PROCEDURE', 'FUNCTION'))
   LOOP
      OPEN check_for_exc (obj_rec.object_name);
      FETCH check_for_exc INTO check_rec;

      IF check_for_exc%FOUND
      THEN
         NULL;
      ELSE
         DBMS_OUTPUT.put_line (
               obj_rec.object_type
            || ' '
            || obj_rec.object_name
            || ' does not contain the EXCEPTION keyword.'
         );
      END IF;

      CLOSE check_for_exc;
   END LOOP;
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
