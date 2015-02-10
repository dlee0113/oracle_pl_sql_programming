/*
Oracle PL/SQL Programming 5th Edition

www.stevenfeuerstein.com/books

Objection creation and example scripts for Chapter 11

You will find below all non-trivial code snippets from the above chapter
that are NOT contained in their own files (as specified in the chapter),
plus any DDL object creation scripts required to get a clean compile
on the snippets.

Any references to Oracle's standard HR tables (employees, departments,
locations, regions, etc.) will NOT include the DDL creation scripts
in this file. Instead, run the hr_schema_install.sql script and all
those tables and related elements will be defined.
*/
DROP TABLE books
/

CREATE TABLE books
(
   book_id          INTEGER
 , isbn             VARCHAR2 (13)
 , title            VARCHAR2 (200)
 , summary          VARCHAR2 (2000)
 , author           VARCHAR2 (200)
 , date_published   DATE
 , page_count       NUMBER
)
/

BEGIN
   INSERT INTO books (title, isbn
                     )
       VALUES ('Oracle PL/SQL Programming, 5th Edition', '0-596-00977-1'
              );

   COMMIT;
END;
/

DECLARE
   my_book   books%ROWTYPE;
BEGIN
   SELECT *
     INTO my_book
     FROM books
    WHERE title = 'Oracle PL/SQL Programming, 5th Edition';

   IF my_book.author LIKE '%Feuerstein%'
   THEN
      DBMS_OUTPUT.put_line ('Our newest ISBN is ' || my_book.isbn);
   END IF;
END;
/

DECLARE
   TYPE author_title_rt IS RECORD (
      author   books.author%TYPE
    , title    books.title%TYPE
   );

   l_book_info   author_title_rt;
BEGIN
   SELECT author, title
     INTO l_book_info
     FROM books
    WHERE isbn = '0-596-00977-1';
END;
/

DECLARE
   CURSOR my_books_cur
   IS
      SELECT *
        FROM books
       WHERE author LIKE '%FEUERSTEIN%';

   one_sf_book   my_books_cur%ROWTYPE;
BEGIN
   NULL;
END;
/

DECLARE
   TYPE book_info_rt IS RECORD (
      author             books.author%TYPE
    , category           VARCHAR2 (100)
    , total_page_count   POSITIVE
   );

   steven_as_author   book_info_rt;
BEGIN
   NULL;
END;
/

DROP TABLE customer
/

CREATE TABLE customer (customer_id INTEGER, name VARCHAR2 (100))
/

CREATE OR REPLACE PACKAGE customer_sales_pkg
IS
   TYPE customer_sales_rectype IS RECORD (
      customer_id     customer.customer_id%TYPE
    , customer_name   customer.name%TYPE
    , total_sales     NUMBER (15, 2)
   );
END;
/

DECLARE
   prev_customer_sales_rec   customer_sales_pkg.customer_sales_rectype;
   top_customer_rec          customer_sales_pkg.customer_sales_rectype;
BEGIN
   NULL;
END;
/

DROP TABLE company
/

CREATE TABLE company
(
   company_id     INTEGER
 , order_amount   NUMBER
 , name           VARCHAR2 (100)
)
/

DROP TABLE orders
/

CREATE TABLE orders (company_id INTEGER)
/

DECLARE
   SUBTYPE long_line_type IS VARCHAR2 (2000);

   CURSOR company_sales_cur
   IS
      SELECT name, SUM (order_amount) total_sales
        FROM company c, orders o
       WHERE c.company_id = o.company_id;

   TYPE employee_ids_tabletype IS TABLE OF employees.employee_id%TYPE
                                     INDEX BY BINARY_INTEGER;

   TYPE company_rectype IS RECORD (
      company_id      company.company_id%TYPE
    , company_name    company.name%TYPE
    , new_hires_tab   employee_ids_tabletype
   );

   TYPE company_rectype2 IS RECORD (
      company_id      company.company_id%TYPE
    , company_name    company.name%TYPE
    , new_hires_tab   employee_ids_tabletype
   );
BEGIN
   NULL;
END;
/

DROP TABLE cust_sales_roundup
/

CREATE TABLE cust_sales_roundup
(
   customer_id     NUMBER (5)
 , customer_name   VARCHAR2 (100)
 , total_sales     NUMBER (15, 2)
)
/

DECLARE
   cust_sales_roundup_rec   cust_sales_roundup%ROWTYPE;

   CURSOR cust_sales_cur
   IS
      SELECT *
        FROM cust_sales_roundup;

   cust_sales_rec           cust_sales_cur%ROWTYPE;

   TYPE customer_sales_rectype IS RECORD (
      customer_id     NUMBER (5)
    , customer_name   customer.name%TYPE
    , total_sales     NUMBER (15, 2)
   );

   preferred_cust_rec       customer_sales_rectype;
BEGIN
   -- Assign one record to another.
   cust_sales_roundup_rec := cust_sales_rec;
   preferred_cust_rec := cust_sales_rec;
END;
/

CREATE OR REPLACE PROCEDURE compare_companies (
   prev_company_rec IN company%ROWTYPE
)
IS
   curr_company_rec   company%ROWTYPE := prev_company_rec;
BEGIN
   NULL;
END;
/

