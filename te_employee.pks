CREATE OR REPLACE PACKAGE te_employee
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
--//  Stored In:  te_employee.pks
--//  Created On: September 05, 1999 20:14:04
--//  Created By: SCOTT
--//  PL/Generator Version: PRO-99.2.1
--//-----------------------------------------------------------------------
IS
--// Data Structures //--
   TYPE pky_rt IS RECORD (
      employee_id employee.employee_id%TYPE
      );

   --// Modified version of %ROWTYPE for table with subset of columns //--
   TYPE allcols_rt IS RECORD (
      employee_id employee.employee_id%TYPE,
      last_name employee.last_name%TYPE,
      first_name employee.first_name%TYPE,
      middle_initial employee.middle_initial%TYPE,
      job_id employee.job_id%TYPE,
      manager_id employee.manager_id%TYPE,
      hire_date employee.hire_date%TYPE,
      salary employee.salary%TYPE,
      commission employee.commission%TYPE,
      department_id employee.department_id%TYPE,
      changed_by employee.changed_by%TYPE,
      changed_on employee.changed_on%TYPE
      );

   TYPE pky_cvt IS REF CURSOR RETURN pky_rt;
   TYPE employee_cvt IS REF CURSOR RETURN allcols_rt;

   TYPE i_employee_name_rt IS RECORD (
      last_name employee.last_name%TYPE,
      first_name employee.first_name%TYPE,
      middle_initial employee.middle_initial%TYPE
      );

   TYPE i_employee_name_cvt IS REF CURSOR RETURN i_employee_name_rt;
   CURSOR totsal_cur
   IS
      SELECT department_id, SUM(salary) total_salary
        FROM employee
       GROUP BY department_id;


--// Cursors //--

   CURSOR compbypky_cur
   IS
      SELECT
         employee_id, salary, commission
        FROM employee
       ORDER BY
         employee_id
      ;

   CURSOR compforpky_cur (
      employee_id_in IN employee.employee_id%TYPE
      )
   IS
      SELECT
         employee_id, salary, commission
        FROM employee
       WHERE
         employee_id = compforpky_cur.employee_id_in
      ;

   --// Specified columns, all rows for this foreign key. //--
   CURSOR emp_dept_lookup_comp_cur (
      department_id_in IN employee.department_id%TYPE
      )
   IS
      SELECT
         employee_id, salary, commission
        FROM employee
       WHERE
          department_id = emp_dept_lookup_comp_cur.department_id_in
      ;

   --// Specified columns, all rows for this foreign key. //--
   CURSOR emp_job_lookup_comp_cur (
      job_id_in IN employee.job_id%TYPE
      )
   IS
      SELECT
         employee_id, salary, commission
        FROM employee
       WHERE
          job_id = emp_job_lookup_comp_cur.job_id_in
      ;

   --// Specified columns, all rows for this foreign key. //--
   CURSOR emp_mgr_lookup_comp_cur (
      manager_id_in IN employee.manager_id%TYPE
      )
   IS
      SELECT
         employee_id, salary, commission
        FROM employee
       WHERE
          manager_id = emp_mgr_lookup_comp_cur.manager_id_in
      ;

   CURSOR namebypky_cur
   IS
      SELECT
         last_name || ', ' || first_name full_name
        FROM employee
       ORDER BY
         employee_id
      ;

   CURSOR nameforpky_cur (
      employee_id_in IN employee.employee_id%TYPE
      )
   IS
      SELECT
         last_name || ', ' || first_name full_name
        FROM employee
       WHERE
         employee_id = nameforpky_cur.employee_id_in
      ;

   --// Specified columns, all rows for this foreign key. //--
   CURSOR emp_dept_lookup_name_cur (
      department_id_in IN employee.department_id%TYPE
      )
   IS
      SELECT
         last_name || ', ' || first_name full_name
        FROM employee
       WHERE
          department_id = emp_dept_lookup_name_cur.department_id_in
      ;

   --// Specified columns, all rows for this foreign key. //--
   CURSOR emp_job_lookup_name_cur (
      job_id_in IN employee.job_id%TYPE
      )
   IS
      SELECT
         last_name || ', ' || first_name full_name
        FROM employee
       WHERE
          job_id = emp_job_lookup_name_cur.job_id_in
      ;

   --// Specified columns, all rows for this foreign key. //--
   CURSOR emp_mgr_lookup_name_cur (
      manager_id_in IN employee.manager_id%TYPE
      )
   IS
      SELECT
         last_name || ', ' || first_name full_name
        FROM employee
       WHERE
          manager_id = emp_mgr_lookup_name_cur.manager_id_in
      ;

   CURSOR allbypky_cur
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
       ORDER BY
         employee_id
      ;

   CURSOR allforpky_cur (
      employee_id_in IN employee.employee_id%TYPE
      )
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
         employee_id = allforpky_cur.employee_id_in
      ;

   --// Specified columns, all rows for this foreign key. //--
   CURSOR emp_dept_lookup_all_cur (
      department_id_in IN employee.department_id%TYPE
      )
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
          department_id = emp_dept_lookup_all_cur.department_id_in
      ;

   --// Specified columns, all rows for this foreign key. //--
   CURSOR emp_job_lookup_all_cur (
      job_id_in IN employee.job_id%TYPE
      )
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
          job_id = emp_job_lookup_all_cur.job_id_in
      ;

   --// Specified columns, all rows for this foreign key. //--
   CURSOR emp_mgr_lookup_all_cur (
      manager_id_in IN employee.manager_id%TYPE
      )
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
          manager_id = emp_mgr_lookup_all_cur.manager_id_in
      ;

