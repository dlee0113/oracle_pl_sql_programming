/*
Oracle PL/SQL Programming 5th Edition

www.stevenfeuerstein.com/books

Objection creation and example scripts for Chapter 7

You will find below all non-trivial code snippets from the above chapter
that are NOT contained in their own files (as specified in the chapter),
plus any DDL object creation scripts required to get a clean compile
on the snippets.

Any references to Oracle's standard HR tables (employees, departments,
locations, regions, etc.) will NOT include the DDL creation scripts
in this file. Instead, run the hr_schema_install.sql script and all
those tables and related elements will be defined.
*/

DECLARE
   "truly_lower_case"   INTEGER;
   "     "              DATE;        -- Yes, a name consisting of five spaces!
   "123_go!"            VARCHAR2 (10);
BEGIN
   "123_go!" := 'Steven';
END;
/

DROP TABLE book
/

CREATE TABLE book
(
   id       NUMBER
 , isbn     VARCHAR2 (100)
 , author   VARCHAR2 (100)
 , title    VARCHAR2 (1000)
)
/

DECLARE
   -- Simple declaration of numeric variable
   l_total_count          NUMBER;

   -- Declaration of number that rounds to nearest hundredth (cent):
   l_dollar_amount        NUMBER (10, 2);

   -- A single datetime value, assigned a default value of the database server's
   -- system clock. Also, it can never be NULL
   l_right_now            DATE NOT NULL DEFAULT SYSDATE;

   -- Using the assignment operator for the default value specification
   l_favorite_flavor      VARCHAR2 (100) := 'Anything with chocolate, actually';

   -- Two-step declaration process for associative array.
   -- First, the type of table:
   TYPE list_of_books_t IS TABLE OF book%ROWTYPE
                              INDEX BY BINARY_INTEGER;

   -- And now the specific list to be manipulated in this block:
   oreilly_oracle_books   list_of_books_t;
BEGIN
   NULL;
END;
/

CREATE OR REPLACE TYPE person_ot IS OBJECT
   (species VARCHAR2 (100), name VARCHAR2 (100), weight NUMBER, dob DATE);
/

DECLARE
   -- The current year number; it's not going to change during my session.
   l_curr_year CONSTANT PLS_INTEGER
         := TO_NUMBER (TO_CHAR (SYSDATE, 'YYYY')) ;

   -- Using the DEFAULT keyword
   l_author   CONSTANT VARCHAR2 (100) DEFAULT 'Bill Pribyl';

   -- Declare a complex datatype as a constant
   -- this isn't just for scalars!
   l_steven CONSTANT person_ot
         := person_ot ('HUMAN'
                     , 'Steven Feuerstein'
                     , 175
                     , TO_DATE ('09-23-1958', 'MM-DD-YYYY')
                      ) ;
BEGIN
   NULL;
END;
/

CREATE OR REPLACE PROCEDURE process_book (book_in IN book%ROWTYPE)
IS
BEGIN
   NULL;
END;
/

DECLARE
   l_book   book%ROWTYPE;
BEGIN
   SELECT *
     INTO l_book
     FROM book
    WHERE isbn = '1-56592-335-9';

   process_book (l_book);
END;
/

DECLARE
   CURSOR book_cur
   IS
      SELECT author, title
        FROM book
       WHERE isbn = '1-56592-335-9';

   l_book   book_cur%ROWTYPE;
BEGIN
   OPEN book_cur;

   FETCH book_cur
   INTO l_book;
END;
/

BEGIN
   FOR book_rec IN (SELECT *
                      FROM book)
   LOOP
      process_book (book_rec);
   END LOOP;
END;
/

CREATE OR REPLACE PACKAGE utility
AS
   SUBTYPE big_string IS VARCHAR2 (32767);

   SUBTYPE big_db_string IS VARCHAR2 (4000);
END utility;
/

DECLARE
   a_number   NUMBER;
BEGIN
   a_number := '125';
END;
/

DECLARE
   hd_display   VARCHAR2 (30);
BEGIN
   hd_display := CAST (SYSDATE AS varchar2);
END;
/