DECLARE
   TYPE first_rectype IS RECORD (var1 VARCHAR2 (100):= 'WHY NOT');

   first_rec   first_rectype;

   TYPE second_rectype IS RECORD (nested_rec first_rectype:= first_rec);
BEGIN
   NULL;
END;
/

DROP TABLE rain_forest_history
/

CREATE TABLE rain_forest_history
(
   country_code    INTEGER
 , analysis_date   DATE
 , size_in_acres   NUMBER
 , species_lost    INTEGER
)
/


DECLARE
   prev_rain_forest_rec   rain_forest_history%ROWTYPE;
   curr_rain_forest_rec   rain_forest_history%ROWTYPE;
BEGIN
   -- Transfer data from previous to current records.
   curr_rain_forest_rec := prev_rain_forest_rec;
END;
/

DROP TABLE cust_sales_roundup
/

CREATE TABLE cust_sales_roundup
(
   customer_id     NUMBER (5)
 , customer_name   VARCHAR2 (100)
 , total_sales     NUMBER (15, 2)
 , sold_on         DATE
)
/

DECLARE
   /*
   || Declare a cursor and then define a record based on that cursor
   || with the %ROWTYPE attribute.
   */
   CURSOR cust_sales_cur
   IS
        SELECT customer_id, customer_name, SUM (total_sales) tot_sales
          FROM cust_sales_roundup
         WHERE sold_on < ADD_MONTHS (SYSDATE, -3)
      GROUP BY customer_id, customer_name;

   cust_sales_rec   cust_sales_cur%ROWTYPE;
BEGIN
   /* Move values directly into record by fetching from cursor */

   OPEN cust_sales_cur;

   FETCH cust_sales_cur
   INTO cust_sales_rec;
END;
/

DECLARE
   TYPE customer_sales_rectype IS RECORD (
      customer_id     customer.customer_id%TYPE
    , customer_name   customer.name%TYPE
    , total_sales     NUMBER (15, 2)
   );

   top_customer_rec   customer_sales_rectype;
BEGIN
     /* Move values directly into the record: */
     SELECT customer_id, customer_name, SUM (total_sales)
       INTO top_customer_rec
       FROM cust_sales_roundup
      WHERE sold_on < ADD_MONTHS (SYSDATE, -3)
   GROUP BY customer_id, customer_name;
END;
/

DECLARE
   rain_forest_rec   rain_forest_history%ROWTYPE;
BEGIN
   /* Set values for the record */
   rain_forest_rec.country_code := 1005;
   rain_forest_rec.analysis_date := ADD_MONTHS (TRUNC (SYSDATE), -3);
   rain_forest_rec.size_in_acres := 32;
   rain_forest_rec.species_lost := 425;

   /* Insert a row in the table using the record values */
   INSERT INTO rain_forest_history (
                                       country_code
                                     , analysis_date
                                     , size_in_acres
                                     , species_lost
              )
       VALUES (
                  rain_forest_rec.country_code
                , rain_forest_rec.analysis_date
                , rain_forest_rec.size_in_acres
                , rain_forest_rec.species_lost
              );
END;
/

DECLARE
   TYPE phone_rectype IS RECORD (
      intl_prefix   VARCHAR2 (2)
    , area_code     VARCHAR2 (3)
    , exchange      VARCHAR2 (3)
    , phn_number    VARCHAR2 (4)
    , extension     VARCHAR2 (4)
   );

   -- Each field is a nested record...
   TYPE contact_set_rectype IS RECORD (
      day_phone#    phone_rectype
    , eve_phone#    phone_rectype
    , fax_phone#    phone_rectype
    , home_phone#   phone_rectype
    , cell_phone#   phone_rectype
   );

   auth_rep_info_rec   contact_set_rectype;
BEGIN
   auth_rep_info_rec.fax_phone#.area_code :=
      auth_rep_info_rec.home_phone#.area_code;
END;
/

CREATE OR REPLACE PACKAGE summer
IS
   TYPE reading_list_rt IS RECORD (
      favorite_author   VARCHAR2 (100)
    , title             VARCHAR2 (100)
    , finish_by         DATE
   );

   must_read        reading_list_rt;
   wifes_favorite   reading_list_rt;
END summer;
/

CREATE OR REPLACE PACKAGE BODY summer
IS
BEGIN                                     -- Initialization section of package
   must_read.favorite_author := 'Tepper, Sheri S.';
   must_read.title := 'Gate to Women''s Country';
END summer;
/

CREATE OR REPLACE PROCEDURE lots_to_talk_about
IS
BEGIN
   NULL;
END;
/

DECLARE
   first_book    summer.reading_list_rt;
   second_book   summer.reading_list_rt;
BEGIN
   summer.must_read.finish_by := TO_DATE ('01-AUG-2009', 'DD-MON-YYYY');
   first_book := summer.must_read;

   second_book.favorite_author := 'Hobb, Robin';
   second_book.title := 'Assassin''s Apprentice';
   second_book.finish_by := TO_DATE ('01-SEP-2009', 'DD-MON-YYYY');
END;
/

DECLARE
   first_book    summer.reading_list_rt := summer.must_read;
   second_book   summer.reading_list_rt := summer.wifes_favorite;
BEGIN
   IF     first_book.favorite_author = second_book.favorite_author
      AND first_book.title = second_book.title
      AND first_book.finish_by = second_book.finish_by
   THEN
      lots_to_talk_about;
   END IF;
END;
/