--// Cursor management procedures //--

   --// Open the cursors with some options. //--
   PROCEDURE open_compforpky_cur (
      employee_id_in IN employee.employee_id%TYPE,
      close_if_open IN BOOLEAN := TRUE
      );

   PROCEDURE open_compbypky_cur (
      close_if_open IN BOOLEAN := TRUE
      );

   PROCEDURE open_emp_dept_lookup_comp_cur (
      department_id_in IN employee.department_id%TYPE,
      close_if_open IN BOOLEAN := TRUE
      );

   PROCEDURE open_emp_job_lookup_comp_cur (
      job_id_in IN employee.job_id%TYPE,
      close_if_open IN BOOLEAN := TRUE
      );

   PROCEDURE open_emp_mgr_lookup_comp_cur (
      manager_id_in IN employee.manager_id%TYPE,
      close_if_open IN BOOLEAN := TRUE
      );
   PROCEDURE open_nameforpky_cur (
      employee_id_in IN employee.employee_id%TYPE,
      close_if_open IN BOOLEAN := TRUE
      );

   PROCEDURE open_namebypky_cur (
      close_if_open IN BOOLEAN := TRUE
      );

   PROCEDURE open_emp_dept_lookup_name_cur (
      department_id_in IN employee.department_id%TYPE,
      close_if_open IN BOOLEAN := TRUE
      );

   PROCEDURE open_emp_job_lookup_name_cur (
      job_id_in IN employee.job_id%TYPE,
      close_if_open IN BOOLEAN := TRUE
      );

   PROCEDURE open_emp_mgr_lookup_name_cur (
      manager_id_in IN employee.manager_id%TYPE,
      close_if_open IN BOOLEAN := TRUE
      );
   PROCEDURE open_allforpky_cur (
      employee_id_in IN employee.employee_id%TYPE,
      close_if_open IN BOOLEAN := TRUE
      );

   PROCEDURE open_allbypky_cur (
      close_if_open IN BOOLEAN := TRUE
      );

   PROCEDURE open_emp_dept_lookup_all_cur (
      department_id_in IN employee.department_id%TYPE,
      close_if_open IN BOOLEAN := TRUE
      );

   PROCEDURE open_emp_job_lookup_all_cur (
      job_id_in IN employee.job_id%TYPE,
      close_if_open IN BOOLEAN := TRUE
      );

   PROCEDURE open_emp_mgr_lookup_all_cur (
      manager_id_in IN employee.manager_id%TYPE,
      close_if_open IN BOOLEAN := TRUE
      );

   --// Close the cursors if they are open. //--
   PROCEDURE close_compforpky_cur;
   PROCEDURE close_compbypky_cur;
   PROCEDURE close_emp_dept_lookup_comp_cur;
   PROCEDURE close_emp_job_lookup_comp_cur;
   PROCEDURE close_emp_mgr_lookup_comp_cur;
   PROCEDURE close_nameforpky_cur;
   PROCEDURE close_namebypky_cur;
   PROCEDURE close_emp_dept_lookup_name_cur;
   PROCEDURE close_emp_job_lookup_name_cur;
   PROCEDURE close_emp_mgr_lookup_name_cur;
   PROCEDURE close_allforpky_cur;
   PROCEDURE close_allbypky_cur;
   PROCEDURE close_emp_dept_lookup_all_cur;
   PROCEDURE close_emp_job_lookup_all_cur;
   PROCEDURE close_emp_mgr_lookup_all_cur;
   PROCEDURE closeall;

