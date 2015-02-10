/* Fetch First for Bulk Collect */

DECLARE
   TYPE employees_t IS TABLE OF employees%ROWTYPE;

   l_employees   employees_t;
BEGIN
        -- All rows at once...
        SELECT *
          BULK COLLECT INTO l_employees
          FROM employees
      ORDER BY last_name DESC
   FETCH FIRST 10 ROWS ONLY;

   DBMS_OUTPUT.put_line (l_employees.COUNT);

   FOR indx IN 1 .. l_employees.COUNT
   LOOP
      DBMS_OUTPUT.put_line (l_employees (indx).last_name);
   END LOOP;
END;
/

/* Watch out! In 12.1 we have bug 17404511:
   Cannot use a variable.... 
   
   Crash....
   
   ORA-03113: end-of-file on communication channel
*/

DECLARE
   TYPE employees_t IS TABLE OF employees%ROWTYPE;

   l_employees   employees_t;

   l_limit       NUMBER := 10;
BEGIN
        -- All rows at once...
        SELECT *
          BULK COLLECT INTO l_employees
          FROM employees
      ORDER BY last_name DESC
   FETCH FIRST l_limit ROWS ONLY;

   DBMS_OUTPUT.put_line (l_employees.COUNT);
END;
/