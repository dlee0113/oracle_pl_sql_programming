SET SERVEROUTPUT ON
CREATE OR REPLACE PACKAGE nocopy_test
IS
   TYPE emp_tabtype IS TABLE OF employee%ROWTYPE INDEX BY BINARY_INTEGER;
   
   PROCEDURE pass_by_value (
      emps IN OUT emp_tabtype,
      raise_err IN BOOLEAN := FALSE);
      
   PROCEDURE pass_by_ref (
      emps IN OUT NOCOPY emp_tabtype,
      raise_err IN BOOLEAN := FALSE);
   
   PROCEDURE compare_methods (num IN PLS_INTEGER);
END;
/
CREATE OR REPLACE PACKAGE BODY nocopy_test
IS
   PROCEDURE pass_by_value (
      emps IN OUT emp_tabtype,
      raise_err IN BOOLEAN := FALSE)
   IS
   BEGIN
      FOR indx IN emps.FIRST .. emps.LAST
      LOOP
         emps(indx).last_name := RTRIM (emps(indx).last_name || ' ');
         emps(indx).salary := emps(indx).salary + 1;
      END LOOP;
      IF raise_err THEN RAISE VALUE_ERROR; END IF;
   END;
      
   PROCEDURE pass_by_ref (
      emps IN OUT NOCOPY emp_tabtype,
      raise_err IN BOOLEAN := FALSE)
   IS
   BEGIN
      FOR indx IN emps.FIRST .. emps.LAST
      LOOP
         emps(indx).last_name := RTRIM (emps(indx).last_name || ' ');
         emps(indx).salary := emps(indx).salary + 1;
      END LOOP;
      IF raise_err THEN RAISE VALUE_ERROR; END IF;
   END;
   
   PROCEDURE compare_methods (num IN PLS_INTEGER)
   IS
      emptab emp_tabtype;
      
      PROCEDURE loadtab IS 
      BEGIN
         sf_timer.start_timer;
         emptab.DELETE;
         FOR indx IN 1 .. num
         LOOP
            FOR rec IN (SELECT * FROM employee)
            LOOP
               emptab(NVL(emptab.LAST,0)+1) := rec;
            END LOOP;
         END LOOP;
         sf_timer.show_elapsed_time ('Fill table ' || num);
      END;
   BEGIN
      
      loadtab;
      sf_timer.start_timer;
      FOR indx IN 1 .. num
      LOOP
         pass_by_value (emptab, FALSE);
      END LOOP;
      sf_timer.show_elapsed_time ('By value no error ' || num);
      
      loadtab;
      sf_timer.start_timer;
      FOR indx IN 1 .. num
      LOOP
         pass_by_ref (emptab, FALSE);
      END LOOP;
      sf_timer.show_elapsed_time ('NOCOPY no error ' || num);
      
      loadtab;
      sf_timer.start_timer;
      BEGIN
         FOR indx IN 1 .. num
         LOOP
            pass_by_value (emptab, TRUE);
         END LOOP;
      EXCEPTION
         WHEN OTHERS THEN 
            sf_timer.show_elapsed_time ('By value raising error ' || num);
      END;
      
      loadtab;
      sf_timer.start_timer;
      BEGIN
         FOR indx IN 1 .. num
         LOOP
            pass_by_ref (emptab, TRUE);
         END LOOP;
      EXCEPTION
         WHEN OTHERS THEN             
            sf_timer.show_elapsed_time ('NOCOPY raising error ' || num);
      END;
   END;
END;
/
BEGIN
   nocopy_test.compare_methods (10);
   nocopy_test.compare_methods (100);
END;
/   