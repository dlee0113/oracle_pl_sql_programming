CREATE OR REPLACE PACKAGE BODY te_employee
--//-----------------------------------------------------------------------
--//  ** Table Encapsulator for "employee"
--//-----------------------------------------------------------------------
--//  (c) COPYRIGHT Personnel Policies, Inc. 1999.
--//               All rights reserved.
--//
--//  No part of this copyrighted work may be reproduced, modified,
--//  or distributed in any form or by any means without the prior
--//  written permission of Personnel Policies, Inc..
--//-----------------------------------------------------------------------
--//  Stored In:  te_employee.pkb
--//  Created On: September 05, 1999 20:14:04
--//  Created By: SCOTT
--//  PL/Generator Version: PRO-99.2.1
--//-----------------------------------------------------------------------
IS
   --// Package name and program name globals --//
   c_pkgname VARCHAR2(30) := 'te_employee';
   g_progname VARCHAR2(30) := NULL;

   --// Update Flag private data structures. --//
   TYPE frcflg_rt IS RECORD (
      last_name CHAR(1),
      first_name CHAR(1),
      middle_initial CHAR(1),
      job_id CHAR(1),
      manager_id CHAR(1),
      hire_date CHAR(1),
      salary CHAR(1),
      commission CHAR(1),
      department_id CHAR(1),
      changed_by CHAR(1),
      changed_on CHAR(1)
      );

   frcflg frcflg_rt;
   emptyfrc frcflg_rt;
   c_set CHAR(1) := 'Y';
   c_noset CHAR(1) := 'N';

   TYPE tab_tabtype IS TABLE OF allcols_rt INDEX BY BINARY_INTEGER;
   loadtab tab_tabtype;
   FUNCTION version RETURN VARCHAR2
   IS
   BEGIN
      RETURN '7.09';
   END;

--// Private Modules //--

   --// For Dynamic SQL operations; currently unused. //--
   PROCEDURE initcur (cur_inout IN OUT INTEGER)
   IS
   BEGIN
      IF NOT DBMS_SQL.IS_OPEN (cur_inout)
      THEN
         cur_inout := DBMS_SQL.OPEN_CURSOR;
      END IF;
   EXCEPTION
      WHEN invalid_cursor
      THEN
         cur_inout := DBMS_SQL.OPEN_CURSOR;
   END;

   PROCEDURE start_program (nm IN VARCHAR2, msg IN VARCHAR2 := NULL) IS
   BEGIN
      g_progname := nm;
      IF PLVxmn.traceactive (nm, PLVxmn.l_start)
      THEN
         PLVxmn.trace (nm, PLVxmn.l_start, msg, override => TRUE);
      END IF;
   END;

   PROCEDURE end_program IS
   BEGIN
      g_progname := NULL;
   END;

