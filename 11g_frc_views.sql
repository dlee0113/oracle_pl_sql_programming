CREATE OR REPLACE VIEW hr_just_names
AS
   SELECT d.department_name, e.last_name, e.first_name
     FROM employees e, departments d
    WHERE d.department_id = e.department_id
/

/* Invalidate the cache. */

BEGIN
   dbms_result_cache.invalidate (USER, 'HR_JUST_NAMES');
END;
/

CREATE OR REPLACE PACKAGE emplu11g
IS
   FUNCTION last_name (employee_id_in IN employees.employee_id%TYPE)
      RETURN employees.last_name%TYPE
      RESULT_CACHE
;
END;
/

CREATE OR REPLACE PACKAGE BODY emplu11g
IS
   /* Relies on references a view */
   FUNCTION last_name (employee_id_in IN employees.employee_id%TYPE)
      RETURN employees.last_name%TYPE
      RESULT_CACHE RELIES_ON ( hr_just_names )
   IS
      onerow_rec   employees%ROWTYPE;
   BEGIN
      DBMS_OUTPUT.put_line (
         'Looking up last name for employee ID ' || employee_id_in
      );

      SELECT *
        INTO onerow_rec
        FROM employees
       WHERE employee_id = employee_id_in;

      RETURN onerow_rec.last_name;
   END;
END;
/

BEGIN
   DBMS_OUTPUT.put_line ('Cache some data....');

   FOR indx IN 1 .. 2
   LOOP
      DBMS_OUTPUT.put_line (emplu11g.last_name (138));
      DBMS_OUTPUT.put_line (emplu11g.last_name (140));
   END LOOP;
END;
/

/* Change only the department table */

BEGIN
   DBMS_OUTPUT.put_line ('Change department names only....');

   UPDATE departments
      SET department_name = department_name;

   COMMIT;
END;
/

/*
Am I still caching?
*/

BEGIN
   FOR indx IN 1 .. 3
   LOOP
      DBMS_OUTPUT.put_line (emplu11g.last_name (138));
      DBMS_OUTPUT.put_line (emplu11g.last_name (140));
   END LOOP;
END;
/