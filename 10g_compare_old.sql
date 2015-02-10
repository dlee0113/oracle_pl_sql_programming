CREATE OR REPLACE PACKAGE emp_coll_pkg
IS
   TYPE employee_tt IS TABLE OF employee%ROWTYPE;

   FUNCTION equal (coll1_in IN employee_tt, coll2_in IN employee_tt)
      RETURN BOOLEAN;
END emp_coll_pkg;
/

CREATE OR REPLACE PACKAGE BODY emp_coll_pkg
IS
   FUNCTION equal (coll1_in IN employee_tt, coll2_in IN employee_tt)
      RETURN BOOLEAN
   IS
      l_count1   PLS_INTEGER := coll1_in.COUNT;
      l_count2   PLS_INTEGER := coll2_in.COUNT;
      l_row      PLS_INTEGER := coll1_in.FIRST;
      retval     BOOLEAN;

      FUNCTION row_equal (
         row1_in IN employee%ROWTYPE
       , row2_in IN employee%ROWTYPE
      )
         RETURN BOOLEAN
      IS
         retval   BOOLEAN;
      BEGIN
         retval :=
                 row1_in.employee_id = row2_in.employee_id
             AND row1_in.last_name = row2_in.last_name
             AND row1_in.first_name = row2_in.first_name
             AND row1_in.middle_initial = row2_in.middle_initial
             AND row1_in.job_id = row2_in.job_id
             AND row1_in.manager_id = row2_in.manager_id
             AND row1_in.hire_date = row2_in.hire_date
             AND row1_in.salary = row2_in.salary
             AND row1_in.commission = row2_in.commission
             AND row1_in.department_id = row2_in.department_id
             AND row1_in.empno = row2_in.empno
             AND row1_in.ename = row2_in.ename
             AND row1_in.created_by = row2_in.created_by
             AND row1_in.created_on = row2_in.created_on
             AND row1_in.changed_by = row2_in.changed_by
             AND row1_in.changed_on = row2_in.changed_on;
         RETURN retval;
      END row_equal;
   BEGIN
      retval := l_count1 = l_count2;

      IF retval
      THEN
         LOOP
            EXIT WHEN l_row IS NULL OR NOT retval;
            retval := row_equal (coll1_in (l_row), coll2_in (l_row));
            l_row := coll1_in.NEXT (l_row);
         END LOOP;
      END IF;

      RETURN retval;
   END;
END emp_coll_pkg;
/

