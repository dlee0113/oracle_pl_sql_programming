/*
Oracle PL/SQL Programming 5th Edition

www.stevenfeuerstein.com/books

Objection creation and example scripts for Chapter 15

You will find below all non-trivial code snippets from the above chapter
that are NOT contained in their own files (as specified in the chapter),
plus any DDL object creation scripts required to get a clean compile
on the snippets.

Any references to Oracle's standard HR tables (employees, departments,
locations, regions, etc.) will NOT include the DDL creation scripts
in this file. Instead, run the hr_schema_install.sql script and all
those tables and related elements will be defined.
*/
DROP TABLE comedian
/
DROP TABLE joke
/
DROP TABLE joke_category
/
DROP TABLE response
/

CREATE TABLE comedian
(
   joker_id     INTEGER
 , name         VARCHAR2 (100)
 , started_on   DATE
)
/

CREATE TABLE response
(
   joke_id        INTEGER
 , joker_id       INTEGER
 , laugh_volume   NUMBER
)
/

CREATE TABLE joke_category (category_id INTEGER, name VARCHAR2 (100))
/

CREATE TABLE joke
(
   joke_id          INTEGER
 , name             VARCHAR2 (100)
 , category         INTEGER
 , last_used_date   DATE
 , punch_line       VARCHAR2 (1000)
)
/

DECLARE
   CURSOR joke_feedback_cur
   IS
      SELECT j.name, r.laugh_volume, c.name
        FROM joke j, response r, comedian c
       WHERE j.joke_id = r.joke_id AND r.joker_id = c.joker_id;
BEGIN
   NULL;
END;
/

CREATE TABLE callers (caller_id INTEGER, name VARCHAR2 (100))
/

CREATE TABLE call
(
   call_id          INTEGER
 , caller_id        INTEGER
 , call_timestamp   timestamp
)
/

DECLARE
   CURSOR caller_cur
   IS
      SELECT *
        FROM callers;
BEGIN
   FOR caller_rec IN caller_cur
   LOOP
      UPDATE call
         SET caller_id = caller_rec.caller_id
       WHERE call_timestamp < SYSDATE;

      IF sql%FOUND
      THEN
         DBMS_OUTPUT.put_line ('Calls updated for ' || caller_rec.caller_id);
      END IF;
   END LOOP;
END;
/

BEGIN
   UPDATE employees
      SET last_name = 'FEUERSTEIN';

   DBMS_OUTPUT.put_line (sql%ROWCOUNT);
END;
/

CREATE TABLE happiness (simple_delights VARCHAR2 (100))
/

DECLARE
   CURSOR happiness_cur
   IS
      SELECT simple_delights
        FROM happiness;
BEGIN
   OPEN happiness_cur;

   IF happiness_cur%ISOPEN
   THEN
      NULL;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      IF happiness_cur%ISOPEN
      THEN
         CLOSE happiness_cur;
      END IF;
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

DECLARE
   l_title   books.title%TYPE;
BEGIN
   SELECT title
     INTO l_title
     FROM books
    WHERE isbn = '0-596-00121-5';
END;
/

DECLARE
   l_book   books%ROWTYPE;
BEGIN
   SELECT *
     INTO l_book
     FROM books
    WHERE isbn = '0-596-00121-5';
END;
/

DECLARE
   department_total   NUMBER;
BEGIN
   SELECT SUM (salary)
     INTO department_total
     FROM employees
    WHERE department_id = 10;
END;
/

DECLARE
   l_isbn    books.isbn%TYPE := '0-596-00121-5';
   l_title   books.title%TYPE;
BEGIN
   SELECT title
     INTO l_title
     FROM books
    WHERE isbn = l_isbn;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      DBMS_OUTPUT.put_line ('Unknown book: ' || l_isbn);
   WHEN TOO_MANY_ROWS
   THEN
      /* This package defined in errpkg.pkg */
      errpkg.record_and_stop ('Data integrity error for: ' || l_isbn);
      RAISE;
END;
/

CREATE OR REPLACE FUNCTION book_title (isbn_in IN books.isbn%TYPE)
   RETURN books.title%TYPE
IS
   return_value   books.title%TYPE;
BEGIN
   SELECT title
     INTO return_value
     FROM books
    WHERE isbn = isbn_in;

   RETURN return_value;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      RETURN NULL;
   WHEN TOO_MANY_ROWS
   THEN
      errpkg.record_and_stop ('Data integrity error for: ' || isbn_in);
      RAISE;
END;
/