--// Functions returning Cursor Variables for each cursor //--

   --// Specified columns for all rows //--
   FUNCTION allbypky$cv RETURN employee_cvt;

   --// Specified columns for one row //--
   FUNCTION allforpky$cv (
      employee_id_in IN employee.employee_id%TYPE
      )
   RETURN employee_cvt;

   --// For each foreign key.... //--
   FUNCTION emp_dept_lookup_all$cv (
      department_id_in IN employee.department_id%TYPE
      )
   RETURN employee_cvt;

   --// For each foreign key.... //--
   FUNCTION emp_job_lookup_all$cv (
      job_id_in IN employee.job_id%TYPE
      )
   RETURN employee_cvt;

   --// For each foreign key.... //--
   FUNCTION emp_mgr_lookup_all$cv (
      manager_id_in IN employee.manager_id%TYPE
      )
   RETURN employee_cvt;

--// Analyze presence of primary key: is it NOT NULL? //--

   FUNCTION isnullpky (
      rec_in IN allcols_rt
      )
   RETURN BOOLEAN;

   FUNCTION isnullpky (
      rec_in IN pky_rt
      )
   RETURN BOOLEAN;

--// Emulate aggregate-level record operations. //--

   FUNCTION recseq (rec1 IN allcols_rt, rec2 IN allcols_rt)
   RETURN BOOLEAN;

   FUNCTION recseq (rec1 IN pky_rt, rec2 IN pky_rt)
   RETURN BOOLEAN;

--// Fetch Data //--

   --// Fetch one row of data for a primary key. //--
   FUNCTION onerow (
      employee_id_in IN employee.employee_id%TYPE
      )
   RETURN allcols_rt;

   FUNCTION onerow$cv (
      employee_id_in IN employee.employee_id%TYPE
      )
   RETURN employee_cvt;

   --// For each unique index ... //--

   FUNCTION i_employee_name$pky (
      last_name_in IN employee.last_name%TYPE,
      first_name_in IN employee.first_name%TYPE,
      middle_initial_in IN employee.middle_initial%TYPE
      )
      RETURN pky_rt
      ;

   FUNCTION i_employee_name$val (
      employee_id_in IN employee.employee_id%TYPE
      )
   RETURN i_employee_name_rt;

   FUNCTION i_employee_name$row (
      last_name_in IN employee.last_name%TYPE,
      first_name_in IN employee.first_name%TYPE,
      middle_initial_in IN employee.middle_initial%TYPE
      )
   RETURN allcols_rt;

   FUNCTION i_employee_name$pcv (
      last_name_in IN employee.last_name%TYPE,
      first_name_in IN employee.first_name%TYPE,
      middle_initial_in IN employee.middle_initial%TYPE
      )
      RETURN pky_cvt
      ;

   FUNCTION i_employee_name$vcv (
      employee_id_in IN employee.employee_id%TYPE
      )
   RETURN i_employee_name_cvt;

   FUNCTION i_employee_name$rcv (
      last_name_in IN employee.last_name%TYPE,
      first_name_in IN employee.first_name%TYPE,
      middle_initial_in IN employee.middle_initial%TYPE
      )
   RETURN employee_cvt;

   --// For each update column ... //--

   FUNCTION hire_date$val (
      employee_id_in IN employee.employee_id%TYPE
      )
   RETURN employee.hire_date%TYPE;
   --// For each update column ... //--

   FUNCTION salary$val (
      employee_id_in IN employee.employee_id%TYPE
      )
   RETURN employee.salary%TYPE;

   --// Count of all rows in table and for each foreign key. //--
   FUNCTION rowcount RETURN INTEGER;
   FUNCTION pkyrowcount (
      employee_id_in IN employee.employee_id%TYPE
      )
      RETURN INTEGER;
   FUNCTION emp_dept_lookuprowcount (
      department_id_in IN employee.department_id%TYPE
      )
      RETURN INTEGER;
   FUNCTION emp_job_lookuprowcount (
      job_id_in IN employee.job_id%TYPE
      )
      RETURN INTEGER;
   FUNCTION emp_mgr_lookuprowcount (
      manager_id_in IN employee.manager_id%TYPE
      )
      RETURN INTEGER;

   PROCEDURE lookup_fkydescs (
      --// Foreign key columns for emp_dept_lookup //--
      department_id_in IN employee.department_id%TYPE,
      emp_dept_lookup_out OUT te_department.i_department_name_rt,
      --// Foreign key columns for emp_job_lookup //--
      job_id_in IN employee.job_id%TYPE,
      emp_job_lookup_out OUT te_job.i_job_function_rt,
      --// Foreign key columns for emp_mgr_lookup //--
      manager_id_in IN employee.manager_id%TYPE,
      emp_mgr_lookup_out OUT te_employee.i_employee_name_rt,
      record_error BOOLEAN := TRUE
      );

