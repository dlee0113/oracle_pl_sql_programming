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
END;
/

/*
Demonstration of scalar caching
*/
BEGIN
   FOR indx IN 1 .. 10
   LOOP
      DBMS_OUTPUT.put_line (emplu11g.last_name (138));
   END LOOP;
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
   /*
   Querying all rows into a collection does NOT help with caching
   based on a single employee ID, even if the data returned is the "same"
   and has been cached by another function.
   */
   DBMS_OUTPUT.put_line ('Last name for 198 = ' || emplu11g.last_name(198));   
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
   DBMS_OUTPUT.put_line ('BEFORE update 1: ' || emplu11g.last_name (144));
   DBMS_OUTPUT.put_line ('BEFORE update 2: ' || emplu11g.last_name (144));
   DBMS_OUTPUT.PUT_LINE ( '-' );

   UPDATE employees_for_11g SET last_name = 'Uh-oh'
    WHERE employee_id = 198;
    
   /* Shows me the new value and caching is disabled. */
   DBMS_OUTPUT.put_line ('AFTER update 1: ' || emplu11g.last_name (144)); 
   DBMS_OUTPUT.put_line ('AFTER update 2: ' || emplu11g.last_name (144)); 
   DBMS_OUTPUT.PUT_LINE ( '-' );
   
   /* After commit, will it start caching again? Yes! */
   COMMIT;
   DBMS_OUTPUT.put_line ('AFTER commit 1: ' || emplu11g.last_name (144)); 
   DBMS_OUTPUT.put_line ('AFTER commit 2: ' || emplu11g.last_name (144)); 
   DBMS_OUTPUT.PUT_LINE ( '-' );
   
   /* Reset last name */
   UPDATE employees_for_11g SET last_name = 'OConnell'
    WHERE employee_id = 198;
   COMMIT;
END;
/   

