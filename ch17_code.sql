/*
Oracle PL/SQL Programming 5th Edition

www.stevenfeuerstein.com/books

Objection creation and example scripts for Chapter 17

You will find below all non-trivial code snippets from the above chapter
that are NOT contained in their own files (as specified in the chapter),
plus any DDL object creation scripts required to get a clean compile
on the snippets.

Any references to Oracle's standard HR tables (employees, departments,
locations, regions, etc.) will NOT include the DDL creation scripts
in this file. Instead, run the hr_schema_install.sql script and all
those tables and related elements will be defined.
*/
DROP TYPE pet_t
/

CREATE OR REPLACE TYPE pet_t IS OBJECT
   (tag_no INTEGER
  , name VARCHAR2 (60)
  , breed VARCHAR2 (100)
  , dob DATE
  , MEMBER FUNCTION age
       RETURN NUMBER
   )
/

CREATE OR REPLACE TYPE BODY pet_t
IS
   MEMBER FUNCTION age
      RETURN NUMBER
   IS
   BEGIN
      RETURN SYSDATE - self.dob;
   END;
END;
/

DROP TABLE books
/

CREATE TABLE books
(
   book_id          INTEGER
 , isbn             VARCHAR2 (100)
 , title            VARCHAR2 (1000)
 , summary          VARCHAR2 (4000)
 , author           VARCHAR2 (100)
 , date_published   DATE
 , page_count       INTEGER
)
/

DROP TABLE lib_users
/

CREATE TABLE lib_users (username VARCHAR2 (100))
/

CREATE OR REPLACE PACKAGE book_info
IS
   TYPE overdue_rt IS RECORD (isbn books.isbn%TYPE, days_overdue PLS_INTEGER);

   TYPE overdue_rct IS REF CURSOR
      RETURN overdue_rt;

   FUNCTION overdue_info (username_in IN lib_users.username%TYPE)
      RETURN overdue_rct;

   FUNCTION onerow (isbn_in IN books.isbn%TYPE)
      RETURN books%ROWTYPE;
END;
/

DECLARE
   my_parrot pet_t
         := pet_t (1001
                 , 'Mercury'
                 , 'African Grey'
                 , TO_DATE ('09/23/1996', 'MM/DD/YYYY')
                  );
BEGIN
   IF my_parrot.age () < INTERVAL '50' YEAR
   THEN
      DBMS_OUTPUT.put_line ('Still a youngster!');
   END IF;
END;
/

DECLARE
   my_first_book   books%ROWTYPE;
BEGIN
   my_first_book := book_info.onerow ('1-56592-335-9');
END;
/

CREATE OR REPLACE PACKAGE hr_info_pkg
IS
   FUNCTION employee_of_the_month (month_in IN VARCHAR2)
      RETURN employees.employee_id%TYPE;
END;

DECLARE
   l_name   employees.last_name%TYPE;
BEGIN
   SELECT last_name
     INTO l_name
     FROM employees
    WHERE employee_id = hr_info_pkg.employee_of_the_month ('FEBRUARY');
END;
/

CREATE OR REPLACE FUNCTION most_reports_before_manager (
   cv_in        IN sys_refcursor
 , hire_date_in IN DATE
)
   RETURN PLS_INTEGER
IS
BEGIN
   RETURN 1;
END;
/

CREATE OR REPLACE VIEW young_managers
AS
   SELECT managers.employee_id AS manager_employee_id
     FROM employees managers
    WHERE most_reports_before_manager (
             cursor (SELECT reports.hire_date
                       FROM employees reports
                      WHERE reports.manager_id = managers.employee_id)
           , managers.hire_date
          ) = 1
/

CREATE OR REPLACE PROCEDURE combine_and_format_names (
   first_name_inout IN OUT VARCHAR2
 , last_name_inout  IN OUT VARCHAR2
 , full_name_out       OUT VARCHAR2
 , name_format_in   IN     VARCHAR2:= 'LAST, FIRST'
)
IS
BEGIN
   /* Upper-case the first and last names. */
   first_name_inout := UPPER (first_name_inout);
   last_name_inout := UPPER (last_name_inout);

   /* Combine the names as directed by the name format string. */
   IF name_format_in = 'LAST, FIRST'
   THEN
      full_name_out := last_name_inout || ', ' || first_name_inout;
   ELSIF name_format_in = 'FIRST LAST'
   THEN
      full_name_out := first_name_inout || ' ' || last_name_inout;
   END IF;
END combine_and_format_names;
/

CREATE OR REPLACE PROCEDURE astrology_reading (
   sign_in    IN VARCHAR2:= 'LIBRA'
 , born_at_in IN DATE DEFAULT SYSDATE
)
IS
BEGIN
   NULL;
END;
/

BEGIN
   astrology_reading (
      'SCORPIO'
    , TO_DATE ('12-24-2009 17:56:10', 'MM-DD-YYYY HH24:MI:SS')
   );
   astrology_reading ('SCORPIO');
   astrology_reading;
   astrology_reading ();
END;
/

BEGIN
   astrology_reading (
      born_at_in => TO_DATE ('12-24-2009 17:56:10', 'MM-DD-YYYY HH24:MI:SS')
   );
END;
/

DROP TABLE sales_descriptors
/

