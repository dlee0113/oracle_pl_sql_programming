DECLARE
   l_cursor     NUMBER;
   l_feedback   NUMBER;

   PROCEDURE set_salary
   IS
   BEGIN
      DBMS_OUTPUT.put_line ('Set salary = salary...');
      l_cursor := DBMS_SQL.open_cursor ();
      DBMS_SQL.parse (l_cursor
                    , 'update employees set salary = salary'
                    , DBMS_SQL.native
                     );
      l_feedback := DBMS_SQL.EXECUTE (l_cursor);
      DBMS_OUTPUT.put_line ('   Rows modified = ' || l_feedback);
      DBMS_SQL.close_cursor (l_cursor);
   END set_salary;
BEGIN
   set_salary ();

   BEGIN
      l_feedback := DBMS_SQL.EXECUTE (1010101010);
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line (DBMS_UTILITY.format_error_stack ());
         DBMS_OUTPUT.put_line (DBMS_UTILITY.format_error_backtrace ());
   END;

   set_salary ();
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (DBMS_UTILITY.format_error_stack ());
      DBMS_OUTPUT.put_line (DBMS_UTILITY.format_error_backtrace ());
END;