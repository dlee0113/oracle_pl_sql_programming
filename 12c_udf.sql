SET TIMING ON

CREATE OR REPLACE FUNCTION udf_function (n IN NUMBER)
   RETURN VARCHAR2
IS
   $IF $$include_udf
   $THEN
      PRAGMA UDF;
   $END
BEGIN
   RETURN TO_CHAR (n);
END;
/

DECLARE
   l_string   VARCHAR2 (32767);
   l_start    PLS_INTEGER;

   PROCEDURE mark_start
   IS
   BEGIN
      l_start := DBMS_UTILITY.get_cpu_time;
   END mark_start;

   PROCEDURE show_elapsed (NAME_IN IN VARCHAR2)
   IS
   BEGIN
      DBMS_OUTPUT.put_line (
            '"'
         || NAME_IN
         || '" elapsed CPU time: '
         || TO_CHAR ( (DBMS_UTILITY.get_cpu_time - l_start) / 100)
         || ' seconds');
   END show_elapsed;
BEGIN
   mark_start;

   FOR indx IN 1 .. 10000
   LOOP
      SELECT udf_function (indx) INTO l_string FROM sys.DUAL;
   END LOOP;

   show_elapsed ('Without UDF');
END;
/

/* In "straight" SQL */

SELECT COUNT (*)
  FROM employees e1, employees e2, employees e3
 WHERE    udf_function (e1.employee_id) > 0
       OR udf_function (e2.employee_id) > 0
       OR udf_function (e3.employee_id) > 0
/

ALTER SESSION SET plsql_ccflags='include_udf:true'
/

ALTER FUNCTION udf_function
COMPILE
/

DECLARE
   l_string   VARCHAR2 (32767);
   l_start    PLS_INTEGER;

   PROCEDURE mark_start
   IS
   BEGIN
      l_start := DBMS_UTILITY.get_cpu_time;
   END mark_start;

   PROCEDURE show_elapsed (NAME_IN IN VARCHAR2)
   IS
   BEGIN
      DBMS_OUTPUT.put_line (
            '"'
         || NAME_IN
         || '" elapsed CPU time: '
         || TO_CHAR ( (DBMS_UTILITY.get_cpu_time - l_start) / 100)
         || ' seconds');
   END show_elapsed;
BEGIN
   mark_start;

   FOR indx IN 1 .. 10000
   LOOP
      SELECT udf_function (indx) INTO l_string FROM sys.DUAL;
   END LOOP;

   show_elapsed ('With UDF');
END;
/

/* In "straight" SQL */

SELECT COUNT (*)
  FROM employees e1, employees e2, employees e3
 WHERE    udf_function (e1.employee_id) > 0
       OR udf_function (e2.employee_id) > 0
       OR udf_function (e3.employee_id) > 0
/