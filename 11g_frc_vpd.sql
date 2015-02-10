/*
Let's examine the impact of fine-grained access or 
virtual private database on the result cache.
*/

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
   FUNCTION last_name (employee_id_in IN employees_for_11g.employee_id%TYPE)
      RETURN employees_for_11g.last_name%TYPE
      result_cache;   
   
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

/*
First demonstrate basic effect of VPD.
*/

CONNECT hr/hr@oracle11

SELECT last_name
  FROM employees_for_11g
 WHERE employee_id = 198
/

CONNECT scott/tiger@oracle11

SELECT last_name
  FROM hr.employees_for_11g
 WHERE employee_id = 198
/

CONNECT hr/hr@oracle11

SET SERVEROUTPUT ON

BEGIN
   /* Should see OConnell */
   DBMS_OUTPUT.put_line (emplu11g.last_name (198));
END;
/

CONNECT scott/tiger@oracle11

SET SERVEROUTPUT ON

BEGIN
   /* Should raise NO_DATA_FOUND but instead.... */
   DBMS_OUTPUT.put_line (hr.emplu11g.last_name (198));
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
   DBMS_OUTPUT.put_line (hr.emplu11g.last_name (198));
END;
/