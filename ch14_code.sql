/*
Oracle PL/SQL Programming 5th Edition

www.stevenfeuerstein.com/books

Objection creation and example scripts for Chapter 14

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
 , isbn             VARCHAR2 (100)
 , title            VARCHAR2 (1000)
 , summary          VARCHAR2 (4000)
 , author           VARCHAR2 (100)
 , date_published   DATE
 , page_count       INTEGER
)
/

CREATE SEQUENCE book_id_sequence
/

BEGIN
   INSERT INTO books (
                         book_id
                       , isbn
                       , title
                       , summary
                       , author
                       , date_published
                       , page_count
              )
       VALUES (
                  100
                , '1-56592-335-9'
                , 'Oracle PL/SQL Programming'
                ,    'Reference for PL/SQL developers,'
                  || 'including examples and best practice '
                  || 'recommendations.'
                , 'Feuerstein,Steven, with Bill Pribyl'
                , TO_DATE ('01-SEP-1997', 'DD-MON-YYYY')
                , 987
              );

   COMMIT;
END;
/

DECLARE
   l_isbn   books.isbn%TYPE := '1-56592-335-9';
   l_book   books%ROWTYPE;
BEGIN
   INSERT INTO books (
                         book_id
                       , isbn
                       , title
                       , summary
                       , author
                       , date_published
                       , page_count
              )
       VALUES (
                  book_id_sequence.NEXTVAL
                , l_isbn
                , l_book.title
                , l_book.summary
                , l_book.author
                , l_book.date_published
                , l_book.page_count
              );
END;
/

CREATE OR REPLACE PROCEDURE remove_time (author_in IN VARCHAR2)
IS
BEGIN
   UPDATE books
      SET title = UPPER (title), date_published = TRUNC (date_published)
    WHERE author LIKE author_in;
END;
/

CREATE OR REPLACE PROCEDURE remove_books (date_in           IN     DATE
                                        , removal_count_out    OUT PLS_INTEGER
                                         )
IS
BEGIN
   DELETE FROM books
         WHERE date_published < date_in;

   removal_count_out := sql%ROWCOUNT;
END;
/

DROP TABLE bonuses
/

CREATE TABLE bonuses (employee_id NUMBER, bonus NUMBER DEFAULT 100)
/

REM Initial bonuses of 20%, incremental bonuses 10%

CREATE OR REPLACE PROCEDURE time_use_merge (
   dept_in IN employees.department_id%TYPE
)
IS
BEGIN
   MERGE INTO bonuses d
        USING (SELECT employee_id, salary, department_id
                 FROM employees
                WHERE department_id = dept_in) s
           ON (d.employee_id = s.employee_id)
   WHEN MATCHED
   THEN
      UPDATE SET d.bonus = d.bonus + s.salary * .01
   WHEN NOT MATCHED
   THEN
      INSERT            (d.employee_id, d.bonus
                        )
          VALUES (s.employee_id, s.salary * 0.2
                 );
END;
/

CREATE OR REPLACE PROCEDURE change_author_name (
   old_name_in      IN     books.author%TYPE
 , new_name_in      IN     books.author%TYPE
 , changes_made_out    OUT BOOLEAN
)
IS
BEGIN
   UPDATE books
      SET author = new_name_in
    WHERE author = old_name_in;

   changes_made_out := sql%FOUND;
END;
/

CREATE OR REPLACE PROCEDURE change_author_name (
   old_name_in      IN     books.author%TYPE
 , new_name_in      IN     books.author%TYPE
 , rename_count_out    OUT PLS_INTEGER
)
IS
BEGIN
   UPDATE books
      SET author = new_name_in
    WHERE author = old_name_in;

   rename_count_out := sql%ROWCOUNT;
END;
/

DECLARE
   myname   employees.last_name%TYPE;
   mysal    employees.salary%TYPE;
BEGIN
   ROLLBACK;

   FOR rec IN (SELECT *
                 FROM employees)
   LOOP
         UPDATE employees
            SET salary = salary * 1.5
          WHERE employee_id = rec.employee_id
      RETURNING salary, last_name
           INTO mysal, myname;

      DBMS_OUTPUT.put_line ('New salary for ' || myname || ' = ' || mysal);
   END LOOP;

   ROLLBACK;
END;
/

CREATE OR REPLACE TYPE name_varray IS VARRAY (10) OF VARCHAR2 (100)
/

CREATE OR REPLACE TYPE number_varray IS VARRAY (10) OF NUMBER
/

CREATE TABLE compensation (last_name VARCHAR2 (100), salary NUMBER)
/

DECLARE
   names          name_varray;
   new_salaries   number_varray;
BEGIN
   populate_arrays (names, new_salaries);

   FORALL indx IN names.FIRST .. names.LAST
                 UPDATE compensation
                    SET salary = new_salaries (indx)
                  WHERE last_name = names (indx)
              RETURNING salary
      BULK COLLECT INTO new_salaries;

   ROLLBACK;
END;
/

CREATE OR REPLACE FUNCTION tabcount
   RETURN PLS_INTEGER
IS
   l_return   PLS_INTEGER;
BEGIN
   SELECT COUNT ( * )
     INTO l_return
     FROM books;

   RETURN l_return;
END tabcount;
/

CREATE OR REPLACE PROCEDURE empty_library (pre_empty_count OUT PLS_INTEGER)
IS
BEGIN
   pre_empty_count := tabcount ();

   DELETE FROM books;

   RAISE NO_DATA_FOUND;
END;
/

DECLARE
   table_count   NUMBER := -1;
   l_isbn        books.isbn%TYPE := '1-56592-335-9';
   l_book        books%ROWTYPE;
BEGIN
   INSERT INTO books (
                         book_id
                       , isbn
                       , title
                       , summary
                       , author
                       , date_published
                       , page_count
              )
       VALUES (
                  book_id_sequence.NEXTVAL
                , l_isbn
                , l_book.title
                , l_book.summary
                , l_book.author
                , l_book.date_published
                , l_book.page_count
              );

   empty_library (table_count);
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (tabcount ());
      DBMS_OUTPUT.put_line (table_count);
END;
/

CREATE OR REPLACE PROCEDURE set_book_info (book_in IN books%ROWTYPE)
IS
BEGIN
   INSERT INTO books
       VALUES book_in;
EXCEPTION
   WHEN DUP_VAL_ON_INDEX
   THEN
      UPDATE books
         SET row = book_in
       WHERE isbn = book_in.isbn;
END;
/

DECLARE
   my_book   books%ROWTYPE;
BEGIN
   my_book.isbn := '1-56592-335-9';
   my_book.title := 'ORACLE PL/SQL PROGRAMMING';
   my_book.summary := 'General user guide and reference';
   my_book.author := 'FEUERSTEIN, STEVEN AND BILL PRIBYL';
   my_book.page_count := 1000;

   INSERT INTO books
       VALUES my_book;
END;
/

BEGIN
   SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
END;
/

