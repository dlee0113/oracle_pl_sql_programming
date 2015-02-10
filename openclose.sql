CREATE OR REPLACE PACKAGE personnel
IS
   CURSOR emps_for_dept (
      department_id_in IN employees.department_id%TYPE)
   IS
      SELECT * FROM employees 
       WHERE department_id = department_id_in;

   PROCEDURE open_emps_for_dept(
      department_id_in IN employees.department_id%TYPE,
      close_if_open IN BOOLEAN := TRUE
      );

   PROCEDURE close_emps_for_dept;
   
END personnel;
/
CREATE OR REPLACE PACKAGE BODY personnel
IS
   PROCEDURE open_emps_for_dept (
      department_id_in IN employees.department_id%TYPE,
      close_if_open IN BOOLEAN := TRUE
      )
   IS
      v_close BOOLEAN := NVL (close_if_open, TRUE);
      v_open BOOLEAN := TRUE;
   BEGIN
      IF emps_for_dept%ISOPEN AND v_close
      THEN
         CLOSE emps_for_dept;

      ELSIF emps_for_dept%ISOPEN AND NOT v_close
      THEN
         v_open := FALSE;
      END IF;

      IF v_open THEN
         OPEN emps_for_dept (department_id_in);
      END IF;
   END;

   PROCEDURE close_emps_for_dept 
   IS
   BEGIN
      IF emps_for_dept%ISOPEN
      THEN
         CLOSE emps_for_dept;
      END IF;
   END;
END personnel;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
