CONNECT HR/HR

CREATE TABLE c12_emps
(
   employee_id     INTEGER,
   department_id   INTEGER,
   last_name       VARCHAR2 (100)
)
/

CREATE OR REPLACE FUNCTION c12_name_for_id (id_in IN INTEGER)
   RETURN c12_emps.last_name%TYPE
   AUTHID CURRENT_USER
   RESULT_CACHE
IS
   l_return   c12_emps.last_name%TYPE;
BEGIN
   SELECT last_name
     INTO l_return
     FROM c12_emps
    WHERE employee_id = id_in;

   RETURN l_return;
END;
/

GRANT EXECUTE ON c12_name_for_id TO scott
/

BEGIN
   DBMS_OUTPUT.put_line (
      'HR Name for 3=' || c12_name_for_id (3));
END;
/

CONNECT scott/tiger

SET SERVEROUTPUT ON FORMAT WRAPPED

CREATE TABLE c12_emps
(
   employee_id     INTEGER,
   department_id   INTEGER,
   last_name       VARCHAR2 (100)
)
/

BEGIN
   INSERT INTO c12_emps
        VALUES (1, 100, 'Mondrian');

   INSERT INTO c12_emps
        VALUES (2, 100, 'Picasso');

   INSERT INTO c12_emps
        VALUES (3, 200, 'Cassatt');

   COMMIT;
END;
/

BEGIN
   DBMS_OUTPUT.put_line (
      'SCOTT Name for 3=' || HR.c12_name_for_id (3));
END;
/

/* Clean up */

DROP TABLE c12_emps
/

CONNECT hr/hr

DROP TABLE c12_emps
/

DROP FUNCTION c12_name_for_id
/