--// Cursor management procedures //--

   --// Open the cursors with some options. //--
   PROCEDURE open_compforpky_cur (
      employee_id_in IN employee.employee_id%TYPE,
      close_if_open IN BOOLEAN := TRUE
      )
   IS
      v_close BOOLEAN := NVL (close_if_open, TRUE);
      v_open BOOLEAN := TRUE;
   BEGIN
      start_program ('open_compforpky_cur');

      IF compforpky_cur%ISOPEN AND v_close
      THEN
         CLOSE compforpky_cur;
      ELSIF compforpky_cur%ISOPEN AND NOT v_close
      THEN
         v_open := FALSE;
      END IF;

      IF v_open
      THEN
          OPEN compforpky_cur (
             employee_id_in
             );
      END IF;

      end_program;
   END;

   PROCEDURE open_compbypky_cur (
      close_if_open IN BOOLEAN := TRUE
      )
   IS
      v_close BOOLEAN := NVL (close_if_open, TRUE);
      v_open BOOLEAN := TRUE;
   BEGIN
      IF compbypky_cur%ISOPEN AND v_close
      THEN
         CLOSE compbypky_cur;
      ELSIF compbypky_cur%ISOPEN AND NOT v_close
      THEN
         v_open := FALSE;
      END IF;

      IF v_open
      THEN
         OPEN compbypky_cur;
      END IF;
   END;

   PROCEDURE open_emp_dept_lookup_comp_cur (
      department_id_in IN employee.department_id%TYPE,
      close_if_open IN BOOLEAN := TRUE
      )
   IS
      v_close BOOLEAN := NVL (close_if_open, TRUE);
      v_open BOOLEAN := TRUE;
   BEGIN
      IF emp_dept_lookup_comp_cur%ISOPEN AND v_close
      THEN
         CLOSE emp_dept_lookup_comp_cur;
      ELSIF emp_dept_lookup_comp_cur%ISOPEN AND NOT v_close
      THEN
         v_open := FALSE;
      END IF;

      IF v_open
      THEN
         OPEN emp_dept_lookup_comp_cur (
            department_id_in
            );
      END IF;
   END;

   PROCEDURE open_emp_job_lookup_comp_cur (
      job_id_in IN employee.job_id%TYPE,
      close_if_open IN BOOLEAN := TRUE
      )
   IS
      v_close BOOLEAN := NVL (close_if_open, TRUE);
      v_open BOOLEAN := TRUE;
   BEGIN
      IF emp_job_lookup_comp_cur%ISOPEN AND v_close
      THEN
         CLOSE emp_job_lookup_comp_cur;
      ELSIF emp_job_lookup_comp_cur%ISOPEN AND NOT v_close
      THEN
         v_open := FALSE;
      END IF;

      IF v_open
      THEN
         OPEN emp_job_lookup_comp_cur (
            job_id_in
            );
      END IF;
   END;

   PROCEDURE open_emp_mgr_lookup_comp_cur (
      manager_id_in IN employee.manager_id%TYPE,
      close_if_open IN BOOLEAN := TRUE
      )
   IS
      v_close BOOLEAN := NVL (close_if_open, TRUE);
      v_open BOOLEAN := TRUE;
   BEGIN
      IF emp_mgr_lookup_comp_cur%ISOPEN AND v_close
      THEN
         CLOSE emp_mgr_lookup_comp_cur;
      ELSIF emp_mgr_lookup_comp_cur%ISOPEN AND NOT v_close
      THEN
         v_open := FALSE;
      END IF;

      IF v_open
      THEN
         OPEN emp_mgr_lookup_comp_cur (
            manager_id_in
            );
      END IF;
   END;
   --// Open the cursors with some options. //--
   PROCEDURE open_nameforpky_cur (
      employee_id_in IN employee.employee_id%TYPE,
      close_if_open IN BOOLEAN := TRUE
      )
   IS
      v_close BOOLEAN := NVL (close_if_open, TRUE);
      v_open BOOLEAN := TRUE;
   BEGIN
      start_program ('open_nameforpky_cur');

      IF nameforpky_cur%ISOPEN AND v_close
      THEN
         CLOSE nameforpky_cur;
      ELSIF nameforpky_cur%ISOPEN AND NOT v_close
      THEN
         v_open := FALSE;
      END IF;

      IF v_open
      THEN
          OPEN nameforpky_cur (
             employee_id_in
             );
      END IF;

      end_program;
   END;

   PROCEDURE open_namebypky_cur (
      close_if_open IN BOOLEAN := TRUE
      )
   IS
      v_close BOOLEAN := NVL (close_if_open, TRUE);
      v_open BOOLEAN := TRUE;
   BEGIN
      IF namebypky_cur%ISOPEN AND v_close
      THEN
         CLOSE namebypky_cur;
      ELSIF namebypky_cur%ISOPEN AND NOT v_close
      THEN
         v_open := FALSE;
      END IF;

      IF v_open
      THEN
         OPEN namebypky_cur;
      END IF;
   END;

   PROCEDURE open_emp_dept_lookup_name_cur (
      department_id_in IN employee.department_id%TYPE,
      close_if_open IN BOOLEAN := TRUE
      )
   IS
      v_close BOOLEAN := NVL (close_if_open, TRUE);
      v_open BOOLEAN := TRUE;
   BEGIN
      IF emp_dept_lookup_name_cur%ISOPEN AND v_close
      THEN
         CLOSE emp_dept_lookup_name_cur;
      ELSIF emp_dept_lookup_name_cur%ISOPEN AND NOT v_close
      THEN
         v_open := FALSE;
      END IF;

      IF v_open
      THEN
         OPEN emp_dept_lookup_name_cur (
            department_id_in
            );
      END IF;
   END;

   PROCEDURE open_emp_job_lookup_name_cur (
      job_id_in IN employee.job_id%TYPE,
      close_if_open IN BOOLEAN := TRUE
      )
   IS
      v_close BOOLEAN := NVL (close_if_open, TRUE);
      v_open BOOLEAN := TRUE;
   BEGIN
      IF emp_job_lookup_name_cur%ISOPEN AND v_close
      THEN
         CLOSE emp_job_lookup_name_cur;
      ELSIF emp_job_lookup_name_cur%ISOPEN AND NOT v_close
      THEN
         v_open := FALSE;
      END IF;

      IF v_open
      THEN
         OPEN emp_job_lookup_name_cur (
            job_id_in
            );
      END IF;
   END;

   PROCEDURE open_emp_mgr_lookup_name_cur (
      manager_id_in IN employee.manager_id%TYPE,
      close_if_open IN BOOLEAN := TRUE
      )
   IS
      v_close BOOLEAN := NVL (close_if_open, TRUE);
      v_open BOOLEAN := TRUE;
   BEGIN
      IF emp_mgr_lookup_name_cur%ISOPEN AND v_close
      THEN
         CLOSE emp_mgr_lookup_name_cur;
      ELSIF emp_mgr_lookup_name_cur%ISOPEN AND NOT v_close
      THEN
         v_open := FALSE;
      END IF;

      IF v_open
      THEN
         OPEN emp_mgr_lookup_name_cur (
            manager_id_in
            );
      END IF;
   END;
   --// Open the cursors with some options. //--
   PROCEDURE open_allforpky_cur (
      employee_id_in IN employee.employee_id%TYPE,
      close_if_open IN BOOLEAN := TRUE
      )
   IS
      v_close BOOLEAN := NVL (close_if_open, TRUE);
      v_open BOOLEAN := TRUE;
   BEGIN
      start_program ('open_allforpky_cur');

      IF allforpky_cur%ISOPEN AND v_close
      THEN
         CLOSE allforpky_cur;
      ELSIF allforpky_cur%ISOPEN AND NOT v_close
      THEN
         v_open := FALSE;
      END IF;

      IF v_open
      THEN
          OPEN allforpky_cur (
             employee_id_in
             );
      END IF;

      end_program;
   END;

   PROCEDURE open_allbypky_cur (
      close_if_open IN BOOLEAN := TRUE
      )
   IS
      v_close BOOLEAN := NVL (close_if_open, TRUE);
      v_open BOOLEAN := TRUE;
   BEGIN
      IF allbypky_cur%ISOPEN AND v_close
      THEN
         CLOSE allbypky_cur;
      ELSIF allbypky_cur%ISOPEN AND NOT v_close
      THEN
         v_open := FALSE;
      END IF;

      IF v_open
      THEN
         OPEN allbypky_cur;
      END IF;
   END;

   PROCEDURE open_emp_dept_lookup_all_cur (
      department_id_in IN employee.department_id%TYPE,
      close_if_open IN BOOLEAN := TRUE
      )
   IS
      v_close BOOLEAN := NVL (close_if_open, TRUE);
      v_open BOOLEAN := TRUE;
   BEGIN
      IF emp_dept_lookup_all_cur%ISOPEN AND v_close
      THEN
         CLOSE emp_dept_lookup_all_cur;
      ELSIF emp_dept_lookup_all_cur%ISOPEN AND NOT v_close
      THEN
         v_open := FALSE;
      END IF;

      IF v_open
      THEN
         OPEN emp_dept_lookup_all_cur (
            department_id_in
            );
      END IF;
   END;

   PROCEDURE open_emp_job_lookup_all_cur (
      job_id_in IN employee.job_id%TYPE,
      close_if_open IN BOOLEAN := TRUE
      )
   IS
      v_close BOOLEAN := NVL (close_if_open, TRUE);
      v_open BOOLEAN := TRUE;
   BEGIN
      IF emp_job_lookup_all_cur%ISOPEN AND v_close
      THEN
         CLOSE emp_job_lookup_all_cur;
      ELSIF emp_job_lookup_all_cur%ISOPEN AND NOT v_close
      THEN
         v_open := FALSE;
      END IF;

      IF v_open
      THEN
         OPEN emp_job_lookup_all_cur (
            job_id_in
            );
      END IF;
   END;

   PROCEDURE open_emp_mgr_lookup_all_cur (
      manager_id_in IN employee.manager_id%TYPE,
      close_if_open IN BOOLEAN := TRUE
      )
   IS
      v_close BOOLEAN := NVL (close_if_open, TRUE);
      v_open BOOLEAN := TRUE;
   BEGIN
      IF emp_mgr_lookup_all_cur%ISOPEN AND v_close
      THEN
         CLOSE emp_mgr_lookup_all_cur;
      ELSIF emp_mgr_lookup_all_cur%ISOPEN AND NOT v_close
      THEN
         v_open := FALSE;
      END IF;

      IF v_open
      THEN
         OPEN emp_mgr_lookup_all_cur (
            manager_id_in
            );
      END IF;
   END;

   --// Close the cursors if they are open. //--
   PROCEDURE close_compforpky_cur
   IS BEGIN
      IF compforpky_cur%ISOPEN
      THEN
         CLOSE compforpky_cur;
      END IF;
   END;

   PROCEDURE close_compbypky_cur
   IS BEGIN
      IF compbypky_cur%ISOPEN
      THEN
         CLOSE compbypky_cur;
      END IF;
   END;

   PROCEDURE close_emp_dept_lookup_comp_cur
   IS BEGIN
      IF emp_dept_lookup_comp_cur%ISOPEN
      THEN
         CLOSE emp_dept_lookup_comp_cur;
      END IF;
   END;

   PROCEDURE close_emp_job_lookup_comp_cur
   IS BEGIN
      IF emp_job_lookup_comp_cur%ISOPEN
      THEN
         CLOSE emp_job_lookup_comp_cur;
      END IF;
   END;

   PROCEDURE close_emp_mgr_lookup_comp_cur
   IS BEGIN
      IF emp_mgr_lookup_comp_cur%ISOPEN
      THEN
         CLOSE emp_mgr_lookup_comp_cur;
      END IF;
   END;

   PROCEDURE close_nameforpky_cur
   IS BEGIN
      IF nameforpky_cur%ISOPEN
      THEN
         CLOSE nameforpky_cur;
      END IF;
   END;

   PROCEDURE close_namebypky_cur
   IS BEGIN
      IF namebypky_cur%ISOPEN
      THEN
         CLOSE namebypky_cur;
      END IF;
   END;

   PROCEDURE close_emp_dept_lookup_name_cur
   IS BEGIN
      IF emp_dept_lookup_name_cur%ISOPEN
      THEN
         CLOSE emp_dept_lookup_name_cur;
      END IF;
   END;

   PROCEDURE close_emp_job_lookup_name_cur
   IS BEGIN
      IF emp_job_lookup_name_cur%ISOPEN
      THEN
         CLOSE emp_job_lookup_name_cur;
      END IF;
   END;

   PROCEDURE close_emp_mgr_lookup_name_cur
   IS BEGIN
      IF emp_mgr_lookup_name_cur%ISOPEN
      THEN
         CLOSE emp_mgr_lookup_name_cur;
      END IF;
   END;

   PROCEDURE close_allforpky_cur
   IS BEGIN
      IF allforpky_cur%ISOPEN
      THEN
         CLOSE allforpky_cur;
      END IF;
   END;

   PROCEDURE close_allbypky_cur
   IS BEGIN
      IF allbypky_cur%ISOPEN
      THEN
         CLOSE allbypky_cur;
      END IF;
   END;

   PROCEDURE close_emp_dept_lookup_all_cur
   IS BEGIN
      IF emp_dept_lookup_all_cur%ISOPEN
      THEN
         CLOSE emp_dept_lookup_all_cur;
      END IF;
   END;

   PROCEDURE close_emp_job_lookup_all_cur
   IS BEGIN
      IF emp_job_lookup_all_cur%ISOPEN
      THEN
         CLOSE emp_job_lookup_all_cur;
      END IF;
   END;

   PROCEDURE close_emp_mgr_lookup_all_cur
   IS BEGIN
      IF emp_mgr_lookup_all_cur%ISOPEN
      THEN
         CLOSE emp_mgr_lookup_all_cur;
      END IF;
   END;

   PROCEDURE closeall
   IS
   BEGIN
      close_compforpky_cur;
      close_compbypky_cur;
      close_emp_dept_lookup_comp_cur;
      close_emp_job_lookup_comp_cur;
      close_emp_mgr_lookup_comp_cur;
      close_nameforpky_cur;
      close_namebypky_cur;
      close_emp_dept_lookup_name_cur;
      close_emp_job_lookup_name_cur;
      close_emp_mgr_lookup_name_cur;
      close_allforpky_cur;
      close_allbypky_cur;
      close_emp_dept_lookup_all_cur;
      close_emp_job_lookup_all_cur;
      close_emp_mgr_lookup_all_cur;
   END;