--// Check Constraint Validation //--

   --// Check Constraint: DEPARTMENT_ID > 0 AND (salary > 0 OR salary IS NULL) //--
   FUNCTION employee$complex$chk (
      department_id_in IN employee.department_id%TYPE,
      salary_in IN employee.salary%TYPE
      ) RETURN BOOLEAN;

   --// Check Constraint: DEPARTMENT_ID IS NOT NULL //--
   FUNCTION notnull_department_id$chk (
      department_id_in IN employee.department_id%TYPE
      ) RETURN BOOLEAN;

   --// Check Constraint: EMPLOYEE_ID IS NOT NULL //--
   FUNCTION notnull_employee_id$chk (
      employee_id_in IN employee.employee_id%TYPE
      ) RETURN BOOLEAN;

   --// Check Constraint: "HIRE_DATE" IS NOT NULL //--
   FUNCTION sys_c002591$chk (
      hire_date_in IN employee.hire_date%TYPE
      ) RETURN BOOLEAN;

   --// Check Constraint: "CHANGED_BY" IS NOT NULL //--
   FUNCTION sys_c002594$chk (
      changed_by_in IN employee.changed_by%TYPE
      ) RETURN BOOLEAN;

   --// Check Constraint: "CHANGED_ON" IS NOT NULL //--
   FUNCTION sys_c002595$chk (
      changed_on_in IN employee.changed_on%TYPE
      ) RETURN BOOLEAN;
   PROCEDURE validate (
      employee_id_in IN employee.employee_id%TYPE,
      hire_date_in IN employee.hire_date%TYPE,
      salary_in IN employee.salary%TYPE,
      department_id_in IN employee.department_id%TYPE,
      changed_by_in IN employee.changed_by%TYPE,
      changed_on_in IN employee.changed_on%TYPE,
      record_error IN BOOLEAN := TRUE
      );

   PROCEDURE validate (
      rec_in IN allcols_rt,
      record_error IN BOOLEAN := TRUE
      );
