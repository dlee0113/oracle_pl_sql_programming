DROP TABLE sales_data
/

CREATE TABLE sales_data (year INTEGER, sales_amount NUMBER)
/

CREATE OR REPLACE PROCEDURE display_total_sales (year_in IN PLS_INTEGER)
IS
BEGIN
   DBMS_OUTPUT.put_line ('Total for year ' || year_in);
END display_total_sales;
/

CREATE OR REPLACE PROCEDURE display_multiple_years (
   start_year_in IN PLS_INTEGER
 , end_year_in   IN PLS_INTEGER
)
IS
   l_current_year   PLS_INTEGER := start_year_in;
BEGIN
   LOOP
      EXIT WHEN l_current_year > end_year_in;
      display_total_sales (l_current_year);
      l_current_year := l_current_year + 1;
   END LOOP;
END display_multiple_years;
/

CREATE OR REPLACE PROCEDURE display_multiple_years (
   start_year_in IN PLS_INTEGER
 , end_year_in   IN PLS_INTEGER
)
IS
BEGIN
   FOR l_current_year IN start_year_in .. end_year_in
   LOOP
      display_total_sales (l_current_year);
   END LOOP;
END display_multiple_years;
/

CREATE OR REPLACE PROCEDURE display_multiple_years (
   start_year_in IN PLS_INTEGER
 , end_year_in   IN PLS_INTEGER
)
IS
BEGIN
   FOR l_current_year IN (SELECT *
                            FROM sales_data
                           WHERE year BETWEEN start_year_in AND end_year_in)
   LOOP
      -- This procedure is now accepted a record implicitly declared
      -- to be of type sales_data%ROWTYPE...
      display_total_sales (l_current_year.year);
   END LOOP;
END display_multiple_years;
/

CREATE OR REPLACE PROCEDURE display_multiple_years (
   start_year_in IN PLS_INTEGER
 , end_year_in   IN PLS_INTEGER
)
IS
   l_current_year   PLS_INTEGER := start_year_in;
BEGIN
   WHILE (l_current_year <= end_year_in)
   LOOP
      display_total_sales (l_current_year);
      l_current_year := l_current_year + 1;
   END LOOP;
END display_multiple_years;
/



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/