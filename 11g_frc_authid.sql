CONNECT hr/hr@oracle11

DROP PACKAGE emplu11g
/

DROP TABLE employees_for_11g
/
CREATE TABLE employees_for_11g
AS SELECT * FROM employees
/

GRANT SELECT ON employees TO scott
/

CREATE OR REPLACE PACKAGE emplu11g AUTHID CURRENT_USER
IS
   FUNCTION last_name (employee_id_in IN employees_for_11g.employee_id%TYPE)
      RETURN employees_for_11g.last_name%TYPE
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
END;
/

GRANT EXECUTE ON emplu11g TO scott
/

CONNECT scott/tiger@oracle11

DROP TABLE employees_for_11g
/
CREATE TABLE employees_for_11g
AS SELECT * FROM employees WHERE 1 = 2
/

SET SERVEROUTPUT ON

BEGIN
   /* Should raise NO_DATA_FOUND since nothing is cached yet. */
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