--// Update Processing //--

   PROCEDURE reset$frc;

   --// Force setting of NULL values //--

   FUNCTION last_name$frc
      (last_name_in IN employee.last_name%TYPE DEFAULT NULL)
      RETURN employee.last_name%TYPE;

   FUNCTION first_name$frc
      (first_name_in IN employee.first_name%TYPE DEFAULT NULL)
      RETURN employee.first_name%TYPE;

   FUNCTION middle_initial$frc
      (middle_initial_in IN employee.middle_initial%TYPE DEFAULT NULL)
      RETURN employee.middle_initial%TYPE;

   FUNCTION job_id$frc
      (job_id_in IN employee.job_id%TYPE DEFAULT NULL)
      RETURN employee.job_id%TYPE;

   FUNCTION manager_id$frc
      (manager_id_in IN employee.manager_id%TYPE DEFAULT NULL)
      RETURN employee.manager_id%TYPE;

   FUNCTION hire_date$frc
      (hire_date_in IN employee.hire_date%TYPE DEFAULT NULL)
      RETURN employee.hire_date%TYPE;

   FUNCTION salary$frc
      (salary_in IN employee.salary%TYPE DEFAULT NULL)
      RETURN employee.salary%TYPE;

   FUNCTION commission$frc
      (commission_in IN employee.commission%TYPE DEFAULT NULL)
      RETURN employee.commission%TYPE;

   FUNCTION department_id$frc
      (department_id_in IN employee.department_id%TYPE DEFAULT NULL)
      RETURN employee.department_id%TYPE;

   FUNCTION changed_by$frc
      (changed_by_in IN employee.changed_by%TYPE DEFAULT NULL)
      RETURN employee.changed_by%TYPE;

   FUNCTION changed_on$frc
      (changed_on_in IN employee.changed_on%TYPE DEFAULT NULL)
      RETURN employee.changed_on%TYPE;

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
      );

   --// Record-based Update //--

   PROCEDURE upd (rec_in IN allcols_rt,
      rowcount_out OUT INTEGER,
      reset_in IN BOOLEAN DEFAULT TRUE);


   --// Update procedure for hire_date. --//
   PROCEDURE upd$hire_date (
      employee_id_in IN employee.employee_id%TYPE,
      hire_date_in IN employee.hire_date%TYPE,
      rowcount_out OUT INTEGER
      );

   PROCEDURE upd$hire_date (
      rec_in IN pky_rt,
      hire_date_in IN employee.hire_date%TYPE,
      rowcount_out OUT INTEGER
      );


   --// Update procedure for salary. --//
   PROCEDURE upd$salary (
      employee_id_in IN employee.employee_id%TYPE,
      salary_in IN employee.salary%TYPE,
      rowcount_out OUT INTEGER
      );

   PROCEDURE upd$salary (
      rec_in IN pky_rt,
      salary_in IN employee.salary%TYPE,
      rowcount_out OUT INTEGER
      );

--// Insert Processing //--

   --// Initialize record with default values. //--
   FUNCTION initrec (allnull IN BOOLEAN := FALSE) RETURN allcols_rt;

   --// Initialize record with default values. //--
   PROCEDURE initrec (
      rec_inout IN OUT allcols_rt,
      allnull IN BOOLEAN := FALSE);


   --// Generate next primary key: for single column PKs only. //--
   FUNCTION nextpky RETURN employee.employee_id%TYPE;

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
      );

   PROCEDURE ins (rec_in IN allcols_rt,
      employee_id_out IN OUT employee.employee_id%TYPE,
      upd_on_dup IN BOOLEAN := FALSE
      );

--// Delete Processing //--
   PROCEDURE del (
      employee_id_in IN employee.employee_id%TYPE,
      rowcount_out OUT INTEGER);

   --// Record-based delete //--
   PROCEDURE del (rec_in IN pky_rt,
      rowcount_out OUT INTEGER);

   PROCEDURE del (rec_in IN allcols_rt,
      rowcount_out OUT INTEGER);

   --// Delete all records for this EMP_DEPT_LOOKUP foreign key. //--
   PROCEDURE delby_emp_dept_lookup (
      department_id_in IN employee.department_id%TYPE,
      rowcount_out OUT INTEGER
      );

   --// Delete all records for this EMP_JOB_LOOKUP foreign key. //--
   PROCEDURE delby_emp_job_lookup (
      job_id_in IN employee.job_id%TYPE,
      rowcount_out OUT INTEGER
      );

   --// Delete all records for this EMP_MGR_LOOKUP foreign key. //--
   PROCEDURE delby_emp_mgr_lookup (
      manager_id_in IN employee.manager_id%TYPE,
      rowcount_out OUT INTEGER
      );

   --// Program called by database initialization script to pin the package. //--
   PROCEDURE pinme;

   --// Load and display index table of data - PK only. //--
   PROCEDURE load_to_memory;

   PROCEDURE showload (
      start_inout IN INTEGER := NULL,
      end_inout IN INTEGER := NULL
      );
   FUNCTION version RETURN VARCHAR2;
END te_employee;
/




/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
