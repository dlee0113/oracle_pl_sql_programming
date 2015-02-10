DECLARE
   cur INTEGER := DBMS_SQL.open_cursor;
   tab DBMS_SQL.desc_tab;
BEGIN
   DBMS_SQL.parse ( cur
                  , 'SELECT last_name, salary, hire_date FROM employees'
                  , DBMS_SQL.native
                  );
   tab := desccols.for_cursor ( cur );
   desccols.show_columns ( tab );
   DBMS_SQL.close_cursor ( cur );
   --
   tab := desccols.for_query ( 'SELECT * FROM employees' );
   desccols.show_columns ( tab );
   --
   tab := desccols.for_query ( 'SELECT LAST_NAME ||'',''||FIRSt_NAME abc FROM employees' );
   desccols.show_columns ( tab );   
END;
/
