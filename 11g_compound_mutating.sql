/*
The rule is: your new salary cannot be more than 
25x the lowest salary in your department. So at
the row level we set the salaries, and keep track
of whose salaries were changed. Then at the statement
level, we get the lowest salary, compute the new
equitable maximum, and then apply it to any salaries which 
exceeded that. 
*/ 

/* Demonstration of mutating table trigger error. */

CREATE OR REPLACE TRIGGER equitable_salary_trg
   AFTER INSERT OR UPDATE
   ON employees
   FOR EACH ROW
DECLARE
   l_max_allowed   employees.salary%TYPE;
BEGIN
   SELECT MIN (salary) * 25
     INTO l_max_allowed
     FROM employees;

   IF l_max_allowed < :NEW.salary
   THEN
      UPDATE employees
         SET salary = l_max_allowed
       WHERE employee_id = :NEW.employee_id;
   END IF;
END equitable_salary_trg;
/

BEGIN
   UPDATE employees
      SET salary = 100000
    WHERE last_name = 'King';

   ROLLBACK;
END;
/

/*
ORA-04091: table HR.EMPLOYEES is mutating, trigger/function may not see it
ORA-06512: at "HR.EQUITABLE_SALARY_TRG", line 4
ORA-04088: error during execution of trigger 'HR.EQUITABLE_SALARY_TRG'
*/

/*
And now the "traditional solution" - package-based collection and 
multiple triggers.
*/

DROP TRIGGER equitable_salary_trg
/

CREATE OR REPLACE PACKAGE equitable_salaries_pkg
IS
   PROCEDURE initialize;

   PROCEDURE add_employee_info (
      employee_id_in IN employees.employee_id%TYPE
    , salary_in IN employees.salary%TYPE
   );

   PROCEDURE make_equitable;
END equitable_salaries_pkg;
/

CREATE OR REPLACE PACKAGE BODY equitable_salaries_pkg
IS
   TYPE id_salary_rt IS RECORD (
      employee_id   employees.employee_id%TYPE
    , salary        employees.salary%TYPE
   );

   TYPE g_emp_info_t IS TABLE OF id_salary_rt
      INDEX BY PLS_INTEGER;

   g_emp_info                 g_emp_info_t;
   g_corrections_in_process   BOOLEAN      := FALSE;

   PROCEDURE initialize
   IS
   BEGIN
      g_emp_info.DELETE;
   END initialize;

   PROCEDURE finished_corrections
   IS
   BEGIN
      g_corrections_in_process := FALSE;
   END finished_corrections;

   PROCEDURE starting_corrections
   IS
   BEGIN
      g_corrections_in_process := TRUE;
   END starting_corrections;

   FUNCTION corrections_in_process
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN g_corrections_in_process;
   END corrections_in_process;

   PROCEDURE add_employee_info (
      employee_id_in IN employees.employee_id%TYPE
    , salary_in IN employees.salary%TYPE
   )
   IS
      l_index   PLS_INTEGER := g_emp_info.COUNT + 1;
   BEGIN
      IF NOT corrections_in_process
      THEN
         g_emp_info (l_index).employee_id := employee_id_in;
         g_emp_info (l_index).salary := salary_in;
         --
         q$error_manager.TRACE ('add_employee_info'
                              ,    g_emp_info (l_index).employee_id
                                || '-'
                                || g_emp_info (l_index).salary
                               );
      END IF;
   END add_employee_info;

   PROCEDURE make_equitable
   IS
      l_max_allowed   employees.salary%TYPE;
      l_index         PLS_INTEGER;
   BEGIN
      IF NOT corrections_in_process
      THEN
         starting_corrections;

         SELECT MIN (salary) * 25
           INTO l_max_allowed
           FROM employees;

         q$error_manager.TRACE ('make_equitable max allowed', l_max_allowed);

         WHILE (g_emp_info.COUNT > 0)
         LOOP
            l_index := g_emp_info.FIRST;
            --
            q$error_manager.TRACE ('make_equitable emp id and salary'
                                 ,    g_emp_info (l_index).employee_id
                                   || '-'
                                   || g_emp_info (l_index).salary
                                  );

            IF l_max_allowed < g_emp_info (l_index).salary
            THEN
               UPDATE employees
                  SET salary = l_max_allowed
                WHERE employee_id = g_emp_info (l_index).employee_id;
            END IF;

            g_emp_info.DELETE (g_emp_info.FIRST);
         END LOOP;

         finished_corrections;
      END IF;
   END make_equitable;
END equitable_salaries_pkg;
/

CREATE OR REPLACE TRIGGER equitable_salaries_bstrg
   before INSERT OR UPDATE 
   ON employees
BEGIN
   LOCK TABLE employees IN EXCLUSIVE MODE;
   equitable_salaries_pkg.initialize;
END;
/

CREATE OR REPLACE TRIGGER equitable_salaries_rtrg
   AFTER INSERT OR UPDATE OF salary
   ON employees
   FOR EACH ROW
BEGIN
   equitable_salaries_pkg.add_employee_info (:NEW.employee_id, :NEW.salary);
END;
/

CREATE OR REPLACE TRIGGER equitable_salaries_astrg
   AFTER INSERT OR UPDATE 
   ON employees
BEGIN
   equitable_salaries_pkg.make_equitable;
END;
/

BEGIN
   UPDATE employees
      SET salary = 100000
    WHERE last_name = 'King';

   ROLLBACK;
END;
/

/*
And here is the much simpler 11g implementation:
*/

CREATE OR REPLACE TRIGGER equitable_salary_trg
FOR UPDATE OR INSERT ON mfe_customers
COMPOUND TRIGGER
IS
   TYPE id_salary_rt IS RECORD (
      employee_id   employees.employee_id%TYPE
    , salary        employees.salary%TYPE
   );

   TYPE row_level_info_t IS TABLE OF id_salary_rt
      INDEX BY PLS_INTEGER;

   g_row_level_info   row_level_info_t;

   AFTER ROW IS
   BEGIN
      g_row_level_info (g_row_level_info.COUNT + 1).employee_id :=
                                                             :NEW.employee_id;
      g_row_level_info (g_row_level_info.COUNT + 1).salary := :NEW.salary;
   END AFTER ROW;

   AFTER STATEMENT IS
      l_max_allowed   employees.salary%TYPE;
   BEGIN
      SELECT MIN (salary) * 25
        INTO l_max_allowed
        FROM employees;

      FOR indx IN 1 .. g_row_level_info.COUNT
      LOOP
         IF l_max_allowed < g_row_level_info (indx).salary
         THEN
            UPDATE employees
               SET salary = l_max_allowed
             WHERE employee_id = g_row_level_info (indx).employee_id;
         END IF;
      END LOOP;
   END AFTER STATEMENT;
END equitable_salary_trg;
/