CREATE OR REPLACE PROCEDURE remove_from_circulation (
   isbn_in IN books.isbn%TYPE
)
IS
BEGIN
   DELETE FROM books
         WHERE isbn = isbn_in;
END;
/

CREATE OR REPLACE PROCEDURE show_book_count
IS
   l_count   INTEGER;
BEGIN
   SELECT COUNT ( * )
     INTO l_count
     FROM books;

   -- No such book!
   remove_from_circulation ('0-000-00000-0');

   DBMS_OUTPUT.put_line (sql%ROWCOUNT);
END;
/

CREATE OR REPLACE PROCEDURE show_book_count
IS
   l_count      INTEGER;
   l_numfound   PLS_INTEGER;
BEGIN
   SELECT COUNT ( * )
     INTO l_count
     FROM books;

   -- Take snapshot of attribute value:
   l_numfound := sql%ROWCOUNT;

   -- No such book!
   remove_from_circulation ('0-000-00000-0');

   -- Now I can go back to the previous attribute value.
   DBMS_OUTPUT.put_line (l_numfound);
END;
/

CREATE TABLE friends (name VARCHAR2 (100), location VARCHAR2 (100))
/

CREATE OR REPLACE FUNCTION jealousy_level (NAME_IN IN friends.name%TYPE)
   RETURN NUMBER
AS
   CURSOR jealousy_cur
   IS
      SELECT location
        FROM friends
       WHERE name = UPPER (NAME_IN);

   jealousy_rec   jealousy_cur%ROWTYPE;
   retval         NUMBER;
BEGIN
   OPEN jealousy_cur;

   FETCH jealousy_cur
   INTO jealousy_rec;

   IF jealousy_cur%FOUND
   THEN
      IF jealousy_rec.location = 'PUERTO RICO'
      THEN
         retval := 10;
      ELSIF jealousy_rec.location = 'CHICAGO'
      THEN
         retval := 1;
      END IF;
   END IF;

   CLOSE jealousy_cur;

   RETURN retval;
EXCEPTION
   WHEN OTHERS
   THEN
      IF jealousy_cur%ISOPEN
      THEN
         CLOSE jealousy_cur;
      END IF;
END;
/

CREATE OR REPLACE PACKAGE book_info
IS
   CURSOR titles_cur
   IS
      SELECT title
        FROM books;

   CURSOR books_cur (title_filter_in IN books.title%TYPE)
      RETURN books%ROWTYPE
   IS
      SELECT *
        FROM books
       WHERE title LIKE title_filter_in;
END;
/

CREATE OR REPLACE PACKAGE book_info
IS
   CURSOR books_cur (title_filter_in IN books.title%TYPE)
      RETURN books%ROWTYPE;
END;
/

CREATE OR REPLACE PACKAGE BODY book_info
IS
   CURSOR books_cur (title_filter_in IN books.title%TYPE)
      RETURN books%ROWTYPE
   IS
      SELECT *
        FROM books
       WHERE title LIKE title_filter_in;
END;
/

CREATE TABLE invoice (invoice_date DATE, company_id INTEGER, inv_amt NUMBER)
/

DECLARE
   CURSOR comp_cur
   IS
        SELECT c.name, SUM (inv_amt) total_sales
          FROM company c, invoice i
         WHERE c.company_id = i.company_id
               AND i.invoice_date BETWEEN '01-JAN-2001' AND '31-DEC-2001'
      GROUP BY c.name;

   comp_rec   comp_cur%ROWTYPE;
BEGIN
   OPEN comp_cur;

   FETCH comp_cur
   INTO comp_rec;

   IF comp_rec.total_sales > 5000
   THEN
      DBMS_OUTPUT.put_line(' You have exceeded your credit limit of $5000 by '
                           || TO_CHAR (comp_rec.total_sales - 5000, '$9999'));
   END IF;
END;
/

CREATE OR REPLACE PACKAGE bookinfo_pkg
IS
   CURSOR bard_cur
   IS
      SELECT title, date_published
        FROM books
       WHERE UPPER (author) LIKE 'SHAKESPEARE%';
END bookinfo_pkg;
/

DECLARE
   bard_rec   bookinfo_pkg.bard_cur%ROWTYPE;
