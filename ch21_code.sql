/*
Oracle PL/SQL Programming 5th Edition

www.stevenfeuerstein.com/books

Objection creation and example scripts for Chapter 21

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
   DBMS_PROFILER.start_profiler (
      'my application' || TO_CHAR (SYSDATE, 'YYYYMMDD HH24:MI:SS')
   );

   my_application_code;

   DBMS_PROFILER.stop_profiler;
END;
/

BEGIN
   DBMS_HPROF.start_profiling ('TEMP_DIR', 'intab_trace.txt');
END;
/

BEGIN
   DBMS_HPROF.stop_profiling;
END;
/

BEGIN
   DBMS_OUTPUT.put_line (DBMS_HPROF.analyze ('TEMP_DIR', 'intab_trace.txt'));
END;
/

SELECT runid, run_timestamp, total_elapsed_time, run_comment
  FROM dbmshp_runs
/

SELECT symbolid, owner, module, TYPE, function, line#, namespace
  FROM dbmshp_function_info
/

SELECT function
     , line#
     , namespace
     , subtree_elapsed_time
     , function_elapsed_time
     , calls
  FROM dbmshp_function_info
 WHERE runid = 177
/

SELECT parentsymid
     , childsymid
     , subtree_elapsed_time
     , function_elapsed_time
     , calls
  FROM dbmshp_parent_child_info
 WHERE runid = 117
/

    SELECT RPAD (' ', LEVEL * 2, ' ') || fi.owner || '.' || fi.module AS name
         , fi.function
         , pci.subtree_elapsed_time
         , pci.function_elapsed_time
         , pci.calls
      FROM    dbmshp_parent_child_info pci
           JOIN
              dbmshp_function_info fi
           ON pci.runid = fi.runid AND pci.childsymid = fi.symbolid
     WHERE pci.runid = 117
CONNECT BY PRIOR childsymid = parentsymid
START WITH pci.parentsymid = 1
/

DECLARE
   l_start_time   PLS_INTEGER;
BEGIN
   l_start_time := DBMS_UTILITY.get_time;

   my_program;

   DBMS_OUTPUT.put_line ('Elapsed: ' || DBMS_UTILITY.get_time - l_start_time);
END;
/

BEGIN
   sf_timer.start_timer ();

   my_program;

   sf_timer.show_elapsed_time ('Ran my_program');
END;
/

DECLARE
   c_big_number   NUMBER := POWER (2, 32);
   l_start_time   PLS_INTEGER;
BEGIN
   l_start_time := DBMS_UTILITY.get_time;
   my_program;
   DBMS_OUTPUT.put_line('Elapsed: '
                        || TO_CHAR(MOD (
                                        DBMS_UTILITY.get_time
                                      - l_start_time
                                      + c_big_number
                                    , c_big_number
                                   )));
END;
/

DROP TABLE transportion
/

CREATE TABLE transportation
(
   name             VARCHAR2 (100)
 , mileage          NUMBER
 , transport_type   VARCHAR2 (100)
)
/

DECLARE
   TYPE names_t IS TABLE OF transportation.name%TYPE;

   TYPE mileage_t IS TABLE OF transportation.mileage%TYPE;

   names      names_t;
   mileages   mileage_t;

   CURSOR major_polluters_cur
   IS
      SELECT name, mileage
        FROM transportation
       WHERE transport_type = 'AUTOMOBILE' AND mileage < 20;
BEGIN
   FOR bad_car IN major_polluters_cur
   LOOP
      names.EXTEND;
      names (major_polluters_cur%ROWCOUNT) := bad_car.name;
      mileages.EXTEND;
      mileages (major_polluters_cur%ROWCOUNT) := bad_car.mileage;
   END LOOP;
-- Now work with data in the collections
END;
/

DECLARE
   TYPE names_t IS TABLE OF transportation.name%TYPE;

   TYPE mileage_t IS TABLE OF transportation.mileage%TYPE;

   names      names_t;
   mileages   mileage_t;
BEGIN
   SELECT name, mileage
     BULK COLLECT
     INTO names, mileages
     FROM transportation
    WHERE transport_type = 'AUTOMOBILE' AND mileage < 20;
/* Now work with data in the collections */
END;
/

