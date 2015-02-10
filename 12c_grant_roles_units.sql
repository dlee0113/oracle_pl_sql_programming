SPOOL 12c_grant_roles_units.log

CONNECT system/Oracle12c

CREATE USER hr IDENTIFIED BY pwd
/

GRANT CREATE SESSION TO hr
/

GRANT CREATE PROCEDURE TO hr
/

GRANT CREATE TABLE TO hr
/

GRANT UNLIMITED TABLESPACE TO hr
/

CREATE USER scott IDENTIFIED BY pwd
/

GRANT CREATE SESSION TO scott
/

GRANT CREATE PROCEDURE TO scott
/

GRANT CREATE TABLE TO scott
/

GRANT UNLIMITED TABLESPACE TO scott
/

CONNECT hr/pwd

CREATE TABLE departments
(
   department_id     INTEGER,
   department_name   VARCHAR2 (100),
   staff_freeze      CHAR (1)
)
/

BEGIN
   INSERT INTO departments
        VALUES (10, 'IT', 'Y');

   INSERT INTO departments
        VALUES (20, 'HR', 'N');

   COMMIT;
END;
/

CREATE TABLE employees
(
   employee_id     INTEGER,
   department_id   INTEGER,
   last_name       VARCHAR2 (100)
)
/

BEGIN
   DELETE FROM employees;

   INSERT INTO employees
        VALUES (100, 10, 'Price');

   INSERT INTO employees
        VALUES (101, 20, 'Sam');

   INSERT INTO employees
        VALUES (102, 20, 'Joseph');

   INSERT INTO employees
        VALUES (103, 20, 'Smith');

   COMMIT;
END;
/

CONNECT scott/pwd

CREATE TABLE employees
(
   employee_id     INTEGER,
   department_id   INTEGER,
   last_name       VARCHAR2 (100)
)
/

BEGIN
   DELETE FROM employees;

   INSERT INTO employees
        VALUES (100, 10, 'Price');

   INSERT INTO employees
        VALUES (104, 20, 'Lakshmi');

   INSERT INTO employees
        VALUES (105, 20, 'Silva');

   INSERT INTO employees
        VALUES (106, 20, 'Ling');

   COMMIT;
END;
/

CONNECT hr/pwd

/* First with definer rights */

CREATE OR REPLACE PROCEDURE remove_emps_in_dept (
   department_id_in IN employees.department_id%TYPE)
   AUTHID DEFINER
IS
   l_freeze   departments.staff_freeze%TYPE;
BEGIN
   SELECT staff_freeze
     INTO l_freeze
     FROM hr.departments
    WHERE department_id = department_id_in;

   IF l_freeze = 'N'
   THEN
      DELETE FROM employees
            WHERE department_id =
                     department_id_in;

      DBMS_OUTPUT.put_line (
         'Rows deleted=' || SQL%ROWCOUNT);
   END IF;
END;
/

GRANT EXECUTE
   ON remove_emps_in_dept
   TO scott
/

CONNECT scott/pwd

SET SERVEROUTPUT ON

SELECT COUNT (*)
  FROM employees
 WHERE department_id = 20
/

/* No error, but no rows removed from Scott's employees table. */

BEGIN
   hr.remove_emps_in_dept (20);
END;
/

SELECT COUNT (*)
  FROM employees
 WHERE department_id = 20
/

ROLLBACK
/

/* Now try invoker rights */

CONNECT hr/pwd

CREATE OR REPLACE PROCEDURE remove_emps_in_dept (
   department_id_in IN employees.department_id%TYPE)
   AUTHID CURRENT_USER
IS
   l_freeze   departments.staff_freeze%TYPE;
BEGIN
   SELECT staff_freeze
     INTO l_freeze
     FROM hr.departments
    WHERE department_id = department_id_in;

   IF l_freeze = 'N'
   THEN
      DELETE FROM employees
            WHERE department_id =
                     department_id_in;

      DBMS_OUTPUT.put_line (
         'Rows deleted=' || SQL%ROWCOUNT);
   END IF;
END;
/

GRANT EXECUTE
   ON remove_emps_in_dept
   TO scott
/

CONNECT scott/pwd

SET SERVEROUTPUT ON

SELECT COUNT (*)
  FROM employees
 WHERE department_id = 20
/

BEGIN
   hr.remove_emps_in_dept (20);
END;
/

/*
ERROR at line 1:
ORA-00942: table or view does not exist
ORA-06512: at "hr.REMOVE_EMPS_IN_DEPT", line 7
ORA-06512: at line 2
*/

/* Now let's use the new feature! 

   Create a role, grant select on the departments to it,
   then grant that role to the procedure.
*/

CONNECT system/Oracle12c

CREATE ROLE hr_departments
/

GRANT hr_departments TO hr
/

CONNECT hr/pwd

GRANT SELECT
   ON departments
   TO hr_departments
/

GRANT hr_departments TO procedure remove_emps_in_dept
/

CONNECT scott/pwd

SET SERVEROUTPUT ON

SELECT COUNT (*)
  FROM employees
 WHERE department_id = 20
/

/* Should execute without error - AND remove the rows. */

BEGIN
   hr.remove_emps_in_dept (20);
END;
/

SELECT COUNT (*)
  FROM employees
 WHERE department_id = 20
/

ROLLBACK
/

/* Clean up */


CONNECT system/pwd

DROP ROLE hr_departments
/

DROP USER hr CASCADE
/

DROP USER scott CASCADE
/

SPOOL OFF