BEGIN
   /* Check to see if the cursor is already opened.
      This may be the case as it is a packaged cursor.
      If so, first close it and then re-open it to
      ensure a "fresh" result set.
   */
   IF bookinfo_pkg.bard_cur%ISOPEN
   THEN
      CLOSE bookinfo_pkg.bard_cur;
   END IF;

   OPEN bookinfo_pkg.bard_cur;

   -- Fetch each row, but stop when I've displayed the
   -- first five works by Shakespeare or when I have
   -- run out of rows.
   LOOP
      FETCH bookinfo_pkg.bard_cur
      INTO bard_rec;

      EXIT WHEN bookinfo_pkg.bard_cur%NOTFOUND
                OR bookinfo_pkg.bard_cur%ROWCOUNT > 5;
      DBMS_OUTPUT.put_line(   bookinfo_pkg.bard_cur%ROWCOUNT
                           || ') '
                           || bard_rec.title
                           || ', published in '
                           || TO_CHAR (bard_rec.date_published, 'YYYY'));
   END LOOP;

   CLOSE bookinfo_pkg.bard_cur;
END bookinfo_pkg;
/

CREATE OR REPLACE PROCEDURE explain_joke (
   main_category_in IN joke_category.category_id%TYPE
)
IS
   /*
   || Cursor with parameter list consisting of a single
   || string parameter.
   */
   CURSOR joke_cur (category_in VARCHAR2)
   IS
      SELECT name, category, last_used_date
        FROM joke
       WHERE category = UPPER (category_in);

   joke_rec   joke_cur%ROWTYPE;
BEGIN
   /* Now when I open the cursor, I also pass the argument */
   OPEN joke_cur (main_category_in);

   FETCH joke_cur
   INTO joke_rec;
END;
/

CREATE TABLE tales_from_the_crypt
(
   prog_name     VARCHAR2 (100)
 , scary_level   INTEGER
)
/

DECLARE
   CURSOR scariness_cur (program_name VARCHAR2)
   IS
      SELECT SUM (scary_level) total_scary_level
        FROM tales_from_the_crypt
       WHERE prog_name = program_name;
BEGIN
   program_name := 'THE BREATHING MUMMY';              /* Illegal reference */

   OPEN scariness_cur (program_name);

   CLOSE scariness_cur;
END;
/

DROP TABLE my_sons_collection
/

CREATE TABLE my_sons_collection
(
   name                    VARCHAR2 (100)
 , manufacturer            INTEGER
 , preference_level        INTEGER
 , sell_at_yardsale_flag   CHAR (1)
 , hours_used              NUMBER
)
/

DROP TABLE winterize
/

CREATE TABLE winterize
(
   task_id               INTEGER
 , task                  VARCHAR2 (100)
 , expected_hours        NUMBER
 , tools_required        VARCHAR2 (100)
 , do_it_yourself_flag   CHAR (1)
 , year_of_task          INTEGER
 , completed_flag        CHAR (1)
 , responsible           VARCHAR2 (100)
)
/

CREATE TABLE husband_config
(
   task_id                       INTEGER
 , max_procrastination_allowed   INTEGER
)
/

DECLARE
   CURSOR toys_cur
   IS
          SELECT name, manufacturer, preference_level, sell_at_yardsale_flag
            FROM my_sons_collection
           WHERE hours_used = 0
      FOR UPDATE ;

   CURSOR fall_jobs_cur
   IS
          SELECT task, expected_hours, tools_required, do_it_yourself_flag
            FROM winterize
           WHERE year_of_task = TO_CHAR (SYSDATE, 'YYYY')
      FOR UPDATE OF task;

   CURSOR fall_jobs_cur2
   IS
          SELECT w.task
               , w.expected_hours
               , w.tools_required
               , w.do_it_yourself_flag
            FROM winterize w, husband_config hc
           WHERE w.year_of_task = TO_CHAR (SYSDATE, 'YYYY')
                 AND w.task_id = hc.task_id
      FOR UPDATE OF hc.max_procrastination_allowed;
BEGIN
   NULL;
END;
/

DECLARE
   /* All the jobs in the Fall to prepare for the Winter */
   CURSOR fall_jobs_cur
   IS
      SELECT task, expected_hours, tools_required, do_it_yourself_flag
        FROM winterize
       WHERE year_of_task = TO_NUMBER (TO_CHAR (SYSDATE, 'YYYY'))
             AND completed_flag = 'NOTYET';
BEGIN
   /* For each job fetched by the cursor... */
   FOR job_rec IN fall_jobs_cur
   LOOP
      IF job_rec.do_it_yourself_flag = 'YOUCANDOIT'
      THEN
         /*
         || I have found my next job. Assign it to myself (like someone
         || else is going to do it!) and then commit the changes.
         */
         UPDATE winterize
            SET responsible = 'STEVEN'
          WHERE task = job_rec.task
                AND year_of_task = TO_NUMBER (TO_CHAR (SYSDATE, 'YYYY'));

         COMMIT;
      END IF;
   END LOOP;
