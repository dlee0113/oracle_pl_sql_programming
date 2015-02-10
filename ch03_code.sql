/*
Oracle PL/SQL Programming 5th Edition

www.stevenfeuerstein.com/books

Objection creation and example scripts for Chapter 3

You will find below all non-trivial code snippets from the above chapter
that are NOT contained in their own files (as specified in the chapter),
plus any DDL object creation scripts required to get a clean compile
on the snippets.

Any references to Oracle's standard HR tables (employees, departments,
locations, regions, etc.) will NOT include the DDL creation scripts
in this file. Instead, run the hr_schema_install.sql script and all
those tables and related elements will be defined.
*/

BEGIN
   DBMS_OUTPUT.put_line (SYSDATE);
END;
/

DECLARE
   l_right_now   VARCHAR2 (9);
BEGIN
   l_right_now := SYSDATE;
   DBMS_OUTPUT.put_line (l_right_now);
END;
/

DECLARE
   l_right_now   VARCHAR2 (9);
BEGIN
   l_right_now := SYSDATE;
   DBMS_OUTPUT.put_line (l_right_now);
EXCEPTION
   WHEN VALUE_ERROR
   THEN
      DBMS_OUTPUT.put_line (
         'I bet l_right_now is too small ' || 'for the default date format!'
      );
END;
/

CREATE OR REPLACE PROCEDURE calc_totals
IS
   year_total   NUMBER;
BEGIN
   year_total := 0;

   /* Beginning of nested block */
   DECLARE
      month_total   NUMBER;
   BEGIN
      month_total := year_total / 12;
   END set_month_total;
/* End of nested block */

END;
/

CREATE OR REPLACE PACKAGE scope_demo
IS
   g_global   NUMBER;

   PROCEDURE set_global (number_in IN NUMBER);
END scope_demo;
/

CREATE OR REPLACE PACKAGE BODY scope_demo
IS
   PROCEDURE set_global (number_in IN NUMBER)
   IS
      l_salary   NUMBER := 10000;
      l_count    PLS_INTEGER;
   BEGIN
     <<local_block>>
      DECLARE
         l_inner   NUMBER;
      BEGIN
         SELECT COUNT ( * )
           INTO l_count
           FROM employees
          WHERE department_id = l_inner AND salary > l_salary;
      END local_block;

      g_global := number_in;
   END set_global;
END scope_demo;
/

/* Example with qualifications */

CREATE OR REPLACE PACKAGE BODY scope_demo
IS
   PROCEDURE set_global (number_in IN NUMBER)
   IS
      l_salary   NUMBER := 10000;
      l_count    PLS_INTEGER;
   BEGIN
     <<local_block>>
      DECLARE
         l_inner   PLS_INTEGER;
      BEGIN
         SELECT COUNT ( * )
           INTO set_global.l_count
           FROM employees e
          WHERE e.department_id = local_block.l_inner
                AND e.salary > set_global.l_salary;
      END local_block;

      scope_demo.g_global := set_global.number_in;
   END set_global;
END scope_demo;
/

DECLARE
   first_day   DATE;
   LAST_DAY    DATE;
BEGIN
   first_day := SYSDATE;
   LAST_DAY := ADD_MONTHS (first_day, 6);
END;
/

CREATE OR REPLACE PROCEDURE calc_totals (fudge_factor_in IN NUMBER)
IS
   subtotal   NUMBER := 0;

   /* Beginning of nested block (in this case a procedure). Notice
   |  we're completely inside the declaration section of calc_totals.
   */
   PROCEDURE compute_running_total (increment_in IN PLS_INTEGER)
   IS
   BEGIN
      /* subtotal, declared above, is both in scope and visible */
      subtotal := subtotal + increment_in * fudge_factor_in;
   END;
/* End of nested block */
BEGIN
   FOR month_idx IN 1 .. 12
   LOOP
      compute_running_total (month_idx);
   END LOOP;

   DBMS_OUTPUT.put_line ('Fudged total for year: ' || subtotal);
END;
/

DECLARE
   "pi"     CONSTANT NUMBER := 3.141592654;
   "PI"     CONSTANT NUMBER := 3.14159265358979323846;
   "2 pi"   CONSTANT NUMBER := 2 * "pi";
BEGIN
   DBMS_OUTPUT.put_line ('pi: ' || "pi");
   DBMS_OUTPUT.put_line ('PI: ' || pi);
   DBMS_OUTPUT.put_line ('2 pi: ' || "2 pi");
END;
/

DECLARE
   enough_money   BOOLEAN;                       -- Declare a Boolean variable
BEGIN
   enough_money := FALSE;                                 -- Assign it a value
END;
/

DECLARE
   no_such_sequence exception;
   PRAGMA EXCEPTION_INIT (no_such_sequence, -2289);
BEGIN
   NULL;
EXCEPTION
   WHEN no_such_sequence
   THEN
      q$error_manager.raise_error ('Sequence not defined');
END;
/

create table catalog (name varchar2(100))
/

<<insert_but_ignore_dups>>
BEGIN
   INSERT INTO catalog
   VALUES ('Steven');
EXCEPTION
   WHEN DUP_VAL_ON_INDEX
   THEN
      NULL;
END insert_but_ignore_dups;
/

<<outerblock>>
DECLARE
   counter INTEGER := 0;
BEGIN   
   DECLARE
      counter INTEGER := 1;
   BEGIN
      IF counter = outerblock.counter
      THEN
         NULL;
      END IF;
   END;
END;
/