--// Functions returning Cursor Variables for each cursor //--

   --// All columns for all rows //--
   FUNCTION allbypky$cv RETURN employee_cvt
   IS
      retval employee_cvt;
   BEGIN
      OPEN retval FOR
         SELECT
             employee_id,
             last_name,
             first_name,
             middle_initial,
             job_id,
             manager_id,
             hire_date,
             salary,
             commission,
             department_id,
             changed_by,
             changed_on
           FROM employee
          ORDER BY
            employee_id
         ;
      RETURN retval;
   END;

   --// All columns for one row //--
   FUNCTION allforpky$cv (
      employee_id_in IN employee.employee_id%TYPE
      )
   RETURN employee_cvt
   IS
      retval employee_cvt;
   BEGIN
      OPEN retval FOR
         SELECT
             employee_id,
             last_name,
             first_name,
             middle_initial,
             job_id,
             manager_id,
             hire_date,
             salary,
             commission,
             department_id,
             changed_by,
             changed_on
           FROM employee
          WHERE
            employee_id = allforpky$cv.employee_id_in
         ;
      RETURN retval;
   END;

   --// For each foreign key.... //--
   FUNCTION emp_dept_lookup_all$cv (
      department_id_in IN employee.department_id%TYPE
      )
   RETURN employee_cvt
   IS
      retval employee_cvt;
   BEGIN
      OPEN retval FOR
         SELECT
             employee_id,
             last_name,
             first_name,
             middle_initial,
             job_id,
             manager_id,
             hire_date,
             salary,
             commission,
             department_id,
             changed_by,
             changed_on
           FROM employee
          WHERE
             department_id = emp_dept_lookup_all$cv.department_id_in
             ;
      RETURN retval;
   END;

   --// For each foreign key.... //--
   FUNCTION emp_job_lookup_all$cv (
      job_id_in IN employee.job_id%TYPE
      )
   RETURN employee_cvt
   IS
      retval employee_cvt;
   BEGIN
      OPEN retval FOR
         SELECT
             employee_id,
             last_name,
             first_name,
             middle_initial,
             job_id,
             manager_id,
             hire_date,
             salary,
             commission,
             department_id,
             changed_by,
             changed_on
           FROM employee
          WHERE
             job_id = emp_job_lookup_all$cv.job_id_in
             ;
      RETURN retval;
   END;

   --// For each foreign key.... //--
   FUNCTION emp_mgr_lookup_all$cv (
      manager_id_in IN employee.manager_id%TYPE
      )
   RETURN employee_cvt
   IS
      retval employee_cvt;
   BEGIN
      OPEN retval FOR
         SELECT
             employee_id,
             last_name,
             first_name,
             middle_initial,
             job_id,
             manager_id,
             hire_date,
             salary,
             commission,
             department_id,
             changed_by,
             changed_on
           FROM employee
          WHERE
             manager_id = emp_mgr_lookup_all$cv.manager_id_in
             ;
      RETURN retval;
   END;