CREATE TABLE sales_descriptors
(
   food_sales_stg      VARCHAR2 (100)
 , service_sales_stg   VARCHAR2 (100)
 , toy_sales_stg       VARCHAR2 (100)
)
/

CREATE OR REPLACE PACKAGE sales_pkg
IS
   food_sales      NUMBER;
   service_sales   NUMBER;
   toy_sales       NUMBER;
END;
/

CREATE OR REPLACE PROCEDURE calc_percentages (total_sales_in IN NUMBER)
IS
   l_profile   sales_descriptors%ROWTYPE;

   /* Define a function right inside the procedure! */
   FUNCTION pct_stg (val_in IN NUMBER)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN TO_CHAR ( (val_in / total_sales_in) * 100, '$999,999');
   END;
BEGIN
   l_profile.food_sales_stg := pct_stg (sales_pkg.food_sales);
   l_profile.service_sales_stg := pct_stg (sales_pkg.service_sales);
   l_profile.toy_sales_stg := pct_stg (sales_pkg.toy_sales);
END;
/

DECLARE
   /* First version takes a DATE parameter. */
   FUNCTION value_ok (date_in IN DATE)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN date_in <= SYSDATE;
   END;

   /* Second version takes a NUMBER parameter. */
   FUNCTION value_ok (number_in IN NUMBER)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN number_in > 0;
   END;

   /* Third version is a procedure! */
   PROCEDURE value_ok (number_in IN NUMBER)
   IS
   BEGIN
      IF number_in > 0
      THEN
         DBMS_OUTPUT.put_line (number_in || 'is OK!');
      ELSE
         DBMS_OUTPUT.put_line (number_in || 'is not OK!');
      END IF;
   END;
BEGIN
   NULL;
END;
/

CREATE OR REPLACE PROCEDURE perform_calcs (year_in IN INTEGER)
IS
   FUNCTION total_sales (year_in IN INTEGER)
      RETURN NUMBER
   IS
   BEGIN
      RETURN 0;
   END;

   /* Header only for total_cost function. */
   FUNCTION total_cost (year_in IN INTEGER)
      RETURN NUMBER;

   /* The net_profit function uses total_cost. */
   FUNCTION net_profit (year_in IN INTEGER)
      RETURN NUMBER
   IS
   BEGIN
      RETURN total_sales (year_in) - total_cost (year_in);
   END;

   /* The total_cost function uses net_profit. */
   FUNCTION total_cost (year_in IN INTEGER)
      RETURN NUMBER
   IS
   BEGIN
      IF TRUE
      THEN
         RETURN net_profit (year_in) * .10;
      ELSE
         RETURN year_in;
      END IF;
   END;
BEGIN
   NULL;
END;
/

DROP TABLE account
/

CREATE TABLE account
(
   name         VARCHAR2 (100)
 , account_id   INTEGER
 , status       VARCHAR2 (10)
)
/

DROP TABLE orders
/

CREATE TABLE orders (account_id INTEGER, sales NUMBER, ordered_on DATE)
/

CREATE OR REPLACE FUNCTION total_sales (id_in IN account.account_id%TYPE)
   RETURN NUMBER
IS
   CURSOR tot_cur
   IS
      SELECT SUM (sales) total
        FROM orders
       WHERE account_id = id_in
             AND TO_CHAR (ordered_on, 'YYYY') = TO_CHAR (SYSDATE, 'YYYY');

   tot_rec   tot_cur%ROWTYPE;
BEGIN
   OPEN tot_cur;

   FETCH tot_cur
   INTO tot_rec;

   RETURN tot_rec.total;
END;
/

SELECT name, total_sales (account_id)
  FROM account
 WHERE status = 'ACTIVE';

/

CREATE OR REPLACE FUNCTION my_transform_fn (
   p_input_rows IN employee_info.recur_t
)
   RETURN employee_info.transformed_t
   PIPELINED
   PARALLEL_ENABLE(PARTITION p_input_rows BY ANY)
IS
BEGIN
   RETURN NULL;
END;
/

CREATE OR REPLACE FUNCTION my_transform_fn (
   p_input_rows IN employee_info.recur_t
)
   RETURN employee_info.transformed_t
   PIPELINED
   CLUSTER p_input_rows BY (department)
   PARALLEL_ENABLE(PARTITION p_input_rows BY HASH (department))
IS
BEGIN
   RETURN NULL;
END;
/

CREATE OR REPLACE FUNCTION my_transform_fn (
   p_input_rows IN employee_info.recur_t
)
   RETURN employee_info.transformed_t
   PIPELINED
   ORDER p_input_rows BY (c1)
   PARALLEL_ENABLE(PARTITION p_input_rows BY RANGE (c1))
   PARALLEL_ENABLE(PARTITION p_input_rows BY HASH (department))
IS
BEGIN
   RETURN NULL;
END;
/

CREATE OR REPLACE FUNCTION betwnstr (string_in IN VARCHAR2
                                   , start_in  IN PLS_INTEGER
                                   , end_in    IN PLS_INTEGER
                                    )
   RETURN VARCHAR2 deterministic
IS
BEGIN
   RETURN (SUBSTR (string_in, start_in, end_in - start_in + 1));
END betwnstr;
/
