/* Function calls view... */

SPOOL bequeath.log

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

   INSERT INTO c12_emps
        VALUES (2, 100, 'def');

   INSERT INTO c12_emps
        VALUES (3, 200, '123');

   COMMIT;
END;
/

CREATE OR REPLACE FUNCTION emps_count (
   department_id_in   IN INTEGER)
   RETURN PLS_INTEGER
   AUTHID CURRENT_USER
IS
   l_count    PLS_INTEGER;
   l_user     VARCHAR2 (100);
   l_userid   VARCHAR2 (100);
BEGIN
   SELECT COUNT (*)
     INTO l_count
     FROM c12_emps
    WHERE department_id = department_id_in;

   /* Show who is invoking the function */
   SELECT ora_invoking_user INTO l_user FROM DUAL;

   SELECT ora_invoking_userid INTO l_userid FROM DUAL;

   DBMS_OUTPUT.put_line (l_user);
   DBMS_OUTPUT.put_line (l_userid);

   RETURN l_count;
END;
/

SHOW ERRORS

CREATE OR REPLACE VIEW emp_counts_v   
   BEQUEATH CURRENT_USER
AS
   SELECT department_id, emps_count (department_id) emps_in_dept
     FROM c12_emps
/

GRANT SELECT ON emp_counts_v TO scott
/

SET SERVEROUTPUT ON

SELECT * FROM hr.emp_counts_v
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

   INSERT INTO c12_emps
        VALUES (2, 200, 'SCOTT.DEF');

   INSERT INTO c12_emps
        VALUES (3, 400, 'SCOTT.123');

   COMMIT;
END;
/

SELECT * FROM hr.emp_counts_v
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