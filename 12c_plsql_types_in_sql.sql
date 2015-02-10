CREATE OR REPLACE FUNCTION uc_last_name (
   employee_id_in   IN employees.employee_id%TYPE,
   upper_in         IN BOOLEAN)
   RETURN employees.last_name%TYPE
IS
   l_return   employees.last_name%TYPE;
BEGIN
   SELECT last_name
     INTO l_return
     FROM employees
    WHERE employee_id = employee_id_in;

   RETURN CASE WHEN upper_in THEN UPPER (l_return) ELSE l_return END;
END;
/

BEGIN
   FOR rec IN (SELECT uc_last_name (last_name, TRUE) lname
                 FROM employees
                WHERE department_id = 10)
   LOOP
      DBMS_OUTPUT.put_line (rec.lname);
   END LOOP;
END;
/