/* Formatted on 2002/05/03 15:05 (Formatter Plus v4.6.5) */

CREATE OR REPLACE PROCEDURE settrig (tab IN VARCHAR2, action IN VARCHAR2)
IS 
   v_action         VARCHAR2 (10) := UPPER (action);
   v_other_action   VARCHAR2 (10) := 'DISABLED';
BEGIN
   IF v_action = 'DISABLE'
   THEN
      v_other_action := 'ENABLED';
   END IF;

   FOR rec IN (SELECT trigger_name
                 FROM user_triggers
                WHERE table_owner = USER
                  AND table_name = UPPER (tab)
                  AND status = v_other_action)
   LOOP
      EXECUTE IMMEDIATE 'ALTER TRIGGER ' || rec.trigger_name || ' ' || v_action;
      DBMS_OUTPUT.put_line (
         'Set status of ' || rec.trigger_name || ' to ' || v_action
      );
   END LOOP;
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
