SET SERVEROUTPUT ON FORMAT WRAPPED

CREATE OR REPLACE PROCEDURE assoc_array_index_test (
   iterations_in   IN   PLS_INTEGER DEFAULT 10000
 , length_in       IN   PLS_INTEGER DEFAULT 100
)
IS
   TYPE tab_bynum_tabtype IS TABLE OF employees%ROWTYPE
      INDEX BY PLS_INTEGER;

   TYPE tab_byvc_tabtype IS TABLE OF employees%ROWTYPE
      INDEX BY VARCHAR2 (32767);

   bynum_tab   tab_bynum_tabtype;
   byvc_tab    tab_byvc_tabtype;
   v_salary    NUMBER;
BEGIN
   DBMS_OUTPUT.put_line
                     (   'Compare String and Integer Indexing, Iterations = '
                      || iterations_in
                      || ' Length = '
                      || length_in
                     );

   FOR rec IN (SELECT *
                 FROM employees)
   LOOP
      bynum_tab (rec.employee_id) := rec;
   END LOOP;

   FOR rec IN (SELECT *
                 FROM employees)
   LOOP
      byvc_tab (RPAD (rec.last_name, length_in, 'x')) := rec;
   END LOOP;

   sf_timer.start_timer;

   FOR indx IN 1 .. iterations_in
   LOOP
      FOR rec IN (SELECT *
                    FROM employees)
      LOOP
         v_salary := bynum_tab (rec.employee_id).salary;
      END LOOP;
   END LOOP;

   sf_timer.show_elapsed_time ('Index by PLS_INTEGER '
                               || length_in
                              );
   sf_timer.start_timer;

   FOR indx IN 1 .. iterations_in
   LOOP
      FOR rec IN (SELECT *
                    FROM employees)
      LOOP
         v_salary := byvc_tab (RPAD (rec.last_name, length_in, 'x')).salary;
      END LOOP;
   END LOOP;

   sf_timer.show_elapsed_time ('Index by VARCHAR2 ' || length_in);
END assoc_array_index_test;
/

BEGIN
   assoc_array_index_test (10000, 100);
   assoc_array_index_test (10000, 1000);
   assoc_array_index_test (10000, 10000);
/*
Compare String and Integer Indexing, Iterations = 10000 Length = 100

Timings in seconds for "By Num":
Elapsed = 4.72 - per rep .000472
CPU     = 4.49 - per rep .000449

Timings in seconds for "By VC":
Elapsed = 5.43 - per rep .000543
CPU     = 5.44 - per rep .000544

Compare String and Integer Indexing, Iterations = 10000 Length = 1000

Timings in seconds for "By Num":
Elapsed = 4.64 - per rep .000464
CPU     = 4.53 - per rep .000453

Timings in seconds for "By VC":
Elapsed = 7.78 - per rep .000778
CPU     = 7.76 - per rep .000776

Compare String and Integer Indexing, Iterations = 10000 Length = 10000

Timings in seconds for "By Num":
Elapsed = 5.09 - per rep .000509
CPU     = 4.56 - per rep .000456

Timings in seconds for "By VC":
Elapsed = 31.72 - per rep .003172
CPU     = 31.66 - per rep .003166

*/
END;
/