DECLARE
   TYPE names_t IS TABLE OF transportation.name%TYPE;

   TYPE mileage_t IS TABLE OF transportation.mileage%TYPE;

   names      names_t;
   mileages   mileage_t;

   CURSOR major_polluters_cur
   IS
      SELECT name, mileage
        FROM transportation
       WHERE transport_type = 'AUTOMOBILE' AND mileage < 20;
BEGIN
   OPEN major_polluters_cur;

   FETCH major_polluters_cur
   BULK COLLECT INTO names, mileages;

   CLOSE major_polluters_cur;
END;
/

DECLARE
   TYPE transportation_aat IS TABLE OF transportation%ROWTYPE
                                 INDEX BY PLS_INTEGER;

   l_transportation   transportation_aat;
BEGIN
   SELECT *
     BULK COLLECT
     INTO l_transportation
     FROM transportation
    WHERE transport_type = 'AUTOMOBILE' AND mileage < 20;
-- Now work with data in the collections
END;
/

DECLARE
   CURSOR allrows_cur
   IS
      SELECT *
        FROM employees;

   TYPE employee_aat IS TABLE OF allrows_cur%ROWTYPE
                           INDEX BY BINARY_INTEGER;

   l_employees   employee_aat;
BEGIN
   OPEN allrows_cur;

   LOOP
      FETCH allrows_cur
      BULK COLLECT INTO l_employees
      LIMIT 100;

      /* Process the data by scanning through the collection. */
      FOR l_row IN 1 .. l_employees.COUNT
      LOOP
         upgrade_employee_status (l_employees (l_row).employee_id);
      END LOOP;

      EXIT WHEN allrows_cur%NOTFOUND;
   END LOOP;

   CLOSE allrows_cur;
END;
/

CREATE OR REPLACE PROCEDURE order_books (isbns_in      IN name_varray
                                       , new_counts_in IN number_varray
                                        )
IS
BEGIN
   FORALL indx IN isbns_in.FIRST .. isbns_in.LAST
      UPDATE books
         SET page_count = new_counts_in (indx)
       WHERE isbn = isbns_in (indx);
END;
/

CREATE OR REPLACE TYPE dlist_t IS TABLE OF INTEGER
/

CREATE OR REPLACE TYPE enolist_t IS TABLE OF INTEGER
/

CREATE OR REPLACE FUNCTION remove_emps_by_dept (deptlist IN dlist_t)
   RETURN enolist_t
IS
   enolist   enolist_t;
BEGIN
   FORALL adept IN deptlist.FIRST .. deptlist.LAST
            DELETE FROM employees
                  WHERE department_id IN deptlist (adept)
              RETURNING employee_id
      BULK COLLECT INTO enolist;

   RETURN enolist;
END;
/

BEGIN
   FORALL indx IN INDICES OF l_top_employees
      EXECUTE IMMEDIATE   'INSERT INTO '
                       || l_table
                       || ' VALUES (:emp_pky, :new_salary)'
         USING l_new_salaries (indx).employee_id
             , l_new_salaries (indx).salary;
END;
/

DROP TABLE books
/

CREATE TABLE books
(
   author       VARCHAR2 (100) NOT NULL
 , title        VARCHAR2 (250) NOT NULL
 , page_count   NUMBER (5)
 , isbn         VARCHAR2 (13)
 , CONSTRAINT pk_books PRIMARY KEY (author, title)
)
/

DECLARE
   TYPE isbn_list IS TABLE OF VARCHAR2 (13);

   my_books isbn_list
         := isbn_list ('1-56592-375-8'
                     , '0-596-00121-5'
                     , '1-56592-849-0'
                     , '1-56592-335-9'
                     , '1-56592-674-9'
                     , '1-56592-675-7'
                     , '0-596-00180-0'
                     , '1-56592-457-6'
                      );
BEGIN
   FORALL book_index IN my_books.FIRST .. my_books.LAST
      UPDATE books
         SET page_count = page_count / 2
       WHERE isbn = my_books (book_index);

   -- Did I update the total number of books I expected?
   IF sql%ROWCOUNT != 8
   THEN
      DBMS_OUTPUT.put_line ('We are missing a book!');
   END IF;

   -- Did the 4th UPDATE statement affect any rows?
   IF sql%BULK_ROWCOUNT (4) = 0
   THEN
      DBMS_OUTPUT.put_line ('What happened to Oracle PL/SQL Programming?');
   END IF;
END;
/

