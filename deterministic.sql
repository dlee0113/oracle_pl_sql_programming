SET SERVEROUTPUT ON FORMAT WRAPPED

CREATE OR REPLACE PROCEDURE pause_with_loop
IS
   i   PLS_INTEGER;
BEGIN
   FOR indx IN 1 .. 1000000
   LOOP
      i := i + 1;
   END LOOP;
END pause_with_loop;
/

CREATE OR REPLACE FUNCTION betwnstr (
   string_in   IN   VARCHAR2
 , start_in    IN   INTEGER
 , end_in      IN   INTEGER
)
   RETURN VARCHAR2
IS
BEGIN
   pause_with_loop;
   RETURN (SUBSTR (string_in, start_in, end_in - start_in + 1));
END;
/

DECLARE
   l_start   PLS_INTEGER;
BEGIN
   l_start := DBMS_UTILITY.get_time;

   FOR rec IN (SELECT betwnstr ('FEUERSTEIN', 1, 5)
                 FROM employees
                WHERE ROWNUM < 101)
   LOOP
      NULL;
   END LOOP;

   DBMS_OUTPUT.put_line (   'Non-deterministic in query elapsed: '
                         || TO_CHAR (DBMS_UTILITY.get_time - l_start)
                        );
END;
/

CREATE OR REPLACE FUNCTION betwnstr (
   string_in   IN   VARCHAR2
 , start_in    IN   INTEGER
 , end_in      IN   INTEGER
)
   RETURN VARCHAR2 DETERMINISTIC
IS
BEGIN
   pause_with_loop;
   RETURN (SUBSTR (string_in, start_in, end_in - start_in + 1));
END;
/

DECLARE
   l_start   PLS_INTEGER;
BEGIN
   l_start := DBMS_UTILITY.get_time;

   FOR rec IN (SELECT betwnstr ('FEUERSTEIN', 1, 5)
                 FROM employees
                WHERE ROWNUM < 101)
   LOOP
      NULL;
   END LOOP;

   DBMS_OUTPUT.put_line (   'Deterministic in query lapsed: '
                         || TO_CHAR (DBMS_UTILITY.get_time - l_start)
                        );
END;
/

DECLARE
   l_string   VARCHAR2 (100);
   l_start    PLS_INTEGER;
BEGIN
   l_start := DBMS_UTILITY.get_time;

   FOR rec IN (SELECT *
                 FROM employees
                WHERE ROWNUM < 101)
   LOOP
      l_string := betwnstr ('FEUERSTEIN', 1, 5);
   END LOOP;

   DBMS_OUTPUT.put_line (   'Deterministic in block elapsed: '
                         || TO_CHAR (DBMS_UTILITY.get_time - l_start)
                        );
END;
/

/* Now move BETWNSTR into a SELECT FROM DUAL -
   NO BENEFIT...so the caching is only lasting for as long as the query!
*/

DECLARE
   l_string   VARCHAR2 (100);
   l_start    PLS_INTEGER;
BEGIN
   l_start := DBMS_UTILITY.get_time;

   FOR rec IN (SELECT *
                 FROM employees
                WHERE ROWNUM < 101)
   LOOP
      SELECT betwnstr ('FEUERSTEIN', 1, 5)
        INTO l_string
        FROM DUAL;
   END LOOP;

   DBMS_OUTPUT.put_line (   'Deterministic in SELECT from DUAL elapsed: '
                         || TO_CHAR (DBMS_UTILITY.get_time - l_start)
                        );
END;
/