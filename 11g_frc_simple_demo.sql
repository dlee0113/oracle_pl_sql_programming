CREATE OR REPLACE FUNCTION betwnstr (
   string_in IN varchar2, start_in IN integer, end_in  IN integer)
   RETURN varchar2 RESULT_CACHE
IS
BEGIN
   DBMS_OUTPUT.put_line (
      'betwnstr for ' || string_in || '-' || start_in || '-' || end_in);
   RETURN (SUBSTR (string_in, start_in, end_in - start_in + 1));
END;
/

DECLARE
   l_string   employees.last_name%TYPE;
BEGIN
   FOR rec IN (SELECT *
                 FROM employees
                WHERE ROWNUM < 11)
   LOOP
      l_string :=
         CASE MOD (rec.employee_id, 2)
            WHEN 0 THEN betwnstr (rec.last_name, 1, 5)
            ELSE betwnstr ('FEUERSTEIN', 1, 5)
         END;
   END LOOP;
END;
/