END;
/

DECLARE
   CURSOR fall_jobs_cur
   IS
          SELECT task, expected_hours, tools_required, do_it_yourself_flag
            FROM winterize
           WHERE year_of_task = TO_NUMBER (TO_CHAR (SYSDATE, 'YYYY'))
                 AND completed_flag = 'NOTYET'
      FOR UPDATE ;

   job_rec   fall_jobs_cur%ROWTYPE;
BEGIN
   OPEN fall_jobs_cur;

   LOOP
      FETCH fall_jobs_cur
      INTO job_rec;

      EXIT WHEN fall_jobs_cur%NOTFOUND;

      IF job_rec.do_it_yourself_flag = 'YOUCANDOIT'
      THEN
         UPDATE winterize
            SET responsible = 'STEVEN'
          WHERE CURRENT OF fall_jobs_cur;

         COMMIT;
         EXIT;
      END IF;
   END LOOP;

   CLOSE fall_jobs_cur;
END;
/

DECLARE
   /* Define weak REF CURSOR type, cursor variable
      and local variable */
   curvar1         sys_refcursor;
   do_you_get_it   VARCHAR2 (100);
BEGIN
   /*
   || Nested block which creates the cursor object and
   || assigns it to the curvar1 cursor variable.
   */
   DECLARE
      curvar2   sys_refcursor;
   BEGIN
      OPEN curvar2 FOR
         SELECT punch_line
           FROM joke;

      curvar1 := curvar2;
   END;

   /*
   || The curvar2 cursor variable is no longer active,
   || but "the baton" has been passed to curvar1, which
   || does exist in the enclosing block. I can therefore
   || fetch from the cursor object, through this other
   || cursor variable.
   */
   FETCH curvar1
   INTO do_you_get_it;

   CLOSE curvar1;
END;
/

DECLARE
   /* Define the REF CURSOR type. */
   TYPE curvar_type IS REF CURSOR
      RETURN company%ROWTYPE;

   /* Reference it in the parameter list. */
   PROCEDURE open_query (curvar_out OUT curvar_type)
   IS
      local_cur   curvar_type;
   BEGIN
      OPEN local_cur FOR
         SELECT *
           FROM company;

      curvar_out := local_cur;
   END;
BEGIN
   NULL;
END;
/

CREATE OR REPLACE PROCEDURE assign_curvar (
   old_curvar_in  IN     company.curvar_type
 , new_curvar_out    OUT company.curvar_type
)
IS
BEGIN
   new_curvar_out := old_curvar_in;
END;
/

CREATE OR REPLACE PROCEDURE emp_report (p_locid NUMBER)
IS
   TYPE refcursor IS REF CURSOR;

   -- The query returns only 2 columns, but the second column is
   -- a cursor that lets us traverse a set of related information.
   CURSOR all_in_one_cur
   IS
      SELECT l.city
           , cursor(SELECT d.department_name
                         , cursor (SELECT e.last_name
                                     FROM employees e
                                    WHERE e.department_id = d.department_id)
                              AS ename
                      FROM departments d
                     WHERE l.location_id = d.location_id)
                AS dname
        FROM locations l
       WHERE l.location_id = p_locid;

   departments_cur   refcursor;
   employees_cur     refcursor;

   v_city            locations.city%TYPE;
   v_dname           departments.department_name%TYPE;
   v_ename           employees.last_name%TYPE;
BEGIN
   OPEN all_in_one_cur;

   LOOP
      FETCH all_in_one_cur
      INTO v_city, departments_cur;

      EXIT WHEN all_in_one_cur%NOTFOUND;

      -- Now I can loop through departments and I do NOT need to
      -- explicitly open that cursor. Oracle did it for me.
      LOOP
         FETCH departments_cur
         INTO v_dname, employees_cur;

         EXIT WHEN departments_cur%NOTFOUND;

         -- Now I can loop through employees for that department.
         -- Again, I do not need to open the cursor explicitly.
         LOOP
            FETCH employees_cur
            INTO v_ename;

            EXIT WHEN employees_cur%NOTFOUND;
            DBMS_OUTPUT.put_line (v_city || ' ' || v_dname || ' ' || v_ename);
         END LOOP;
      END LOOP;
   END LOOP;

   CLOSE all_in_one_cur;
END;
/

