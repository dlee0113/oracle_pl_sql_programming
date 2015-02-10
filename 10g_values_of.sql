SELECT employee_id FROM employee  WHERE salary = 10000
/

DECLARE
   TYPE employee_aat IS TABLE OF employees.employee_id%TYPE
      INDEX BY PLS_INTEGER;

   l_employees           employee_aat;

   TYPE indices_aat IS TABLE OF PLS_INTEGER
      INDEX BY PLS_INTEGER;

   l_employee_indices   indices_aat;
BEGIN
   l_employees (-77) := 7820;
   l_employees (13067) := 7799;
   l_employees (99999999) := 7369;
   --
   l_employee_indices (100) := -77;
   l_employee_indices (200) := 99999999;
   --
   FORALL l_index IN VALUES OF l_employee_indices
      UPDATE employees
         SET salary = 10000
       WHERE employee_id = l_employees (l_index);
END;
/

SELECT employee_id FROM employees  WHERE salary = 10000
/

ROLLBACK
/