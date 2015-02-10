CREATE OR REPLACE PROCEDURE run_9am_procedure (
   id_in     IN   employee.employee_id%TYPE,
   hour_in   IN   INTEGER
)
IS 
   v_apptcount   INTEGER;
   v_name        VARCHAR2 (100);
BEGIN
   EXECUTE IMMEDIATE    'BEGIN '
                     || TO_CHAR (SYSDATE, 'DAY')
                     || '_set_schedule (:id, :hour, :name, :appts); END;'
      USING IN id_in, IN hour_in, OUT v_name, OUT v_apptcount;
	  
   DBMS_OUTPUT.put_line (
         'Employee '
      || v_name
      || ' has '
      || v_apptcount
      || ' appointments on '
      || TO_CHAR (SYSDATE)
   );
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
