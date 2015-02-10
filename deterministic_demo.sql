SET SERVEROUTPUT ON FORMAT WRAPPED

CREATE OR REPLACE FUNCTION betwnstr (
   string_in   IN   VARCHAR2
 , start_in    IN   INTEGER
 , end_in      IN   INTEGER
)
   RETURN VARCHAR2
IS
BEGIN
   DBMS_LOCK.sleep (.01);
   RETURN (SUBSTR (string_in, start_in, end_in - start_in + 1));
END;
/

BEGIN
   sf_timer.start_timer;

   FOR rec IN (SELECT betwnstr ('FEUERSTEIN', 1, 5)
                 FROM employees)
   LOOP
      NULL;
   END LOOP;

   sf_timer.show_elapsed_time ('Non-deterministic function in query');
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
   DBMS_LOCK.sleep (.01);
   RETURN (SUBSTR (string_in, start_in, end_in - start_in + 1));
END;
/

BEGIN
   sf_timer.start_timer;

   FOR rec IN (SELECT betwnstr ('FEUERSTEIN', 1, 5)
                 FROM employees)
   LOOP
      NULL;
   END LOOP;

   sf_timer.show_elapsed_time ('Deterministic function in query');
END;
/

DECLARE
   l_string   employees.last_name%TYPE;
BEGIN
   sf_timer.start_timer;

   FOR rec IN (SELECT *
                 FROM employees)
   LOOP
      l_string := betwnstr ('FEUERSTEIN', 1, 5);
   END LOOP;

   sf_timer.show_elapsed_time ('Deterministic function in block');
END;
/

CREATE OR REPLACE FUNCTION betwnstr (
   string_in   IN   VARCHAR2
 , start_in    IN   INTEGER
 , end_in      IN   INTEGER
)
   RETURN VARCHAR2 DETERMINISTIC RESULT_CACHE
IS
BEGIN
   DBMS_LOCK.sleep (.01);
   RETURN (SUBSTR (string_in, start_in, end_in - start_in + 1));
END;
/

DECLARE
   l_string   employees.last_name%TYPE;
BEGIN
   sf_timer.start_timer;

   FOR rec IN (SELECT *
                 FROM employees)
   LOOP
      l_string := betwnstr ('FEUERSTEIN', 1, 5);
   END LOOP;

   sf_timer.show_elapsed_time ('Result cache function in block');
END;
/