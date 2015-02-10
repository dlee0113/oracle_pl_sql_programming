CONNECT hr/hr@oracle11

DROP PACKAGE emplu11g
/

DROP TABLE employees_for_11g
/
CREATE TABLE employees_for_11g
AS SELECT * FROM employees
/

CREATE OR REPLACE PACKAGE emplu11g 
IS
   TYPE last_names_aat IS TABLE OF employees_for_11g.last_name%TYPE
      INDEX BY pls_INTEGER;
  
   TYPE employees_aat IS TABLE OF employees_for_11g%ROWTYPE
      INDEX BY pls_INTEGER;
  
   FUNCTION last_name (employee_id_in IN employees_for_11g.employee_id%TYPE)
      RETURN employees_for_11g.last_name%TYPE
      result_cache
   ;
   
   FUNCTION last_names (department_id_in IN employees_for_11g.department_id%TYPE)
      RETURN last_names_aat
      result_cache
   ;   

   FUNCTION employees_in_dept (department_id_in IN employees_for_11g.department_id%TYPE)
      RETURN employees_aat
      result_cache
   ;   

   FUNCTION restrict_employees_for_11g (schema_in VARCHAR2, NAME_IN VARCHAR2)
      RETURN VARCHAR2;
END;
/

CREATE OR REPLACE PACKAGE BODY emplu11g
IS
   FUNCTION last_name (employee_id_in IN employees_for_11g.employee_id%TYPE)
      RETURN employees_for_11g.last_name%TYPE
      result_cache relies_on (employees_for_11g)
   IS
      onerow_rec   employees_for_11g%ROWTYPE;
   BEGIN
      DBMS_OUTPUT.PUT_LINE ( 'Looking up last name for employee ID ' || employee_id_in );
      SELECT *
        INTO onerow_rec
        FROM employees_for_11g
       WHERE employee_id = employee_id_in;

      RETURN onerow_rec.last_name;
   END;
   
   FUNCTION last_names (department_id_in IN employees_for_11g.department_id%TYPE)
      RETURN last_names_aat
      result_cache relies_on (employees_for_11g)
   IS
      l_names last_names_aat;
   BEGIN
      DBMS_OUTPUT.PUT_LINE ( 'Getting all last names for department ID ' || department_id_in );
      SELECT last_name 
        BULK COLLECT INTO l_names
        FROM employees_for_11g
       WHERE department_id = department_id_in;

      RETURN l_names;
   END;

   FUNCTION employees_in_dept (department_id_in IN employees_for_11g.department_id%TYPE)
      RETURN employees_aat
      result_cache relies_on (employees_for_11g)
   IS
      l_employees employees_aat;
   BEGIN
      DBMS_OUTPUT.PUT_LINE ( 'Getting all rows for department ID ' || department_id_in );
      SELECT * 
        BULK COLLECT INTO l_employees
        FROM employees_for_11g
       WHERE department_id = department_id_in;

      RETURN l_employees;
   END;
   
   FUNCTION restrict_employees_for_11g (schema_in VARCHAR2, NAME_IN VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN (CASE USER
                 WHEN 'HR'
                    THEN '1 = 1'
                 ELSE '1 = 2'
              END
             );
   END restrict_employees_for_11g;
END;
/

/*
Can I cache an entire collection of strings? Yes!
*/

DECLARE
   l_names emplu11g.last_names_aat;
BEGIN
   l_names := emplu11g.last_names (50);
   DBMS_OUTPUT.put_line ('1. Count of names in department 50 = ' || l_names.COUNT);
   l_names := emplu11g.last_names (50);
   l_names := emplu11g.last_names (60);
   DBMS_OUTPUT.put_line ('2. Count of names in department 60 = ' || l_names.COUNT);
END;
/  

/*
Can I cache an entire collection of records? Yes!
*/

DECLARE
   l_employees emplu11g.employees_aat;
BEGIN
   l_employees := emplu11g.employees_in_dept (50);
   DBMS_OUTPUT.put_line ('1. Count of names in department 50 = ' || l_employees.COUNT);
   l_employees := emplu11g.employees_in_dept (50);
   l_employees := emplu11g.employees_in_dept (60);
   DBMS_OUTPUT.put_line ('2. Count of names in department 60 = ' || l_employees.COUNT);
END;
/  

/*
Will the cache show "dirty" data in the same session? NO!
*/

SET SERVEROUTPUT ON

BEGIN
   DBMS_OUTPUT.put_line ('BEFORE update 1: ' || emplu11g.last_name (198));
   DBMS_OUTPUT.put_line ('BEFORE update 2: ' || emplu11g.last_name (198));
   DBMS_OUTPUT.PUT_LINE ( '-' );

   UPDATE employees_for_11g SET last_name = 'Uh-oh'
    WHERE employee_id = 198;
    
   /* Shows me the new value and caching is disabled. */
   DBMS_OUTPUT.put_line ('AFTER update 1: ' || emplu11g.last_name (198)); 
   DBMS_OUTPUT.put_line ('AFTER update 2: ' || emplu11g.last_name (198)); 
   DBMS_OUTPUT.PUT_LINE ( '-' );
   
   /* After commit, will it start caching again? Yes! */
   COMMIT;
   DBMS_OUTPUT.put_line ('AFTER commit 1: ' || emplu11g.last_name (198)); 
   DBMS_OUTPUT.put_line ('AFTER commit 2: ' || emplu11g.last_name (198)); 
   DBMS_OUTPUT.PUT_LINE ( '-' );
   
   /* Reset last name */
   UPDATE employees_for_11g SET last_name = 'OConnell'
    WHERE employee_id = 198;
   COMMIT;
END;
/   

/*
Let's examine the impact of fine-grained access or 
virtual private database on the result cache.
*/

GRANT SELECT ON employees_for_11g TO scott
/
GRANT EXECUTE ON emplu11g TO scott
/

BEGIN
   BEGIN
      DBMS_RLS.drop_policy ('HR', 'employees_for_11g', 'rls_and_rc');
   EXCEPTION
      WHEN OTHERS
      THEN
         IF SQLCODE = -28102
         THEN
            NULL;
         ELSE
            RAISE;
         END IF;
   END;

   DBMS_RLS.add_policy
                    (object_schema        => 'HR'
                   , object_name          => 'employees_for_11g'
                   , policy_name          => 'rls_and_rc'
                   , function_schema      => 'HR'
                   , policy_function      => 'emplu11g.restrict_employees_for_11g'
                   , statement_types      => 'SELECT,UPDATE,DELETE,INSERT'
                   , update_check         => TRUE
                    );
END;
/

BEGIN
   /* Should see OConnell */
   DBMS_OUTPUT.put_line (emplu11g.last_name (198 /* Department 50 */));
END;
/

CONNECT scott/tiger@oracle11

SET SERVEROUTPUT ON

BEGIN
   /* Should raise NO_DATA_FOUND but instead.... */
   DBMS_OUTPUT.put_line (hr.emplu11g.last_name (198 /* Department 50 */));
END;
/

CONNECT hr/hr@oracle11

SET SERVEROUTPUT ON

BEGIN
   /* Flush the cache */
   UPDATE employees_for_11g
      SET last_name = SUBSTR (last_name, 1, 500);

   COMMIT;
END;
/

CONNECT scott/tiger@oracle11

SET SERVEROUTPUT ON

BEGIN
   /* Should raise NO_DATA_FOUND */
   DBMS_OUTPUT.put_line (hr.emplu11g.last_name (198 /* Department 50 */));
END;
/