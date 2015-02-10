SELECT employee_id FROM employee  WHERE salary = 10000
/

DECLARE
   TYPE employee_aat IS TABLE OF employees.employee_id%TYPE
      INDEX BY PLS_INTEGER;
	  
   l_employees           employee_aat;
   
   TYPE boolean_aat IS TABLE OF BOOLEAN
      INDEX BY PLS_INTEGER;
	  
   l_employee_indices   boolean_aat;
BEGIN
   l_employees (1) := 7839;
   l_employees (100) := 7654;
   l_employees (500) := 7950;
   --
   l_employee_indices (1) := TRUE;
   l_employee_indices (500) := TRUE;
   l_employee_indices (799) := TRUE;
   --
   FORALL l_index IN INDICES OF l_employee_indices
      BETWEEN 1 AND 500
      UPDATE employees
         SET salary = 10000
       WHERE employee_id = l_employees (l_index);
END;
/

SELECT employee_id FROM employees  WHERE salary = 10000
/

ROLLBACK
/