--// Emulate aggregate-level record operations. //--

   FUNCTION recseq (rec1 IN allcols_rt, rec2 IN allcols_rt)
   RETURN BOOLEAN
   IS
      unequal_records EXCEPTION;
      retval BOOLEAN;
   BEGIN
      retval := rec1.employee_id = rec2.employee_id OR
         (rec1.employee_id IS NULL AND rec2.employee_id IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.last_name = rec2.last_name OR
         (rec1.last_name IS NULL AND rec2.last_name IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.first_name = rec2.first_name OR
         (rec1.first_name IS NULL AND rec2.first_name IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.middle_initial = rec2.middle_initial OR
         (rec1.middle_initial IS NULL AND rec2.middle_initial IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.job_id = rec2.job_id OR
         (rec1.job_id IS NULL AND rec2.job_id IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.manager_id = rec2.manager_id OR
         (rec1.manager_id IS NULL AND rec2.manager_id IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.hire_date = rec2.hire_date OR
         (rec1.hire_date IS NULL AND rec2.hire_date IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.salary = rec2.salary OR
         (rec1.salary IS NULL AND rec2.salary IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.commission = rec2.commission OR
         (rec1.commission IS NULL AND rec2.commission IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.department_id = rec2.department_id OR
         (rec1.department_id IS NULL AND rec2.department_id IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.changed_by = rec2.changed_by OR
         (rec1.changed_by IS NULL AND rec2.changed_by IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.changed_on = rec2.changed_on OR
         (rec1.changed_on IS NULL AND rec2.changed_on IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      RETURN TRUE;
   EXCEPTION
      WHEN unequal_records THEN RETURN FALSE;
   END;

   FUNCTION recseq (rec1 IN pky_rt, rec2 IN pky_rt)
   RETURN BOOLEAN
   IS
      unequal_records EXCEPTION;
      retval BOOLEAN;
   BEGIN
      retval := rec1.employee_id = rec2.employee_id OR
         (rec1.employee_id IS NULL AND rec2.employee_id IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      RETURN TRUE;
   EXCEPTION
      WHEN unequal_records THEN RETURN FALSE;
   END;

--// Is the primary key NOT NULL? //--

   FUNCTION isnullpky (
      rec_in IN allcols_rt
      )
   RETURN BOOLEAN
   IS
   BEGIN
      RETURN
         rec_in.employee_id IS NULL
         ;
   END;

   FUNCTION isnullpky (
      rec_in IN pky_rt
      )
   RETURN BOOLEAN
   IS
   BEGIN
      RETURN
         rec_in.employee_id IS NULL
         ;
   END;

--// Query Processing --//

   FUNCTION onerow_internal (
      employee_id_in IN employee.employee_id%TYPE
      )
   RETURN allcols_rt
   IS
      CURSOR onerow_cur
      IS
         SELECT
            employee_id,
            last_name,
            first_name,
            middle_initial,
            job_id,
            manager_id,
            hire_date,
            salary,
            commission,
            department_id,
            changed_by,
            changed_on
           FROM employee
          WHERE
             employee_id = employee_id_in
      ;
      onerow_rec allcols_rt;
   BEGIN
      OPEN onerow_cur;
      FETCH onerow_cur INTO onerow_rec;
      CLOSE onerow_cur;
      RETURN onerow_rec;
   END onerow_internal;

   FUNCTION onerow (
      employee_id_in IN employee.employee_id%TYPE
      )
   RETURN allcols_rt
   IS
      retval allcols_rt;
   BEGIN
      IF loadtab.EXISTS (employee_id_in)
      THEN
         retval := loadtab(employee_id_in);
      ELSE
         retval := onerow_internal (employee_id_in);
         IF retval.employee_id IS NOT NULL
         THEN
            --// Load the data into the table. --//
            loadtab(employee_id_in) := retval;
         END IF;
      END IF;
      RETURN retval;
   END onerow;

   FUNCTION onerow$cv (
      employee_id_in IN employee.employee_id%TYPE
      )
   RETURN employee_cvt
   IS
      retval employee_cvt;
   BEGIN
      OPEN retval FOR
         SELECT
            employee_id,
            last_name,
            first_name,
            middle_initial,
            job_id,
            manager_id,
            hire_date,
            salary,
            commission,
            department_id,
            changed_by,
            changed_on
           FROM employee
          WHERE
             employee_id = employee_id_in
      ;
   END;


   FUNCTION i_employee_name$pky (
      last_name_in IN employee.last_name%TYPE,
      first_name_in IN employee.first_name%TYPE,
      middle_initial_in IN employee.middle_initial%TYPE
      )
      RETURN pky_rt
   IS
      CURSOR getpky_cur
      IS
         SELECT
            employee_id
           FROM employee
          WHERE
            last_name = i_employee_name$pky.last_name_in AND
            first_name = i_employee_name$pky.first_name_in AND
            middle_initial = i_employee_name$pky.middle_initial_in
            ;

      getpky_rec getpky_cur%ROWTYPE;
      retval pky_rt;
   BEGIN
      OPEN getpky_cur;
      FETCH getpky_cur INTO getpky_rec;
      IF getpky_cur%FOUND
      THEN
         retval.employee_id := getpky_rec.employee_id;
      END IF;
      CLOSE getpky_cur;
      RETURN retval;
   END i_employee_name$pky;

   FUNCTION i_employee_name$row (
      last_name_in IN employee.last_name%TYPE,
      first_name_in IN employee.first_name%TYPE,
      middle_initial_in IN employee.middle_initial%TYPE
      )
   RETURN allcols_rt
   IS
      CURSOR onerow_cur
      IS
         SELECT
            employee_id,
            last_name,
            first_name,
            middle_initial,
            job_id,
            manager_id,
            hire_date,
            salary,
            commission,
            department_id,
            changed_by,
            changed_on
           FROM employee
          WHERE
             last_name = i_employee_name$row.last_name_in AND
             first_name = i_employee_name$row.first_name_in AND
             middle_initial = i_employee_name$row.middle_initial_in
             ;
      onerow_rec allcols_rt;
   BEGIN
      OPEN onerow_cur;
      FETCH onerow_cur INTO onerow_rec;
      CLOSE onerow_cur;
      RETURN onerow_rec;
   END i_employee_name$row;

   FUNCTION i_employee_name$val (
      employee_id_in IN employee.employee_id%TYPE
      )
   RETURN i_employee_name_rt
   IS
      v_onerow allcols_rt;
      retval i_employee_name_rt;
   BEGIN
      v_onerow := onerow (
         employee_id_in
         );

      retval.last_name := v_onerow.last_name;
      retval.first_name := v_onerow.first_name;
      retval.middle_initial := v_onerow.middle_initial;

      RETURN retval;
   END i_employee_name$val;

   FUNCTION i_employee_name$pcv (
      last_name_in IN employee.last_name%TYPE,
      first_name_in IN employee.first_name%TYPE,
      middle_initial_in IN employee.middle_initial%TYPE
      )
      RETURN pky_cvt
   IS
      retval pky_cvt;
   BEGIN
      OPEN retval FOR
         SELECT
            employee_id
           FROM employee
          WHERE
            last_name = i_employee_name$pcv.last_name_in AND
            first_name = i_employee_name$pcv.first_name_in AND
            middle_initial = i_employee_name$pcv.middle_initial_in
            ;
   END;

   FUNCTION i_employee_name$vcv (
      employee_id_in IN employee.employee_id%TYPE
      )
   RETURN i_employee_name_cvt
   IS
      retval i_employee_name_cvt;
   BEGIN
      OPEN retval FOR
         SELECT
              last_name,
              first_name,
              middle_initial
           FROM employee
          WHERE
             employee_id = employee_id_in
      ;
   END;

   FUNCTION i_employee_name$rcv (
      last_name_in IN employee.last_name%TYPE,
      first_name_in IN employee.first_name%TYPE,
      middle_initial_in IN employee.middle_initial%TYPE
      )
   RETURN employee_cvt
   IS
      retval employee_cvt;
   BEGIN
      OPEN retval FOR
         SELECT
            employee_id,
            last_name,
            first_name,
            middle_initial,
            job_id,
            manager_id,
            hire_date,
            salary,
            commission,
            department_id,
            changed_by,
            changed_on
           FROM employee
          WHERE
             last_name = i_employee_name$rcv.last_name_in AND
             first_name = i_employee_name$rcv.first_name_in AND
             middle_initial = i_employee_name$rcv.middle_initial_in
             ;
   END;

   --// For each update column ... //--

   FUNCTION hire_date$val (
      employee_id_in IN employee.employee_id%TYPE
      )
   RETURN employee.hire_date%TYPE
   IS
      CURSOR onecol_cur
      IS
         SELECT hire_date
           FROM employee
          WHERE
             employee_id = employee_id_in
         ;
      retval employee.hire_date%TYPE;
   BEGIN
      OPEN onecol_cur;
      FETCH onecol_cur INTO retval;
      CLOSE onecol_cur;
      RETURN retval;
   END hire_date$val;
   --// For each update column ... //--

   FUNCTION salary$val (
      employee_id_in IN employee.employee_id%TYPE
      )
   RETURN employee.salary%TYPE
   IS
      CURSOR onecol_cur
      IS
         SELECT salary
           FROM employee
          WHERE
             employee_id = employee_id_in
         ;
      retval employee.salary%TYPE;
   BEGIN
      OPEN onecol_cur;
      FETCH onecol_cur INTO retval;
      CLOSE onecol_cur;
      RETURN retval;
   END salary$val;

   --// Count of all rows in table and for each foreign key. //--
   FUNCTION rowcount RETURN INTEGER
   IS
      retval INTEGER;
   BEGIN
      SELECT COUNT(*) INTO retval FROM employee;
      RETURN retval;
   END;

   FUNCTION pkyrowcount (
      employee_id_in IN employee.employee_id%TYPE
      )
      RETURN INTEGER
   IS
      retval INTEGER;
   BEGIN
      SELECT COUNT(*)
        INTO retval
        FROM employee
       WHERE
         employee_id = employee_id_in
         ;
      RETURN retval;
   END;

   FUNCTION emp_dept_lookuprowcount (
      department_id_in IN employee.department_id%TYPE
      )
      RETURN INTEGER
   IS
      retval INTEGER;
   BEGIN
      SELECT COUNT(*) INTO retval
        FROM employee
       WHERE
          department_id = emp_dept_lookuprowcount.department_id_in
          ;
      RETURN retval;
   END;
   FUNCTION emp_job_lookuprowcount (
      job_id_in IN employee.job_id%TYPE
      )
      RETURN INTEGER
   IS
      retval INTEGER;
   BEGIN
      SELECT COUNT(*) INTO retval
        FROM employee
       WHERE
          job_id = emp_job_lookuprowcount.job_id_in
          ;
      RETURN retval;
   END;
   FUNCTION emp_mgr_lookuprowcount (
      manager_id_in IN employee.manager_id%TYPE
      )
      RETURN INTEGER
   IS
      retval INTEGER;
   BEGIN
      SELECT COUNT(*) INTO retval
        FROM employee
       WHERE
          manager_id = emp_mgr_lookuprowcount.manager_id_in
          ;
      RETURN retval;
   END;

   PROCEDURE lookup_fkydescs (
      --// Foreign key columns for emp_dept_lookup --//
      department_id_in IN employee.department_id%TYPE,
      emp_dept_lookup_out OUT te_department.i_department_name_rt,
      --// Foreign key columns for emp_job_lookup --//
      job_id_in IN employee.job_id%TYPE,
      emp_job_lookup_out OUT te_job.i_job_function_rt,
      --// Foreign key columns for emp_mgr_lookup --//
      manager_id_in IN employee.manager_id%TYPE,
      emp_mgr_lookup_out OUT te_employee.i_employee_name_rt,
      record_error BOOLEAN := TRUE
      )
   IS
   BEGIN
      emp_dept_lookup_out :=
         te_department.i_department_name$val (
            department_id_in
            );
      emp_job_lookup_out :=
         te_job.i_job_function$val (
            job_id_in
            );
      emp_mgr_lookup_out :=
         te_employee.i_employee_name$val (
            manager_id_in
            );
   EXCEPTION
      WHEN OTHERS
      THEN
         IF record_error
         THEN
            plvexc.recnstop;
         END IF;
         RAISE;
   END lookup_fkydescs;

   --// Generate the next primary key: single column PKYs only --//
   FUNCTION nextpky RETURN employee.employee_id%TYPE
   IS
      retval employee.employee_id%TYPE;
   BEGIN
      SELECT EMPLOYEE_ID_SEQ.NEXTVAL INTO retval FROM dual;
      RETURN retval;
   END;

--// Check Constraint Validation --//

   --// Check Constraint: DEPARTMENT_ID > 0 AND (salary > 0 OR salary IS NULL) --//
   FUNCTION employee$complex$chk (
      department_id_in IN employee.department_id%TYPE,
      salary_in IN employee.salary%TYPE
      ) RETURN BOOLEAN
   IS
   BEGIN
      RETURN (DEPARTMENT_ID_in > 0 AND (SALARY_in > 0 OR SALARY_in IS NULL));
   END employee$complex$chk;

   --// Check Constraint: DEPARTMENT_ID IS NOT NULL --//
   FUNCTION notnull_department_id$chk (
      department_id_in IN employee.department_id%TYPE
      ) RETURN BOOLEAN
   IS
   BEGIN
      RETURN (DEPARTMENT_ID_in IS NOT NULL);
   END notnull_department_id$chk;

   --// Check Constraint: EMPLOYEE_ID IS NOT NULL --//
   FUNCTION notnull_employee_id$chk (
      employee_id_in IN employee.employee_id%TYPE
      ) RETURN BOOLEAN
   IS
   BEGIN
      RETURN (EMPLOYEE_ID_in IS NOT NULL);
   END notnull_employee_id$chk;

   --// Check Constraint: "HIRE_DATE" IS NOT NULL --//
   FUNCTION sys_c002591$chk (
      hire_date_in IN employee.hire_date%TYPE
      ) RETURN BOOLEAN
   IS
   BEGIN
      RETURN (HIRE_DATE_in IS NOT NULL);
   END sys_c002591$chk;

   --// Check Constraint: "CHANGED_BY" IS NOT NULL --//
   FUNCTION sys_c002594$chk (
      changed_by_in IN employee.changed_by%TYPE
      ) RETURN BOOLEAN
   IS
   BEGIN
      RETURN (CHANGED_BY_in IS NOT NULL);
   END sys_c002594$chk;

   --// Check Constraint: "CHANGED_ON" IS NOT NULL --//
   FUNCTION sys_c002595$chk (
      changed_on_in IN employee.changed_on%TYPE
      ) RETURN BOOLEAN
   IS
   BEGIN
      RETURN (CHANGED_ON_in IS NOT NULL);
   END sys_c002595$chk;

   PROCEDURE validate (
      employee_id_in IN employee.employee_id%TYPE,
      hire_date_in IN employee.hire_date%TYPE,
      salary_in IN employee.salary%TYPE,
      department_id_in IN employee.department_id%TYPE,
      changed_by_in IN employee.changed_by%TYPE,
      changed_on_in IN employee.changed_on%TYPE,
      record_error IN BOOLEAN := TRUE
      )
   IS
   BEGIN
      IF NOT employee$complex$chk (
         department_id_in,
         salary_in
         )
      THEN
         --//** General mechanism! //--
         plvexc.raise (-20000, 'ora-2290: check constraint (employee$complex) failed!');
      END IF;
      IF NOT notnull_department_id$chk (
         department_id_in
         )
      THEN
         plvexc.raise (-20000, 'value of department_id cannot be null.');
      END IF;
      IF NOT notnull_employee_id$chk (
         employee_id_in
         )
      THEN
         plvexc.raise (-20000, 'value of employee_id cannot be null.');
      END IF;
      IF NOT sys_c002591$chk (
         hire_date_in
         )
      THEN
         --//** General mechanism! //--
         plvexc.raise (-20000, 'ora-2290: check constraint (sys_c002591) failed!');
      END IF;
      IF NOT sys_c002594$chk (
         changed_by_in
         )
      THEN
         --//** General mechanism! //--
         plvexc.raise (-20000, 'ora-2290: check constraint (sys_c002594) failed!');
      END IF;
      IF NOT sys_c002595$chk (
         changed_on_in
         )
      THEN
         --//** General mechanism! //--
         plvexc.raise (-20000, 'ora-2290: check constraint (sys_c002595) failed!');
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF record_error
         THEN
            plvexc.recnstop;
         END IF;
         RAISE;
   END validate;

   PROCEDURE validate (
      rec_in IN allcols_rt,
      record_error IN BOOLEAN := TRUE
      )
   IS
   BEGIN
      validate (
         rec_in.employee_id,
         rec_in.hire_date,
         rec_in.salary,
         rec_in.department_id,
         rec_in.changed_by,
         rec_in.changed_on,
         record_error
         );
   END validate;
--// Update Processing --//

   PROCEDURE reset$frc IS
   BEGIN
      frcflg := emptyfrc;
   END reset$frc;

   FUNCTION last_name$frc (last_name_in IN employee.last_name%TYPE DEFAULT NULL)
      RETURN employee.last_name%TYPE
   IS
   BEGIN
      frcflg.last_name := c_set;
      RETURN last_name_in;
   END last_name$frc;

   FUNCTION first_name$frc (first_name_in IN employee.first_name%TYPE DEFAULT NULL)
      RETURN employee.first_name%TYPE
   IS
   BEGIN
      frcflg.first_name := c_set;
      RETURN first_name_in;
   END first_name$frc;

   FUNCTION middle_initial$frc (middle_initial_in IN employee.middle_initial%TYPE DEFAULT NULL)
      RETURN employee.middle_initial%TYPE
   IS
   BEGIN
      frcflg.middle_initial := c_set;
      RETURN middle_initial_in;
   END middle_initial$frc;

   FUNCTION job_id$frc (job_id_in IN employee.job_id%TYPE DEFAULT NULL)
      RETURN employee.job_id%TYPE
   IS
   BEGIN
      frcflg.job_id := c_set;
      RETURN job_id_in;
   END job_id$frc;

   FUNCTION manager_id$frc (manager_id_in IN employee.manager_id%TYPE DEFAULT NULL)
      RETURN employee.manager_id%TYPE
   IS
   BEGIN
      frcflg.manager_id := c_set;
      RETURN manager_id_in;
   END manager_id$frc;

   FUNCTION hire_date$frc (hire_date_in IN employee.hire_date%TYPE DEFAULT NULL)
      RETURN employee.hire_date%TYPE
   IS
   BEGIN
      frcflg.hire_date := c_set;
      RETURN hire_date_in;
   END hire_date$frc;

   FUNCTION salary$frc (salary_in IN employee.salary%TYPE DEFAULT NULL)
      RETURN employee.salary%TYPE
   IS
   BEGIN
      frcflg.salary := c_set;
      RETURN salary_in;
   END salary$frc;

   FUNCTION commission$frc (commission_in IN employee.commission%TYPE DEFAULT NULL)
      RETURN employee.commission%TYPE
   IS
   BEGIN
      frcflg.commission := c_set;
      RETURN commission_in;
   END commission$frc;

   FUNCTION department_id$frc (department_id_in IN employee.department_id%TYPE DEFAULT NULL)
      RETURN employee.department_id%TYPE
   IS
   BEGIN
      frcflg.department_id := c_set;
      RETURN department_id_in;
   END department_id$frc;

   FUNCTION changed_by$frc (changed_by_in IN employee.changed_by%TYPE DEFAULT NULL)
      RETURN employee.changed_by%TYPE
   IS
   BEGIN
      frcflg.changed_by := c_set;
      RETURN changed_by_in;
   END changed_by$frc;

   FUNCTION changed_on$frc (changed_on_in IN employee.changed_on%TYPE DEFAULT NULL)
      RETURN employee.changed_on%TYPE
   IS
   BEGIN
      frcflg.changed_on := c_set;
      RETURN changed_on_in;
   END changed_on$frc;

   PROCEDURE upd (
      employee_id_in IN employee.employee_id%TYPE,
      last_name_in IN employee.last_name%TYPE DEFAULT NULL,
      first_name_in IN employee.first_name%TYPE DEFAULT NULL,
      middle_initial_in IN employee.middle_initial%TYPE DEFAULT NULL,
      job_id_in IN employee.job_id%TYPE DEFAULT NULL,
      manager_id_in IN employee.manager_id%TYPE DEFAULT NULL,
      hire_date_in IN employee.hire_date%TYPE DEFAULT NULL,
      salary_in IN employee.salary%TYPE DEFAULT NULL,
      commission_in IN employee.commission%TYPE DEFAULT NULL,
      department_id_in IN employee.department_id%TYPE DEFAULT NULL,
      changed_by_in IN employee.changed_by%TYPE DEFAULT NULL,
      changed_on_in IN employee.changed_on%TYPE DEFAULT NULL,
      rowcount_out OUT INTEGER,
      reset_in IN BOOLEAN DEFAULT TRUE
      )
   IS
   BEGIN
      IF PLVxmn.traceactive ('upd', PLVxmn.l_upd)
      THEN
         PLVxmn.trace ('upd', PLVxmn.l_upd,
            '-employee_id='|| employee_id_in ||
            '-last_name='|| last_name_in ||
            '-first_name='|| first_name_in ||
            '-middle_initial='|| middle_initial_in ||
            '-job_id='|| job_id_in ||
            '-manager_id='|| manager_id_in ||
            '-hire_date='|| hire_date_in ||
            '-salary='|| salary_in ||
            '-commission='|| commission_in ||
            '-department_id='|| department_id_in ||
            '-changed_by='|| changed_by_in ||
            '-changed_on='|| changed_on_in
            , override => TRUE);
      END IF;
      UPDATE employee SET
         last_name = DECODE (frcflg.last_name, c_set, UPPER(last_name_in),
            NVL (UPPER(last_name_in), last_name)),
         first_name = DECODE (frcflg.first_name, c_set, UPPER(first_name_in),
            NVL (UPPER(first_name_in), first_name)),
         middle_initial = DECODE (frcflg.middle_initial, c_set, UPPER(middle_initial_in),
            NVL (UPPER(middle_initial_in), middle_initial)),
         job_id = DECODE (frcflg.job_id, c_set, job_id_in,
            NVL (job_id_in, job_id)),
         manager_id = DECODE (frcflg.manager_id, c_set, manager_id_in,
            NVL (manager_id_in, manager_id)),
         hire_date = DECODE (frcflg.hire_date, c_set, TRUNC(hire_date_in),
            NVL (TRUNC(hire_date_in), hire_date)),
         salary = DECODE (frcflg.salary, c_set, salary_in,
            NVL (salary_in, salary)),
         commission = DECODE (frcflg.commission, c_set, commission_in,
            NVL (commission_in, commission)),
         department_id = DECODE (frcflg.department_id, c_set, department_id_in,
            NVL (department_id_in, department_id)),
         changed_by = DECODE (frcflg.changed_by, c_set, USER,
            NVL (USER, changed_by)),
         changed_on = DECODE (frcflg.changed_on, c_set, SYSDATE,
            NVL (SYSDATE, changed_on))
       WHERE
          employee_id = employee_id_in
         ;
      rowcount_out := SQL%ROWCOUNT;
      IF reset_in THEN reset$frc; END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         plvexc.recnstop;
   END upd;

   --// Record-based Update --//
   PROCEDURE upd (
      rec_in IN allcols_rt,
      rowcount_out OUT INTEGER,
      reset_in IN BOOLEAN DEFAULT TRUE)
   IS
   BEGIN
      upd (
         rec_in.employee_id,
         rec_in.last_name,
         rec_in.first_name,
         rec_in.middle_initial,
         rec_in.job_id,
         rec_in.manager_id,
         rec_in.hire_date,
         rec_in.salary,
         rec_in.commission,
         rec_in.department_id,
         rec_in.changed_by,
         rec_in.changed_on,
         rowcount_out,
         reset_in);
   END upd;

   --// Update procedure for hire_date. --//
   PROCEDURE upd$hire_date (
      employee_id_in IN employee.employee_id%TYPE,
      hire_date_in IN employee.hire_date%TYPE,
      rowcount_out OUT INTEGER
      )
   IS
   BEGIN
      IF PLVxmn.traceactive ('upd$hire_date', PLVxmn.l_upd)
      THEN
         PLVxmn.trace ('upd$hire_date', PLVxmn.l_upd,
            'employee_id='|| employee_id_in
            || 'hire_date='|| hire_date_in
            , override => TRUE);
      END IF;
      UPDATE employee SET hire_date = TRUNC(hire_date_in)
       WHERE
          employee_id = employee_id_in
         ;
      rowcount_out := SQL%ROWCOUNT;
   EXCEPTION
      WHEN OTHERS
      THEN
         plvexc.recnstop;
   END upd$hire_date;

   --// Update procedure for hire_date using records. --//
   PROCEDURE upd$hire_date (
      rec_in IN pky_rt,
      hire_date_in IN employee.hire_date%TYPE,
      rowcount_out OUT INTEGER
      )
   IS
   BEGIN
      upd$hire_date (
         rec_in.employee_id,
         hire_date_in,
         rowcount_out
         );
   END upd$hire_date;

   --// Update procedure for salary. --//
   PROCEDURE upd$salary (
      employee_id_in IN employee.employee_id%TYPE,
      salary_in IN employee.salary%TYPE,
      rowcount_out OUT INTEGER
      )
   IS
   BEGIN
      IF PLVxmn.traceactive ('upd$salary', PLVxmn.l_upd)
      THEN
         PLVxmn.trace ('upd$salary', PLVxmn.l_upd,
            'employee_id='|| employee_id_in
            || 'salary='|| salary_in
            , override => TRUE);
      END IF;
      UPDATE employee SET salary = salary_in
       WHERE
          employee_id = employee_id_in
         ;
      rowcount_out := SQL%ROWCOUNT;
   EXCEPTION
      WHEN OTHERS
      THEN
         plvexc.recnstop;
   END upd$salary;

   --// Update procedure for salary using records. --//
   PROCEDURE upd$salary (
      rec_in IN pky_rt,
      salary_in IN employee.salary%TYPE,
      rowcount_out OUT INTEGER
      )
   IS
   BEGIN
      upd$salary (
         rec_in.employee_id,
         salary_in,
         rowcount_out
         );
   END upd$salary;

--// Insert Processing --//

   --// Initialize record with default values. --//
   FUNCTION initrec (allnull IN BOOLEAN := FALSE) RETURN allcols_rt
   IS
      retval allcols_rt;
   BEGIN
      IF allnull THEN NULL; /* Default values are NULL already. */
      ELSE
         retval.employee_id := NULL;
         retval.last_name := NULL;
         retval.first_name := NULL;
         retval.middle_initial := NULL;
         retval.job_id := NULL;
         retval.manager_id := NULL;
         retval.hire_date := SYSDATE;
         retval.salary := NULL;
         retval.commission := NULL;
         retval.department_id := NULL;
         retval.changed_by := USER;
         retval.changed_on := SYSDATE;
      END IF;
      RETURN retval;
   END;

   --// Initialize record with default values. --//
   PROCEDURE initrec (
      rec_inout IN OUT allcols_rt,
      allnull IN BOOLEAN := FALSE)
   IS
   BEGIN
      rec_inout := initrec;
   END;

   PROCEDURE ins$ins (
      employee_id_in IN employee.employee_id%TYPE,
      last_name_in IN employee.last_name%TYPE DEFAULT NULL,
      first_name_in IN employee.first_name%TYPE DEFAULT NULL,
      middle_initial_in IN employee.middle_initial%TYPE DEFAULT NULL,
      job_id_in IN employee.job_id%TYPE DEFAULT NULL,
      manager_id_in IN employee.manager_id%TYPE DEFAULT NULL,
      hire_date_in IN employee.hire_date%TYPE DEFAULT SYSDATE,
      salary_in IN employee.salary%TYPE DEFAULT NULL,
      commission_in IN employee.commission%TYPE DEFAULT NULL,
      department_id_in IN employee.department_id%TYPE DEFAULT NULL,
      changed_by_in IN employee.changed_by%TYPE DEFAULT USER,
      changed_on_in IN employee.changed_on%TYPE DEFAULT SYSDATE,
      upd_on_dup IN BOOLEAN := FALSE
      )
   IS
   BEGIN
      IF PLVxmn.traceactive ('ins', PLVxmn.l_ins)
      THEN
         PLVxmn.trace ('ins', PLVxmn.l_ins,
            '-employee_id='|| employee_id_in ||
            '-last_name='|| last_name_in ||
            '-first_name='|| first_name_in ||
            '-middle_initial='|| middle_initial_in ||
            '-job_id='|| job_id_in ||
            '-manager_id='|| manager_id_in ||
            '-hire_date='|| hire_date_in ||
            '-salary='|| salary_in ||
            '-commission='|| commission_in ||
            '-department_id='|| department_id_in ||
            '-changed_by='|| changed_by_in ||
            '-changed_on='|| changed_on_in
            , override => TRUE);
      END IF;
      validate (
         employee_id_in,
         TRUNC(hire_date_in),
         salary_in,
         department_id_in,
         USER,
         SYSDATE,
         TRUE
         );
      INSERT INTO employee (
         employee_id
         ,last_name
         ,first_name
         ,middle_initial
         ,job_id
         ,manager_id
         ,hire_date
         ,salary
         ,commission
         ,department_id
         ,changed_by
         ,changed_on
         )
      VALUES (
         employee_id_in
         ,UPPER(last_name_in)
         ,UPPER(first_name_in)
         ,UPPER(middle_initial_in)
         ,job_id_in
         ,manager_id_in
         ,TRUNC(hire_date_in)
         ,salary_in
         ,commission_in
         ,department_id_in
         ,USER
         ,SYSDATE
         );
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX
      THEN
         IF NOT NVL (upd_on_dup, FALSE)
         THEN
            RAISE;
         ELSE
            DECLARE
               v_errm VARCHAR2(2000) := SQLERRM;
               v_rowcount INTEGER;
               dotloc INTEGER;
               leftloc INTEGER;
               c_owner ALL_CONSTRAINTS.OWNER%TYPE;
               c_name ALL_CONSTRAINTS.CONSTRAINT_NAME%TYPE;
            BEGIN
               dotloc := INSTR (v_errm,'.');
               leftloc := INSTR (v_errm,'(');
               c_owner :=SUBSTR (v_errm, leftloc+1, dotloc-leftloc-1);
               c_name := SUBSTR (v_errm, dotloc+1, INSTR (v_errm,')')-dotloc-1);

               --// Duplicate based on primary key //--
               IF 'EMP_PK' = c_name AND 'SCOTT' = c_owner
               THEN
                  upd (
                     employee_id_in,
                     last_name_in,
                     first_name_in,
                     middle_initial_in,
                     job_id_in,
                     manager_id_in,
                     hire_date_in,
                     salary_in,
                     commission_in,
                     department_id_in,
                     changed_by_in,
                     changed_on_in,
                     v_rowcount,
                     FALSE
                     );
               ELSE
                  --// Unique index violation. Cannot recover... //--
                  RAISE;
               END IF;
            END;
         END IF;
      WHEN OTHERS
      THEN
         plvexc.recnstop;
   END ins$ins;

   --// Insert 1: with individual fields and return primary key //--
   PROCEDURE ins (
      last_name_in IN employee.last_name%TYPE DEFAULT NULL,
      first_name_in IN employee.first_name%TYPE DEFAULT NULL,
      middle_initial_in IN employee.middle_initial%TYPE DEFAULT NULL,
      job_id_in IN employee.job_id%TYPE DEFAULT NULL,
      manager_id_in IN employee.manager_id%TYPE DEFAULT NULL,
      hire_date_in IN employee.hire_date%TYPE DEFAULT SYSDATE,
      salary_in IN employee.salary%TYPE DEFAULT NULL,
      commission_in IN employee.commission%TYPE DEFAULT NULL,
      department_id_in IN employee.department_id%TYPE DEFAULT NULL,
      changed_by_in IN employee.changed_by%TYPE DEFAULT USER,
      changed_on_in IN employee.changed_on%TYPE DEFAULT SYSDATE,
      employee_id_out IN OUT employee.employee_id%TYPE,
      upd_on_dup IN BOOLEAN := FALSE
      )
   IS
      v_pky INTEGER := nextpky;
   BEGIN
      ins$ins (
         v_pky,
         last_name_in,
         first_name_in,
         middle_initial_in,
         job_id_in,
         manager_id_in,
         hire_date_in,
         salary_in,
         commission_in,
         department_id_in,
         changed_by_in,
         changed_on_in,
         upd_on_dup
         );
      employee_id_out := v_pky;
   END;

   --// Insert 2: with record, returning primary key. //--
   PROCEDURE ins (
      rec_in IN allcols_rt,
      employee_id_out IN OUT employee.employee_id%TYPE,
      upd_on_dup IN BOOLEAN := FALSE
      )
   IS
      v_pky INTEGER := nextpky;
   BEGIN
      ins$ins (
         v_pky,
         rec_in.last_name,
         rec_in.first_name,
         rec_in.middle_initial,
         rec_in.job_id,
         rec_in.manager_id,
         rec_in.hire_date,
         rec_in.salary,
         rec_in.commission,
         rec_in.department_id,
         rec_in.changed_by,
         rec_in.changed_on,
         upd_on_dup
         );
      employee_id_out := v_pky;
   END;

--// Delete Processing --//

   PROCEDURE del (
      employee_id_in IN employee.employee_id%TYPE,
      rowcount_out OUT INTEGER)
   IS
   BEGIN
      IF PLVxmn.traceactive ('del', PLVxmn.l_del)
      THEN
         PLVxmn.trace ('del', PLVxmn.l_del,
            '-employee_id='|| employee_id_in
            , override => TRUE);
      END IF;
      DELETE FROM employee
       WHERE
          employee_id = employee_id_in
         ;
      rowcount_out := SQL%ROWCOUNT;
      IF SQL%ROWCOUNT > 0
      THEN
         loadtab.DELETE (employee_id_in);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         plvexc.recnstop;
   END del;

   --// Record-based delete --//
   PROCEDURE del
      (rec_in IN pky_rt,
      rowcount_out OUT INTEGER)
   IS
   BEGIN
      del (
         rec_in.employee_id,
         rowcount_out);
   END del;

   PROCEDURE del (rec_in IN allcols_rt,
      rowcount_out OUT INTEGER)
   IS
   BEGIN
      del (
         rec_in.employee_id,
         rowcount_out);
   END del;

   --// Delete all records for foreign key EMP_DEPT_LOOKUP. //--
   PROCEDURE delby_emp_dept_lookup (
      department_id_in IN employee.department_id%TYPE,
      rowcount_out OUT INTEGER
      )
   IS
   BEGIN
      IF PLVxmn.traceactive ('delby_emp_dept_lookup', PLVxmn.l_del)
      THEN
         PLVxmn.trace ('delby_emp_dept_lookup', PLVxmn.l_del,
            '-department_id='|| department_id_in
            , override => TRUE);
      END IF;
      DELETE FROM employee
       WHERE
          department_id = delby_emp_dept_lookup.department_id_in
         ;
      rowcount_out := SQL%ROWCOUNT;
   EXCEPTION
      WHEN OTHERS
      THEN
         plvexc.recnstop;
   END delby_emp_dept_lookup;

   --// Delete all records for foreign key EMP_JOB_LOOKUP. //--
   PROCEDURE delby_emp_job_lookup (
      job_id_in IN employee.job_id%TYPE,
      rowcount_out OUT INTEGER
      )
   IS
   BEGIN
      IF PLVxmn.traceactive ('delby_emp_job_lookup', PLVxmn.l_del)
      THEN
         PLVxmn.trace ('delby_emp_job_lookup', PLVxmn.l_del,
            '-job_id='|| job_id_in
            , override => TRUE);
      END IF;
      DELETE FROM employee
       WHERE
          job_id = delby_emp_job_lookup.job_id_in
         ;
      rowcount_out := SQL%ROWCOUNT;
   EXCEPTION
      WHEN OTHERS
      THEN
         plvexc.recnstop;
   END delby_emp_job_lookup;

   --// Delete all records for foreign key EMP_MGR_LOOKUP. //--
   PROCEDURE delby_emp_mgr_lookup (
      manager_id_in IN employee.manager_id%TYPE,
      rowcount_out OUT INTEGER
      )
   IS
   BEGIN
      IF PLVxmn.traceactive ('delby_emp_mgr_lookup', PLVxmn.l_del)
      THEN
         PLVxmn.trace ('delby_emp_mgr_lookup', PLVxmn.l_del,
            '-manager_id='|| manager_id_in
            , override => TRUE);
      END IF;
      DELETE FROM employee
       WHERE
          manager_id = delby_emp_mgr_lookup.manager_id_in
         ;
      rowcount_out := SQL%ROWCOUNT;
   EXCEPTION
      WHEN OTHERS
      THEN
         plvexc.recnstop;
   END delby_emp_mgr_lookup;


   --// Program called by database initialization script to pin the package. //--
   PROCEDURE pinme
   IS
   BEGIN
      --// Doesn't do anything except cause the package to be loaded. //--
      NULL;
   END;


   PROCEDURE load_to_memory
   IS
   BEGIN
      loadtab.DELETE;
      FOR rec IN (
         SELECT
            employee_id,
            last_name,
            first_name,
            middle_initial,
            job_id,
            manager_id,
            hire_date,
            salary,
            commission,
            department_id,
            changed_by,
            changed_on
           FROM employee
           )
      LOOP
         loadtab (rec.employee_id) := rec;
      END LOOP;
   END;

   PROCEDURE showload (
      start_inout IN INTEGER := NULL,
      end_inout IN INTEGER := NULL
      )
   IS
      v_row PLS_INTEGER := loadtab.FIRST;
      v_last PLS_INTEGER := loadtab.LAST;
   BEGIN
      IF v_row IS NULL
      THEN
         DBMS_OUTPUT.PUT_LINE ('In-memory table for employee is empty!');
      ELSE
         IF start_inout > v_row
         THEN
            v_row := loadtab.NEXT (v_row-1);
         END IF;
         IF end_inout < v_last
         THEN
            v_row := loadtab.PRIOR (v_last+1);
         END IF;
         LOOP
            EXIT WHEN v_row >= v_last OR v_row IS NULL;
            DBMS_OUTPUT.PUT_LINE ('PKY Value/Row: ' || loadtab(v_row).employee_id);
            v_row := loadtab.NEXT (v_row);
         END LOOP;
      END IF;
   END;
--// Initialization section for the package. --//
BEGIN
   NULL; -- Placeholder.
   load_to_memory;
END te_employee;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
