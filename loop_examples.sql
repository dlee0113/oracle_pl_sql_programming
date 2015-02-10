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
   FOR sales_rec IN (
      SELECT *
        FROM sales_data
       WHERE year BETWEEN start_year_in AND end_year_in)
   LOOP
      display_total_sales (sales_rec.year);
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