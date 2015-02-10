BEGIN
   dbms_result_cache.INVALIDATE (USER, 'BETWNSTR');
END;
/

CREATE OR REPLACE FUNCTION betwnstr (
   string_in   IN   VARCHAR2
 , start_in    IN   INTEGER
 , end_in      IN   INTEGER
)
   RETURN VARCHAR2 RESULT_CACHE
IS
BEGIN
   DBMS_OUTPUT.put_line (   'betwnstr for '
                         || string_in
                         || '-'
                         || start_in
                         || '-'
                         || end_in
                        );
   RETURN (SUBSTR (string_in, start_in, end_in - start_in + 1));
END;
/

DECLARE
   l_string   employees.last_name%TYPE;
BEGIN
   DBMS_RESULT_CACHE.INVALIDATE (USER, 'BETWNSTR');
   
   FOR rec IN (SELECT *
                 FROM employees
                WHERE ROWNUM < 11)
   LOOP
      l_string :=
         CASE MOD (rec.employee_id, 2)
            WHEN 0
               THEN betwnstr (rec.last_name, 1, 5)
            ELSE betwnstr ('FEUERSTEIN', 1, 5)
         END;
   END LOOP;
END;
/