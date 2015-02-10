/* Grant roles to program units! */

CONNECT system/Oracle12c

CREATE ROLE just_employees_rl
/

GRANT SELECT ON employees TO just_employees_rl
/

CREATE OR REPLACE PROCEDURE show_employees
   AUTHID CURRENT_USER
IS
BEGIN
   FOR rec IN (SELECT * FROM employees)
   LOOP
      DBMS_OUTPUT.put_line (rec.last_name);
   END LOOP;
END;
/

GRANT just_employees_rl TO procedure show_employees
/