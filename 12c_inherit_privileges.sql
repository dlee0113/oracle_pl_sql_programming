/* Demonstrate that without INHERIT PRIVILEGES
   CURRENT_USER will not give access to invoker
   privileges. */

CONNECT hr/hr

CREATE TABLE c12_emps
(
   employee_id     INTEGER,
   department_id   INTEGER,
   last_name       VARCHAR2 (100)
)
/

BEGIN
   INSERT INTO c12_emps
        VALUES (1, 100, 'abc');

   COMMIT;
END;
/

CREATE OR REPLACE FUNCTION emps_count (
   department_id_in IN INTEGER)
   RETURN PLS_INTEGER
   AUTHID CURRENT_USER
IS
   l_count   PLS_INTEGER;
BEGIN
   SELECT COUNT (*)
     INTO l_count
     FROM c12_emps
    WHERE department_id = department_id_in;

   RETURN l_count;
END;
/

GRANT EXECUTE ON emps_count TO scott
/

CONNECT scott/tiger

SET SERVEROUTPUT ON

CREATE TABLE c12_emps
(
   employee_id     INTEGER,
   department_id   INTEGER,
   last_name       VARCHAR2 (100)
)
/

BEGIN
   INSERT INTO c12_emps
        VALUES (1, 200, 'SCOTT.ABC');

   COMMIT;
END;
/

BEGIN
   DBMS_OUTPUT.put_line (hr.emps_count (200));
END;
/

/* Now revoke inherit privs and try again. */

CONNECT SYS/sys as sysdba

REVOKE INHERIT PRIVILEGES ON USER hr FROM scott
/

BEGIN
   DBMS_OUTPUT.put_line (hr.emps_count (200));
END;
/

/* Clean up */

DROP TABLE c12_emps
/

CONNECT hr/hr

DROP FUNCTION emps_count
/

DROP TABLE c12_emps
/

DROP VIEW emp_counts_v
/

SPOOL OFF