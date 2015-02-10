CREATE OR REPLACE PROCEDURE drop_dept (
   deptno_in          IN employees.department_id%TYPE
 , reassign_deptno_in IN employees.department_id%TYPE
)
IS
   l_count   PLS_INTEGER;
BEGIN
   DBMS_APPLICATION_INFO.set_module (module_name => 'DEPARTMENT FIXES'
                                   , action_name => NULL
                                    );

   DBMS_APPLICATION_INFO.set_action (action_name => 'GET COUNT IN DEPT');

   SELECT COUNT ( * )
     INTO l_count
     FROM employees
    WHERE department_id = deptno_in;

   DBMS_OUTPUT.put_line ('Reassigning ' || l_count || ' employees');

   IF l_count > 0
   THEN
      DBMS_APPLICATION_INFO.set_action (action_name => 'REASSIGN EMPLOYEES');

      UPDATE employees
         SET department_id = reassign_deptno_in
       WHERE department_id = deptno_in;
   END IF;

   DBMS_APPLICATION_INFO.set_action (action_name => 'DROP DEPT');

   DELETE FROM departments
         WHERE department_id = deptno_in;

   COMMIT;

   DBMS_APPLICATION_INFO.set_module (NULL, NULL);
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_APPLICATION_INFO.set_module (NULL, NULL);
END drop_dept;