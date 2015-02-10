/* To get code to compile properly, unzip TopDown.zip and compile the topdown package. */

DROP TABLE cases
/

CREATE TABLE cases (id INTEGER)
/

CREATE OR REPLACE PACKAGE call_analysis
IS
   FUNCTION current_caseload (emp_in IN NUMBER)
      RETURN INTEGER;

   FUNCTION avg_caseload_for_dept (dept_in IN NUMBER)
      RETURN INTEGER;
END call_analysis;
/

CREATE OR REPLACE PACKAGE BODY call_analysis
IS
   FUNCTION current_caseload (emp_in IN NUMBER)
      RETURN INTEGER
   IS
   BEGIN
      RETURN 1;
   END current_caseload;

   FUNCTION avg_caseload_for_dept (dept_in IN NUMBER)
      RETURN INTEGER
   IS
   BEGIN
      RETURN 1;
   END avg_caseload_for_dept;
END call_analysis;
/

/* First pass: create header of program and set up
   your test definition.
   
   Recommendation: use Quest Code Tester!
*/

CREATE OR REPLACE PACKAGE call_support_pkg
IS
   PROCEDURE distribute_calls (
      department_id_in IN employees.department_id%TYPE
   );
END call_support_pkg;
/

CREATE OR REPLACE PACKAGE BODY call_support_pkg
IS
   PROCEDURE distribute_calls (
      department_id_in IN employees.department_id%TYPE
   )
   IS
   BEGIN
      NULL;
   END distribute_calls;
END call_support_pkg;
/

/* Second pass: create main executable section base
   on "executive summary" in documentation. */

CREATE OR REPLACE PACKAGE BODY call_support_pkg
IS
   PROCEDURE distribute_calls (
      department_id_in IN employees.department_id%TYPE
   )
   IS
   BEGIN
      WHILE (calls_still_unhandled ())
      LOOP
         FOR emp_rec IN support_dept_cur (department_id_in)
         LOOP
            IF call_analysis.current_caseload (emp_rec.employee_id) <
                  call_analysis.avg_caseload_for_dept (department_id_in)
            THEN
               assign_next_open_call_to (emp_rec.employee_id, l_case_id);
               notify_customer (l_case_id);
            END IF;
         END LOOP;
      END LOOP;
   END distribute_calls;
END call_support_pkg;
/

/* Third pass: build local modules for each placeholder,
   add enough code to get a clean compile. 
   
   Recommendation: use the topdown package's 
   "To be completed" program to create your stubs. 
*/

CREATE OR REPLACE PACKAGE BODY call_support_pkg
IS
   PROCEDURE distribute_calls (
      department_id_in IN employees.department_id%TYPE
   )
   IS
      l_case_id   cases.id%TYPE;

      CURSOR support_dept_cur (
         department_id_in IN employees.department_id%TYPE
      )
      IS
         SELECT *
           FROM employees
          WHERE department_id = department_id_in;

      FUNCTION calls_still_unhandled
         RETURN BOOLEAN
      IS
      BEGIN
         /* Zagreb Sept 2007 */
         topdown.tbc ('calls_still_unhandled');
         RETURN NULL;
      END calls_still_unhandled;

      PROCEDURE assign_next_open_call_to (
         employee_id_in IN     employees.employee_id%TYPE
       , case_id_out       OUT cases.id%TYPE
      )
      IS
      BEGIN
         topdown.tbc ('assign_next_open_call_to');
      END assign_next_open_call_to;

      PROCEDURE notify_customer (case_id_in IN cases.id%TYPE)
      IS
      BEGIN
         topdown.tbc ('notify_customer');
      END notify_customer;
   BEGIN
      WHILE (calls_still_unhandled ())
      LOOP
         FOR emp_rec IN support_dept_cur (department_id_in)
         LOOP
            IF call_analysis.current_caseload (emp_rec.employee_id) <
                  call_analysis.avg_caseload_for_dept (department_id_in)
            THEN
               assign_next_open_call_to (emp_rec.employee_id, l_case_id);
               notify_customer (l_case_id);
            END IF;
         END LOOP;
      END LOOP;
   END distribute_calls;
END call_support_pkg;
/

/* Try it out! */

BEGIN
   topdown.tbc_show;
   call_support_pkg.distribute_calls (15);
END;
/

/* Fourth pass: go down one level of detail to
   assign_next_open_call_to and repeat the process. */

CREATE OR REPLACE PACKAGE BODY call_support_pkg
IS
   PROCEDURE distribute_calls (
      department_id_in IN employees.department_id%TYPE
   )
   IS
      l_case_id   cases.id%TYPE;

      CURSOR support_dept_cur (
         department_id_in IN employees.department_id%TYPE
      )
      IS
         SELECT *
           FROM employees
          WHERE department_id = department_id_in;

      FUNCTION calls_still_unhandled
         RETURN BOOLEAN
      IS
      BEGIN
         topdown.tbc ('calls_still_unhandled');
         RETURN NULL;
      END calls_still_unhandled;

      PROCEDURE assign_next_open_call_to (
         employee_id_in IN     employees.employee_id%TYPE
       , case_id_out       OUT cases.id%TYPE
      )
      IS
         PROCEDURE find_next_open_call (case_out OUT NUMBER)
         IS
         BEGIN
            topdown.tbc ('find_next_open_call');
         END find_next_open_call;

         PROCEDURE assign_to_employee (employee_id_in IN NUMBER
                                     , case_in        IN NUMBER
                                      )
         IS
         BEGIN
            topdown.tbc ('assign_to_employee');
         END assign_to_employee;
      BEGIN
         find_next_open_call (case_id_out);
         assign_to_employee (employee_id_in, case_id_out);
      END assign_next_open_call_to;

      PROCEDURE notify_customer (case_id_in IN cases.id%TYPE)
      IS
      BEGIN
         topdown.tbc ('notify_customer');
      END notify_customer;
   BEGIN
      WHILE (calls_still_unhandled ())
      LOOP
         FOR emp_rec IN support_dept_cur (department_id_in)
         LOOP
            IF call_analysis.current_caseload (emp_rec.employee_id) <
                  call_analysis.avg_caseload_for_dept (department_id_in)
            THEN
               assign_next_open_call_to (emp_rec.employee_id, l_case_id);
               notify_customer (l_case_id);
            END IF;
         END LOOP;
      END LOOP;
   END distribute_calls;
END call_support_pkg;
/

BEGIN
   topdown.tbc_show;
   call_support_pkg.distribute_calls (15);
END;
/

