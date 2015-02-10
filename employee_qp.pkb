CREATE OR REPLACE PACKAGE BODY EMPLOYEE_QP
/*
| Generated by or retrieved from Qnxo - DO NOT MODIFY!
| Qnxo - "Get it right, do it fast" - www.qnxo.com
| Qnxo Universal ID: ce63f2f4-b478-47a2-b142-b1c577af0c40
| Created On: April     04, 2005 07:31:54 Created By: QNXO_DEMO
*/
IS
   FUNCTION onerow (
      employee_id_in IN EMPLOYEE_TP.EMPLOYEE_ID_t
      )
   RETURN EMPLOYEE_TP.EMPLOYEE_rt
   IS
      onerow_rec EMPLOYEE_TP.EMPLOYEE_rt;
   BEGIN
      SELECT
            EMPLOYEE_ID,
            LAST_NAME,
            FIRST_NAME,
            MIDDLE_INITIAL,
            JOB_ID,
            MANAGER_ID,
            HIRE_DATE,
            SALARY,
            COMMISSION,
            DEPARTMENT_ID,
            EMPNO,
            ENAME,
            CREATED_BY,
            CREATED_ON,
            CHANGED_BY,
            CHANGED_ON
        INTO onerow_rec
        FROM EMPLOYEE
       WHERE
             EMPLOYEE_ID = employee_id_in
      ;
      RETURN onerow_rec;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
      WHEN TOO_MANY_ROWS
      THEN
         DECLARE
            l_err_instance_id qd_err_instance_tp.id_t;
         BEGIN
            qd_runtime.register_error ('MULTIPLE-UNIQUE-ROWS'
               ,err_instance_id_out => l_err_instance_id);
            qd_runtime.add_context (
               err_instance_id_in => l_err_instance_id
              ,NAME_IN => 'TABLE'
              ,value_in => 'EMPLOYEE'
              ,validate_in => FALSE
              );
            qd_runtime.add_context (
               err_instance_id_in => l_err_instance_id
              ,NAME_IN => 'EMPLOYEE_ID'
              ,value_in => 'employee_id_in'
              ,validate_in => FALSE
              );
            qd_runtime.raise_error_instance (
              err_instance_id_in => l_err_instance_id);
         END;
   END onerow;

   FUNCTION row_exists (
      employee_id_in IN EMPLOYEE_TP.EMPLOYEE_ID_t
      )
   RETURN BOOLEAN
   IS
      l_dummy PLS_INTEGER;
      retval BOOLEAN;
   BEGIN
      SELECT 1 INTO l_dummy
        FROM EMPLOYEE
       WHERE
             EMPLOYEE_ID = employee_id_in
      ;
      RETURN TRUE;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN RETURN FALSE;
      WHEN TOO_MANY_ROWS THEN RETURN TRUE;
   END row_exists;

   FUNCTION onerow_CV (
      employee_id_in IN EMPLOYEE_TP.EMPLOYEE_ID_t
      )
   RETURN EMPLOYEE_TP.EMPLOYEE_rc
   IS
      retval EMPLOYEE_TP.EMPLOYEE_rc;
   BEGIN
      OPEN retval FOR
         SELECT
            EMPLOYEE_ID,
            LAST_NAME,
            FIRST_NAME,
            MIDDLE_INITIAL,
            JOB_ID,
            MANAGER_ID,
            HIRE_DATE,
            SALARY,
            COMMISSION,
            DEPARTMENT_ID,
            EMPNO,
            ENAME,
            CREATED_BY,
            CREATED_ON,
            CHANGED_BY,
            CHANGED_ON
        FROM EMPLOYEE
       WHERE
             EMPLOYEE_ID = employee_id_in
      ;
      RETURN retval;
   END onerow_cv;

   FUNCTION allrows RETURN EMPLOYEE_TP.EMPLOYEE_tc
   IS
      CURSOR allrows_cur
      IS
         SELECT
            EMPLOYEE_ID,
            LAST_NAME,
            FIRST_NAME,
            MIDDLE_INITIAL,
            JOB_ID,
            MANAGER_ID,
            HIRE_DATE,
            SALARY,
            COMMISSION,
            DEPARTMENT_ID,
            EMPNO,
            ENAME,
            CREATED_BY,
            CREATED_ON,
            CHANGED_BY,
            CHANGED_ON
           FROM EMPLOYEE

           ;
      l_rows PLS_INTEGER;
      retval EMPLOYEE_TP.EMPLOYEE_tc;
   BEGIN
      OPEN allrows_cur;
      FETCH allrows_cur BULK COLLECT INTO retval;
      RETURN retval;
   END allrows;

   FUNCTION allrows_cv RETURN EMPLOYEE_TP.EMPLOYEE_rc
   IS
      retval EMPLOYEE_TP.EMPLOYEE_rc;
   BEGIN
      OPEN retval FOR
         SELECT
            EMPLOYEE_ID,
            LAST_NAME,
            FIRST_NAME,
            MIDDLE_INITIAL,
            JOB_ID,
            MANAGER_ID,
            HIRE_DATE,
            SALARY,
            COMMISSION,
            DEPARTMENT_ID,
            EMPNO,
            ENAME,
            CREATED_BY,
            CREATED_ON,
            CHANGED_BY,
            CHANGED_ON
           FROM EMPLOYEE

           ;
      RETURN retval;
   END allrows_cv;

   FUNCTION allrows_by_CV (where_clause_in IN VARCHAR2
      , column_list_in IN VARCHAR2 DEFAULT NULL) RETURN EMPLOYEE_TP.weak_refcur
   IS
      retval EMPLOYEE_TP.weak_refcur;
   BEGIN
      IF where_clause_in IS NULL AND column_list_in IS NULL
      THEN
         retval := allrows_cv;
      ELSIF column_list_in IS NULL
      THEN
         OPEN retval FOR
            'SELECT
            EMPLOYEE_ID,
            LAST_NAME,
            FIRST_NAME,
            MIDDLE_INITIAL,
            JOB_ID,
            MANAGER_ID,
            HIRE_DATE,
            SALARY,
            COMMISSION,
            DEPARTMENT_ID,
            EMPNO,
            ENAME,
            CREATED_BY,
            CREATED_ON,
            CHANGED_BY,
            CHANGED_ON
           FROM EMPLOYEE WHERE ' || where_clause_in
             || ' ' || ''
           ;
      ELSE
         OPEN retval FOR
            'SELECT ' || column_list_in ||
             ' FROM EMPLOYEE WHERE ' || where_clause_in
             || ' ' || ''
           ;
      END IF;
      RETURN retval;
   END allrows_by_cv;

   -- Close the specified cursor variable, only if it is open.
   PROCEDURE close_cursor (cursor_variable_in IN EMPLOYEE_TP.EMPLOYEE_rc)
   IS
   BEGIN
      IF cursor_variable_in%ISOPEN
      THEN
         CLOSE cursor_variable_in;
      END IF;
   END close_cursor;

   -- Hide calls to cursor attributes behind interface.
   FUNCTION cursor_is_open (cursor_variable_in IN EMPLOYEE_TP.weak_refcur) RETURN BOOLEAN
   IS
   BEGIN
      RETURN cursor_variable_in%ISOPEN;
   EXCEPTION WHEN OTHERS THEN RETURN FALSE;
   END cursor_is_open;

   FUNCTION row_found (cursor_variable_in IN EMPLOYEE_TP.weak_refcur) RETURN BOOLEAN
   IS
   BEGIN
      RETURN cursor_variable_in%FOUND;
   EXCEPTION WHEN OTHERS THEN RETURN NULL;
   END row_found;

   FUNCTION row_notfound (cursor_variable_in IN EMPLOYEE_TP.weak_refcur) RETURN BOOLEAN
   IS
   BEGIN
      RETURN cursor_variable_in%NOTFOUND;
   EXCEPTION WHEN OTHERS THEN RETURN NULL;
   END row_notfound;

   FUNCTION cursor_rowcount (cursor_variable_in IN EMPLOYEE_TP.weak_refcur) RETURN PLS_INTEGER
   IS
   BEGIN
      RETURN cursor_variable_in%ROWCOUNT;
   EXCEPTION WHEN OTHERS THEN RETURN 0;
   END cursor_rowcount;

   -- Use the LIMIT clause to BULK COLLECT N rows through the cursor variable
   -- The current contents of the collection will be deleted.

   FUNCTION fetch_rows (
      cursor_variable_in IN EMPLOYEE_TP.EMPLOYEE_rc
    , limit_in IN PLS_INTEGER DEFAULT 100
    )
      RETURN EMPLOYEE_TP.EMPLOYEE_tc
   IS
      retval EMPLOYEE_TP.EMPLOYEE_tc;
   BEGIN
      FETCH cursor_variable_in BULK COLLECT INTO
         retval LIMIT limit_in;
      RETURN retval;
   END fetch_rows;

    -- Allrows for specified where clause (using dynamic SQL)
   FUNCTION allrows_by (where_clause_in IN VARCHAR2)
      RETURN EMPLOYEE_TP.EMPLOYEE_tc
   IS
      allrows_cur EMPLOYEE_TP.weak_refcur;
      retval EMPLOYEE_TP.EMPLOYEE_tc;
   BEGIN
      EXECUTE IMMEDIATE
         'SELECT
            EMPLOYEE_ID,
            LAST_NAME,
            FIRST_NAME,
            MIDDLE_INITIAL,
            JOB_ID,
            MANAGER_ID,
            HIRE_DATE,
            SALARY,
            COMMISSION,
            DEPARTMENT_ID,
            EMPNO,
            ENAME,
            CREATED_BY,
            CREATED_ON,
            CHANGED_BY,
            CHANGED_ON
           FROM EMPLOYEE WHERE ' || where_clause_in
         BULK COLLECT INTO retval;
      RETURN retval;
   END allrows_by;

   PROCEDURE allrows (
      employee_id_out OUT EMPLOYEE_TP.EMPLOYEE_ID_cc,
      last_name_out OUT EMPLOYEE_TP.LAST_NAME_cc,
      first_name_out OUT EMPLOYEE_TP.FIRST_NAME_cc,
      middle_initial_out OUT EMPLOYEE_TP.MIDDLE_INITIAL_cc,
      job_id_out OUT EMPLOYEE_TP.JOB_ID_cc,
      manager_id_out OUT EMPLOYEE_TP.MANAGER_ID_cc,
      hire_date_out OUT EMPLOYEE_TP.HIRE_DATE_cc,
      salary_out OUT EMPLOYEE_TP.SALARY_cc,
      commission_out OUT EMPLOYEE_TP.COMMISSION_cc,
      department_id_out OUT EMPLOYEE_TP.DEPARTMENT_ID_cc,
      empno_out OUT EMPLOYEE_TP.EMPNO_cc,
      ename_out OUT EMPLOYEE_TP.ENAME_cc,
      created_by_out OUT EMPLOYEE_TP.CREATED_BY_cc,
      created_on_out OUT EMPLOYEE_TP.CREATED_ON_cc,
      changed_by_out OUT EMPLOYEE_TP.CHANGED_BY_cc,
      changed_on_out OUT EMPLOYEE_TP.CHANGED_ON_cc
   )
   IS
   BEGIN
      SELECT
            EMPLOYEE_ID,
            LAST_NAME,
            FIRST_NAME,
            MIDDLE_INITIAL,
            JOB_ID,
            MANAGER_ID,
            HIRE_DATE,
            SALARY,
            COMMISSION,
            DEPARTMENT_ID,
            EMPNO,
            ENAME,
            CREATED_BY,
            CREATED_ON,
            CHANGED_BY,
            CHANGED_ON
        BULK COLLECT INTO
            employee_id_out,
            last_name_out,
            first_name_out,
            middle_initial_out,
            job_id_out,
            manager_id_out,
            hire_date_out,
            salary_out,
            commission_out,
            department_id_out,
            empno_out,
            ename_out,
            created_by_out,
            created_on_out,
            changed_by_out,
            changed_on_out
        FROM EMPLOYEE
      ;
   END allrows;

   -- Return collection of all rows for primary key column EMPLOYEE_ID
   FUNCTION for_EMPLOYEE_ID (
      employee_id_in IN EMPLOYEE_TP.EMPLOYEE_ID_t
      )
      RETURN EMPLOYEE_TP.EMPLOYEE_tc
   IS
      CURSOR allrows_cur
      IS
         SELECT
            EMPLOYEE_ID,
            LAST_NAME,
            FIRST_NAME,
            MIDDLE_INITIAL,
            JOB_ID,
            MANAGER_ID,
            HIRE_DATE,
            SALARY,
            COMMISSION,
            DEPARTMENT_ID,
            EMPNO,
            ENAME,
            CREATED_BY,
            CREATED_ON,
            CHANGED_BY,
            CHANGED_ON
           FROM EMPLOYEE
          WHERE EMPLOYEE_ID = for_EMPLOYEE_ID.employee_id_in

          ;
      l_rows PLS_INTEGER;
      retval EMPLOYEE_TP.EMPLOYEE_tc;
   BEGIN
      OPEN allrows_cur;
      FETCH allrows_cur BULK COLLECT INTO retval;
      RETURN retval;
   END for_EMPLOYEE_ID;

   -- Return ref cursor to all rows for primary key column EMPLOYEE_ID
   FUNCTION for_EMPLOYEE_ID_cv (
      employee_id_in IN EMPLOYEE_TP.EMPLOYEE_ID_t
      )
      RETURN EMPLOYEE_TP.EMPLOYEE_rc
   IS
      retval EMPLOYEE_TP.EMPLOYEE_rc;
   BEGIN
      OPEN retval FOR
         SELECT
            EMPLOYEE_ID,
            LAST_NAME,
            FIRST_NAME,
            MIDDLE_INITIAL,
            JOB_ID,
            MANAGER_ID,
            HIRE_DATE,
            SALARY,
            COMMISSION,
            DEPARTMENT_ID,
            EMPNO,
            ENAME,
            CREATED_BY,
            CREATED_ON,
            CHANGED_BY,
            CHANGED_ON
           FROM EMPLOYEE
          WHERE EMPLOYEE_ID = employee_id_in

             ;
      RETURN retval;
   END for_EMPLOYEE_ID_cv;

   FUNCTION in_EMPLOYEE_ID_cv (
      list_in IN VARCHAR2
      )
      RETURN EMPLOYEE_TP.weak_refcur
   IS
      retval EMPLOYEE_TP.weak_refcur;
   BEGIN
      OPEN retval FOR
         'SELECT
            EMPLOYEE_ID,
            LAST_NAME,
            FIRST_NAME,
            MIDDLE_INITIAL,
            JOB_ID,
            MANAGER_ID,
            HIRE_DATE,
            SALARY,
            COMMISSION,
            DEPARTMENT_ID,
            EMPNO,
            ENAME,
            CREATED_BY,
            CREATED_ON,
            CHANGED_BY,
            CHANGED_ON
           FROM EMPLOYEE
          WHERE EMPLOYEE_ID IN (' || list_in || ')
             '
             ;
      RETURN retval;
   END in_EMPLOYEE_ID_cv;

   FUNCTION or_I_EMPLOYEE_NAME (
      last_name_in IN EMPLOYEE_TP.LAST_NAME_t,
      first_name_in IN EMPLOYEE_TP.FIRST_NAME_t,
      middle_initial_in IN EMPLOYEE_TP.MIDDLE_INITIAL_t
      )
      RETURN EMPLOYEE_TP.EMPLOYEE_rt
   IS
      retval EMPLOYEE_TP.EMPLOYEE_rt;
   BEGIN
      IF
         last_name_in IS NOT NULL AND
         first_name_in IS NOT NULL AND
         middle_initial_in IS NOT NULL
      THEN
      SELECT
            EMPLOYEE_ID,
            LAST_NAME,
            FIRST_NAME,
            MIDDLE_INITIAL,
            JOB_ID,
            MANAGER_ID,
            HIRE_DATE,
            SALARY,
            COMMISSION,
            DEPARTMENT_ID,
            EMPNO,
            ENAME,
            CREATED_BY,
            CREATED_ON,
            CHANGED_BY,
            CHANGED_ON
        INTO retval
        FROM EMPLOYEE
       WHERE
            LAST_NAME = last_name_in AND
            FIRST_NAME = first_name_in AND
            MIDDLE_INITIAL = middle_initial_in
      ;
      ELSE
      SELECT
            EMPLOYEE_ID,
            LAST_NAME,
            FIRST_NAME,
            MIDDLE_INITIAL,
            JOB_ID,
            MANAGER_ID,
            HIRE_DATE,
            SALARY,
            COMMISSION,
            DEPARTMENT_ID,
            EMPNO,
            ENAME,
            CREATED_BY,
            CREATED_ON,
            CHANGED_BY,
            CHANGED_ON
        INTO retval
        FROM EMPLOYEE
       WHERE
            (LAST_NAME = last_name_in OR (LAST_NAME IS NULL AND last_name_in IS NULL)) AND
            (FIRST_NAME = first_name_in OR (FIRST_NAME IS NULL AND first_name_in IS NULL)) AND
            (MIDDLE_INITIAL = middle_initial_in OR (MIDDLE_INITIAL IS NULL AND middle_initial_in IS NULL))
      ;
      END IF;
      RETURN retval;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
      WHEN TOO_MANY_ROWS
      THEN
         DECLARE
            l_err_instance_id qd_err_instance_tp.id_t;
         BEGIN
            qd_runtime.register_error ('MULTIPLE-UNIQUE-ROWS'
               ,err_instance_id_out => l_err_instance_id);
            qd_runtime.add_context (
               err_instance_id_in => l_err_instance_id
              ,NAME_IN => 'TABLE'
              ,value_in => 'EMPLOYEE'
              ,validate_in => FALSE
              );
            qd_runtime.add_context (
               err_instance_id_in => l_err_instance_id
              ,NAME_IN => 'LAST_NAME'
              ,value_in => 'last_name_in'
              ,validate_in => FALSE
              );
            qd_runtime.add_context (
               err_instance_id_in => l_err_instance_id
              ,NAME_IN => 'FIRST_NAME'
              ,value_in => 'first_name_in'
              ,validate_in => FALSE
              );
            qd_runtime.add_context (
               err_instance_id_in => l_err_instance_id
              ,NAME_IN => 'MIDDLE_INITIAL'
              ,value_in => 'middle_initial_in'
              ,validate_in => FALSE
              );
            qd_runtime.raise_error_instance (
              err_instance_id_in => l_err_instance_id);
         END;
   END or_I_EMPLOYEE_NAME;

   FUNCTION or_I_EMPLOYEE_NAME_cv (
      last_name_in IN EMPLOYEE_TP.LAST_NAME_t,
      first_name_in IN EMPLOYEE_TP.FIRST_NAME_t,
      middle_initial_in IN EMPLOYEE_TP.MIDDLE_INITIAL_t
      )
      RETURN EMPLOYEE_TP.EMPLOYEE_rc
   IS
      retval EMPLOYEE_TP.EMPLOYEE_rc;
   BEGIN
      IF
         last_name_in IS NOT NULL AND
         first_name_in IS NOT NULL AND
         middle_initial_in IS NOT NULL
      THEN
      OPEN retval FOR
         SELECT
            EMPLOYEE_ID,
            LAST_NAME,
            FIRST_NAME,
            MIDDLE_INITIAL,
            JOB_ID,
            MANAGER_ID,
            HIRE_DATE,
            SALARY,
            COMMISSION,
            DEPARTMENT_ID,
            EMPNO,
            ENAME,
            CREATED_BY,
            CREATED_ON,
            CHANGED_BY,
            CHANGED_ON
           FROM EMPLOYEE
          WHERE
            LAST_NAME = last_name_in AND
            FIRST_NAME = first_name_in AND
            MIDDLE_INITIAL = middle_initial_in
             ;
      ELSE
      OPEN retval FOR
         SELECT
            EMPLOYEE_ID,
            LAST_NAME,
            FIRST_NAME,
            MIDDLE_INITIAL,
            JOB_ID,
            MANAGER_ID,
            HIRE_DATE,
            SALARY,
            COMMISSION,
            DEPARTMENT_ID,
            EMPNO,
            ENAME,
            CREATED_BY,
            CREATED_ON,
            CHANGED_BY,
            CHANGED_ON
           FROM EMPLOYEE
          WHERE
            (LAST_NAME = last_name_in OR (LAST_NAME IS NULL AND last_name_in IS NULL)) AND
            (FIRST_NAME = first_name_in OR (FIRST_NAME IS NULL AND first_name_in IS NULL)) AND
            (MIDDLE_INITIAL = middle_initial_in OR (MIDDLE_INITIAL IS NULL AND middle_initial_in IS NULL))
             ;
      END IF;
      RETURN retval;
   END or_I_EMPLOYEE_NAME_cv;

   FUNCTION pky_I_EMPLOYEE_NAME (
      last_name_in IN EMPLOYEE_TP.LAST_NAME_t,
      first_name_in IN EMPLOYEE_TP.FIRST_NAME_t,
      middle_initial_in IN EMPLOYEE_TP.MIDDLE_INITIAL_t
      )
      RETURN EMPLOYEE_TP.EMPLOYEE_ID_t
   IS
      retval EMPLOYEE_TP.EMPLOYEE_ID_t;
   BEGIN
      IF
         last_name_in IS NOT NULL AND
         first_name_in IS NOT NULL AND
         middle_initial_in IS NOT NULL
      THEN
      SELECT EMPLOYEE_ID
        INTO retval
        FROM EMPLOYEE
       WHERE
            LAST_NAME = last_name_in AND
            FIRST_NAME = first_name_in AND
            MIDDLE_INITIAL = middle_initial_in
      ;
      ELSE
      SELECT EMPLOYEE_ID
        INTO retval
        FROM EMPLOYEE
       WHERE
            (LAST_NAME = last_name_in OR (LAST_NAME IS NULL AND last_name_in IS NULL)) AND
            (FIRST_NAME = first_name_in OR (FIRST_NAME IS NULL AND first_name_in IS NULL)) AND
            (MIDDLE_INITIAL = middle_initial_in OR (MIDDLE_INITIAL IS NULL AND middle_initial_in IS NULL))
      ;
      END IF;
      RETURN retval;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
      WHEN TOO_MANY_ROWS
      THEN
         DECLARE
            l_err_instance_id qd_err_instance_tp.id_t;
         BEGIN
            qd_runtime.register_error ('MULTIPLE-UNIQUE-ROWS'
               ,err_instance_id_out => l_err_instance_id);
            qd_runtime.add_context (
               err_instance_id_in => l_err_instance_id
              ,NAME_IN => 'TABLE'
              ,value_in => 'EMPLOYEE'
              ,validate_in => FALSE
              );
            qd_runtime.add_context (
               err_instance_id_in => l_err_instance_id
              ,NAME_IN => 'LAST_NAME'
              ,value_in => 'last_name_in'
              ,validate_in => FALSE
              );
            qd_runtime.add_context (
               err_instance_id_in => l_err_instance_id
              ,NAME_IN => 'FIRST_NAME'
              ,value_in => 'first_name_in'
              ,validate_in => FALSE
              );
            qd_runtime.add_context (
               err_instance_id_in => l_err_instance_id
              ,NAME_IN => 'MIDDLE_INITIAL'
              ,value_in => 'middle_initial_in'
              ,validate_in => FALSE
              );
            qd_runtime.raise_error_instance (
              err_instance_id_in => l_err_instance_id);
         END;
   END pky_I_EMPLOYEE_NAME;

   -- Number of rows by I_EMPLOYEE_NAME
   FUNCTION num_I_EMPLOYEE_NAME (
      last_name_in IN EMPLOYEE_TP.LAST_NAME_t,
      first_name_in IN EMPLOYEE_TP.FIRST_NAME_t,
      middle_initial_in IN EMPLOYEE_TP.MIDDLE_INITIAL_t
      )
      RETURN PLS_INTEGER
   IS
      retval PLS_INTEGER;
   BEGIN
      IF
         last_name_in IS NOT NULL AND
         first_name_in IS NOT NULL AND
         middle_initial_in IS NOT NULL
      THEN
      SELECT COUNT(*)
        INTO retval
        FROM EMPLOYEE
       WHERE
            LAST_NAME = last_name_in AND
            FIRST_NAME = first_name_in AND
            MIDDLE_INITIAL = middle_initial_in
      ;
      ELSE
      SELECT COUNT(*)
        INTO retval
        FROM EMPLOYEE
       WHERE
            (LAST_NAME = last_name_in OR (LAST_NAME IS NULL AND last_name_in IS NULL)) AND
            (FIRST_NAME = first_name_in OR (FIRST_NAME IS NULL AND first_name_in IS NULL)) AND
            (MIDDLE_INITIAL = middle_initial_in OR (MIDDLE_INITIAL IS NULL AND middle_initial_in IS NULL))
      ;
      END IF;
      RETURN retval;
   END num_I_EMPLOYEE_NAME;

   FUNCTION ex_I_EMPLOYEE_NAME (
      last_name_in IN EMPLOYEE_TP.LAST_NAME_t,
      first_name_in IN EMPLOYEE_TP.FIRST_NAME_t,
      middle_initial_in IN EMPLOYEE_TP.MIDDLE_INITIAL_t
      )
      RETURN BOOLEAN
   IS
      l_dummy PLS_INTEGER;
   BEGIN
      SELECT 1 INTO l_dummy
        FROM EMPLOYEE
       WHERE
             LAST_NAME = last_name_in AND
             FIRST_NAME = first_name_in AND
             MIDDLE_INITIAL = middle_initial_in
      ;
      RETURN TRUE;
   EXCEPTION WHEN NO_DATA_FOUND THEN RETURN FALSE;
             WHEN TOO_MANY_ROWS THEN RETURN TRUE;
   END ex_I_EMPLOYEE_NAME;

   FUNCTION ar_FK_EMP_DEPARTMENT_cv (
      department_id_in IN EMPLOYEE_TP.DEPARTMENT_ID_t
      )
      RETURN EMPLOYEE_TP.EMPLOYEE_rc
   IS
      retval EMPLOYEE_TP.EMPLOYEE_rc;
   BEGIN
      OPEN retval FOR
         SELECT
            EMPLOYEE_ID,
            LAST_NAME,
            FIRST_NAME,
            MIDDLE_INITIAL,
            JOB_ID,
            MANAGER_ID,
            HIRE_DATE,
            SALARY,
            COMMISSION,
            DEPARTMENT_ID,
            EMPNO,
            ENAME,
            CREATED_BY,
            CREATED_ON,
            CHANGED_BY,
            CHANGED_ON
           FROM EMPLOYEE
       WHERE
          DEPARTMENT_ID = ar_FK_EMP_DEPARTMENT_cv.department_id_in

         ;
      RETURN retval;
   END ar_FK_EMP_DEPARTMENT_cv;

   FUNCTION in_FK_EMP_DEPARTMENT_cv (
      department_id_in IN VARCHAR2
      )
      RETURN EMPLOYEE_TP.weak_refcur
   IS
      retval EMPLOYEE_TP.weak_refcur;
   BEGIN
      OPEN retval FOR
         'SELECT
            EMPLOYEE_ID,
            LAST_NAME,
            FIRST_NAME,
            MIDDLE_INITIAL,
            JOB_ID,
            MANAGER_ID,
            HIRE_DATE,
            SALARY,
            COMMISSION,
            DEPARTMENT_ID,
            EMPNO,
            ENAME,
            CREATED_BY,
            CREATED_ON,
            CHANGED_BY,
            CHANGED_ON
           FROM EMPLOYEE
       WHERE
          DEPARTMENT_ID IN (' || department_id_in || ')
             '
         ;
      RETURN retval;
   END in_FK_EMP_DEPARTMENT_cv;

   FUNCTION ar_FK_EMP_DEPARTMENT (
      department_id_in IN EMPLOYEE_TP.DEPARTMENT_ID_t
      )
      RETURN EMPLOYEE_TP.EMPLOYEE_tc
   IS
      CURSOR allrows_cur
      IS
         SELECT
            EMPLOYEE_ID,
            LAST_NAME,
            FIRST_NAME,
            MIDDLE_INITIAL,
            JOB_ID,
            MANAGER_ID,
            HIRE_DATE,
            SALARY,
            COMMISSION,
            DEPARTMENT_ID,
            EMPNO,
            ENAME,
            CREATED_BY,
            CREATED_ON,
            CHANGED_BY,
            CHANGED_ON
           FROM EMPLOYEE
          WHERE
             DEPARTMENT_ID = ar_FK_EMP_DEPARTMENT.department_id_in

         ;
      l_rows PLS_INTEGER;
      retval EMPLOYEE_TP.EMPLOYEE_tc;
   BEGIN
      OPEN allrows_cur;
      FETCH allrows_cur BULK COLLECT INTO retval;
      RETURN retval;
   END ar_FK_EMP_DEPARTMENT;

   PROCEDURE ar_FK_EMP_DEPARTMENT (
      department_id_in IN EMPLOYEE_TP.DEPARTMENT_ID_t,
      employee_id_out OUT EMPLOYEE_TP.EMPLOYEE_ID_cc,
      last_name_out OUT EMPLOYEE_TP.LAST_NAME_cc,
      first_name_out OUT EMPLOYEE_TP.FIRST_NAME_cc,
      middle_initial_out OUT EMPLOYEE_TP.MIDDLE_INITIAL_cc,
      job_id_out OUT EMPLOYEE_TP.JOB_ID_cc,
      manager_id_out OUT EMPLOYEE_TP.MANAGER_ID_cc,
      hire_date_out OUT EMPLOYEE_TP.HIRE_DATE_cc,
      salary_out OUT EMPLOYEE_TP.SALARY_cc,
      commission_out OUT EMPLOYEE_TP.COMMISSION_cc,
      department_id_out OUT EMPLOYEE_TP.DEPARTMENT_ID_cc,
      empno_out OUT EMPLOYEE_TP.EMPNO_cc,
      ename_out OUT EMPLOYEE_TP.ENAME_cc,
      created_by_out OUT EMPLOYEE_TP.CREATED_BY_cc,
      created_on_out OUT EMPLOYEE_TP.CREATED_ON_cc,
      changed_by_out OUT EMPLOYEE_TP.CHANGED_BY_cc,
      changed_on_out OUT EMPLOYEE_TP.CHANGED_ON_cc
      )
   IS
   BEGIN
      SELECT
            EMPLOYEE_ID,
            LAST_NAME,
            FIRST_NAME,
            MIDDLE_INITIAL,
            JOB_ID,
            MANAGER_ID,
            HIRE_DATE,
            SALARY,
            COMMISSION,
            DEPARTMENT_ID,
            EMPNO,
            ENAME,
            CREATED_BY,
            CREATED_ON,
            CHANGED_BY,
            CHANGED_ON
        BULK COLLECT INTO
            employee_id_out,
            last_name_out,
            first_name_out,
            middle_initial_out,
            job_id_out,
            manager_id_out,
            hire_date_out,
            salary_out,
            commission_out,
            department_id_out,
            empno_out,
            ename_out,
            created_by_out,
            created_on_out,
            changed_by_out,
            changed_on_out
        FROM EMPLOYEE
       WHERE
             DEPARTMENT_ID = ar_FK_EMP_DEPARTMENT.department_id_in

      ;
   END ar_FK_EMP_DEPARTMENT;

   -- Number of rows by FK_EMP_DEPARTMENT
   FUNCTION num_FK_EMP_DEPARTMENT (
      department_id_in IN EMPLOYEE_TP.DEPARTMENT_ID_t
      )
      RETURN PLS_INTEGER
   IS
      retval PLS_INTEGER;
   BEGIN
      SELECT COUNT(*)
        INTO retval
        FROM EMPLOYEE
       WHERE
             DEPARTMENT_ID = department_id_in
      ;
      RETURN retval;
   END num_FK_EMP_DEPARTMENT;

   FUNCTION ex_FK_EMP_DEPARTMENT (
      department_id_in IN EMPLOYEE_TP.DEPARTMENT_ID_t
      )
      RETURN BOOLEAN
   IS
      l_dummy PLS_INTEGER;
   BEGIN
      SELECT 1 INTO l_dummy
        FROM EMPLOYEE
       WHERE
             DEPARTMENT_ID = department_id_in
      ;
      RETURN TRUE;
   EXCEPTION WHEN NO_DATA_FOUND THEN RETURN FALSE;
             WHEN TOO_MANY_ROWS THEN RETURN TRUE;
   END ex_FK_EMP_DEPARTMENT;

   FUNCTION ar_FK_EMP_JOB_cv (
      job_id_in IN EMPLOYEE_TP.JOB_ID_t
      )
      RETURN EMPLOYEE_TP.EMPLOYEE_rc
   IS
      retval EMPLOYEE_TP.EMPLOYEE_rc;
   BEGIN
      OPEN retval FOR
         SELECT
            EMPLOYEE_ID,
            LAST_NAME,
            FIRST_NAME,
            MIDDLE_INITIAL,
            JOB_ID,
            MANAGER_ID,
            HIRE_DATE,
            SALARY,
            COMMISSION,
            DEPARTMENT_ID,
            EMPNO,
            ENAME,
            CREATED_BY,
            CREATED_ON,
            CHANGED_BY,
            CHANGED_ON
           FROM EMPLOYEE
       WHERE
          JOB_ID = ar_FK_EMP_JOB_cv.job_id_in

         ;
      RETURN retval;
   END ar_FK_EMP_JOB_cv;

   FUNCTION in_FK_EMP_JOB_cv (
      job_id_in IN VARCHAR2
      )
      RETURN EMPLOYEE_TP.weak_refcur
   IS
      retval EMPLOYEE_TP.weak_refcur;
   BEGIN
      OPEN retval FOR
         'SELECT
            EMPLOYEE_ID,
            LAST_NAME,
            FIRST_NAME,
            MIDDLE_INITIAL,
            JOB_ID,
            MANAGER_ID,
            HIRE_DATE,
            SALARY,
            COMMISSION,
            DEPARTMENT_ID,
            EMPNO,
            ENAME,
            CREATED_BY,
            CREATED_ON,
            CHANGED_BY,
            CHANGED_ON
           FROM EMPLOYEE
       WHERE
          JOB_ID IN (' || job_id_in || ')
             '
         ;
      RETURN retval;
   END in_FK_EMP_JOB_cv;

   FUNCTION ar_FK_EMP_JOB (
      job_id_in IN EMPLOYEE_TP.JOB_ID_t
      )
      RETURN EMPLOYEE_TP.EMPLOYEE_tc
   IS
      CURSOR allrows_cur
      IS
         SELECT
            EMPLOYEE_ID,
            LAST_NAME,
            FIRST_NAME,
            MIDDLE_INITIAL,
            JOB_ID,
            MANAGER_ID,
            HIRE_DATE,
            SALARY,
            COMMISSION,
            DEPARTMENT_ID,
            EMPNO,
            ENAME,
            CREATED_BY,
            CREATED_ON,
            CHANGED_BY,
            CHANGED_ON
           FROM EMPLOYEE
          WHERE
             JOB_ID = ar_FK_EMP_JOB.job_id_in

         ;
      l_rows PLS_INTEGER;
      retval EMPLOYEE_TP.EMPLOYEE_tc;
   BEGIN
      OPEN allrows_cur;
      FETCH allrows_cur BULK COLLECT INTO retval;
      RETURN retval;
   END ar_FK_EMP_JOB;

   PROCEDURE ar_FK_EMP_JOB (
      job_id_in IN EMPLOYEE_TP.JOB_ID_t,
      employee_id_out OUT EMPLOYEE_TP.EMPLOYEE_ID_cc,
      last_name_out OUT EMPLOYEE_TP.LAST_NAME_cc,
      first_name_out OUT EMPLOYEE_TP.FIRST_NAME_cc,
      middle_initial_out OUT EMPLOYEE_TP.MIDDLE_INITIAL_cc,
      job_id_out OUT EMPLOYEE_TP.JOB_ID_cc,
      manager_id_out OUT EMPLOYEE_TP.MANAGER_ID_cc,
      hire_date_out OUT EMPLOYEE_TP.HIRE_DATE_cc,
      salary_out OUT EMPLOYEE_TP.SALARY_cc,
      commission_out OUT EMPLOYEE_TP.COMMISSION_cc,
      department_id_out OUT EMPLOYEE_TP.DEPARTMENT_ID_cc,
      empno_out OUT EMPLOYEE_TP.EMPNO_cc,
      ename_out OUT EMPLOYEE_TP.ENAME_cc,
      created_by_out OUT EMPLOYEE_TP.CREATED_BY_cc,
      created_on_out OUT EMPLOYEE_TP.CREATED_ON_cc,
      changed_by_out OUT EMPLOYEE_TP.CHANGED_BY_cc,
      changed_on_out OUT EMPLOYEE_TP.CHANGED_ON_cc
      )
   IS
   BEGIN
      SELECT
            EMPLOYEE_ID,
            LAST_NAME,
            FIRST_NAME,
            MIDDLE_INITIAL,
            JOB_ID,
            MANAGER_ID,
            HIRE_DATE,
            SALARY,
            COMMISSION,
            DEPARTMENT_ID,
            EMPNO,
            ENAME,
            CREATED_BY,
            CREATED_ON,
            CHANGED_BY,
            CHANGED_ON
        BULK COLLECT INTO
            employee_id_out,
            last_name_out,
            first_name_out,
            middle_initial_out,
            job_id_out,
            manager_id_out,
            hire_date_out,
            salary_out,
            commission_out,
            department_id_out,
            empno_out,
            ename_out,
            created_by_out,
            created_on_out,
            changed_by_out,
            changed_on_out
        FROM EMPLOYEE
       WHERE
             JOB_ID = ar_FK_EMP_JOB.job_id_in

      ;
   END ar_FK_EMP_JOB;

   -- Number of rows by FK_EMP_JOB
   FUNCTION num_FK_EMP_JOB (
      job_id_in IN EMPLOYEE_TP.JOB_ID_t
      )
      RETURN PLS_INTEGER
   IS
      retval PLS_INTEGER;
   BEGIN
      SELECT COUNT(*)
        INTO retval
        FROM EMPLOYEE
       WHERE
             JOB_ID = job_id_in
      ;
      RETURN retval;
   END num_FK_EMP_JOB;

   FUNCTION ex_FK_EMP_JOB (
      job_id_in IN EMPLOYEE_TP.JOB_ID_t
      )
      RETURN BOOLEAN
   IS
      l_dummy PLS_INTEGER;
   BEGIN
      SELECT 1 INTO l_dummy
        FROM EMPLOYEE
       WHERE
             JOB_ID = job_id_in
      ;
      RETURN TRUE;
   EXCEPTION WHEN NO_DATA_FOUND THEN RETURN FALSE;
             WHEN TOO_MANY_ROWS THEN RETURN TRUE;
   END ex_FK_EMP_JOB;

   FUNCTION ar_FK_EMP_MANAGER_cv (
      manager_id_in IN EMPLOYEE_TP.MANAGER_ID_t
      )
      RETURN EMPLOYEE_TP.EMPLOYEE_rc
   IS
      retval EMPLOYEE_TP.EMPLOYEE_rc;
   BEGIN
      OPEN retval FOR
         SELECT
            EMPLOYEE_ID,
            LAST_NAME,
            FIRST_NAME,
            MIDDLE_INITIAL,
            JOB_ID,
            MANAGER_ID,
            HIRE_DATE,
            SALARY,
            COMMISSION,
            DEPARTMENT_ID,
            EMPNO,
            ENAME,
            CREATED_BY,
            CREATED_ON,
            CHANGED_BY,
            CHANGED_ON
           FROM EMPLOYEE
       WHERE
          MANAGER_ID = ar_FK_EMP_MANAGER_cv.manager_id_in

         ;
      RETURN retval;
   END ar_FK_EMP_MANAGER_cv;

   FUNCTION in_FK_EMP_MANAGER_cv (
      manager_id_in IN VARCHAR2
      )
      RETURN EMPLOYEE_TP.weak_refcur
   IS
      retval EMPLOYEE_TP.weak_refcur;
   BEGIN
      OPEN retval FOR
         'SELECT
            EMPLOYEE_ID,
            LAST_NAME,
            FIRST_NAME,
            MIDDLE_INITIAL,
            JOB_ID,
            MANAGER_ID,
            HIRE_DATE,
            SALARY,
            COMMISSION,
            DEPARTMENT_ID,
            EMPNO,
            ENAME,
            CREATED_BY,
            CREATED_ON,
            CHANGED_BY,
            CHANGED_ON
           FROM EMPLOYEE
       WHERE
          MANAGER_ID IN (' || manager_id_in || ')
             '
         ;
      RETURN retval;
   END in_FK_EMP_MANAGER_cv;

   FUNCTION ar_FK_EMP_MANAGER (
      manager_id_in IN EMPLOYEE_TP.MANAGER_ID_t
      )
      RETURN EMPLOYEE_TP.EMPLOYEE_tc
   IS
      CURSOR allrows_cur
      IS
         SELECT
            EMPLOYEE_ID,
            LAST_NAME,
            FIRST_NAME,
            MIDDLE_INITIAL,
            JOB_ID,
            MANAGER_ID,
            HIRE_DATE,
            SALARY,
            COMMISSION,
            DEPARTMENT_ID,
            EMPNO,
            ENAME,
            CREATED_BY,
            CREATED_ON,
            CHANGED_BY,
            CHANGED_ON
           FROM EMPLOYEE
          WHERE
             MANAGER_ID = ar_FK_EMP_MANAGER.manager_id_in

         ;
      l_rows PLS_INTEGER;
      retval EMPLOYEE_TP.EMPLOYEE_tc;
   BEGIN
      OPEN allrows_cur;
      FETCH allrows_cur BULK COLLECT INTO retval;
      RETURN retval;
   END ar_FK_EMP_MANAGER;

   PROCEDURE ar_FK_EMP_MANAGER (
      manager_id_in IN EMPLOYEE_TP.MANAGER_ID_t,
      employee_id_out OUT EMPLOYEE_TP.EMPLOYEE_ID_cc,
      last_name_out OUT EMPLOYEE_TP.LAST_NAME_cc,
      first_name_out OUT EMPLOYEE_TP.FIRST_NAME_cc,
      middle_initial_out OUT EMPLOYEE_TP.MIDDLE_INITIAL_cc,
      job_id_out OUT EMPLOYEE_TP.JOB_ID_cc,
      manager_id_out OUT EMPLOYEE_TP.MANAGER_ID_cc,
      hire_date_out OUT EMPLOYEE_TP.HIRE_DATE_cc,
      salary_out OUT EMPLOYEE_TP.SALARY_cc,
      commission_out OUT EMPLOYEE_TP.COMMISSION_cc,
      department_id_out OUT EMPLOYEE_TP.DEPARTMENT_ID_cc,
      empno_out OUT EMPLOYEE_TP.EMPNO_cc,
      ename_out OUT EMPLOYEE_TP.ENAME_cc,
      created_by_out OUT EMPLOYEE_TP.CREATED_BY_cc,
      created_on_out OUT EMPLOYEE_TP.CREATED_ON_cc,
      changed_by_out OUT EMPLOYEE_TP.CHANGED_BY_cc,
      changed_on_out OUT EMPLOYEE_TP.CHANGED_ON_cc
      )
   IS
   BEGIN
      SELECT
            EMPLOYEE_ID,
            LAST_NAME,
            FIRST_NAME,
            MIDDLE_INITIAL,
            JOB_ID,
            MANAGER_ID,
            HIRE_DATE,
            SALARY,
            COMMISSION,
            DEPARTMENT_ID,
            EMPNO,
            ENAME,
            CREATED_BY,
            CREATED_ON,
            CHANGED_BY,
            CHANGED_ON
        BULK COLLECT INTO
            employee_id_out,
            last_name_out,
            first_name_out,
            middle_initial_out,
            job_id_out,
            manager_id_out,
            hire_date_out,
            salary_out,
            commission_out,
            department_id_out,
            empno_out,
            ename_out,
            created_by_out,
            created_on_out,
            changed_by_out,
            changed_on_out
        FROM EMPLOYEE
       WHERE
             MANAGER_ID = ar_FK_EMP_MANAGER.manager_id_in

      ;
   END ar_FK_EMP_MANAGER;

   -- Number of rows by FK_EMP_MANAGER
   FUNCTION num_FK_EMP_MANAGER (
      manager_id_in IN EMPLOYEE_TP.MANAGER_ID_t
      )
      RETURN PLS_INTEGER
   IS
      retval PLS_INTEGER;
   BEGIN
      SELECT COUNT(*)
        INTO retval
        FROM EMPLOYEE
       WHERE
             MANAGER_ID = manager_id_in
      ;
      RETURN retval;
   END num_FK_EMP_MANAGER;

   FUNCTION ex_FK_EMP_MANAGER (
      manager_id_in IN EMPLOYEE_TP.MANAGER_ID_t
      )
      RETURN BOOLEAN
   IS
      l_dummy PLS_INTEGER;
   BEGIN
      SELECT 1 INTO l_dummy
        FROM EMPLOYEE
       WHERE
             MANAGER_ID = manager_id_in
      ;
      RETURN TRUE;
   EXCEPTION WHEN NO_DATA_FOUND THEN RETURN FALSE;
             WHEN TOO_MANY_ROWS THEN RETURN TRUE;
   END ex_FK_EMP_MANAGER;

    -- Number of rows in table
   FUNCTION tabcount (
      where_clause_in IN VARCHAR2 := NULL)
      RETURN PLS_INTEGER
   IS
      retval PLS_INTEGER;
   BEGIN
      IF where_clause_in IS NULL
      THEN
         SELECT COUNT(*) INTO retval FROM EMPLOYEE;
      ELSE
         EXECUTE IMMEDIATE
            'SELECT COUNT(*) FROM EMPLOYEE
              WHERE ' || where_clause_in
            INTO retval;
      END IF;
      RETURN retval;
   END tabcount;

   -- Number of rows by primary key
   FUNCTION pkycount (
      employee_id_in IN EMPLOYEE_TP.EMPLOYEE_ID_t
      )
   RETURN PLS_INTEGER
   IS
      retval PLS_INTEGER;
   BEGIN
      SELECT COUNT(*)
        INTO retval
        FROM EMPLOYEE
       WHERE
             EMPLOYEE_ID = employee_id_in
      ;
      RETURN retval;
   END pkycount;

   -- Number of rows in table
   FUNCTION ex_EMPLOYEE (
      where_clause_in IN VARCHAR2 := NULL)
      RETURN BOOLEAN
   IS
      l_dummy PLS_INTEGER;
   BEGIN
      IF where_clause_in IS NULL
      THEN
         SELECT 1 INTO l_dummy FROM EMPLOYEE;
      ELSE
         EXECUTE IMMEDIATE
            'SELECT 1 FROM EMPLOYEE
              WHERE ' || where_clause_in
            INTO l_dummy;
      END IF;
      RETURN TRUE;
   EXCEPTION WHEN NO_DATA_FOUND THEN RETURN FALSE;
             WHEN TOO_MANY_ROWS THEN RETURN TRUE;
   END ex_EMPLOYEE;

    -- Number of rows by primary key
   FUNCTION ex_pky (
      employee_id_in IN EMPLOYEE_TP.EMPLOYEE_ID_t
      )
   RETURN BOOLEAN
   IS
      l_dummy PLS_INTEGER;
   BEGIN
      SELECT 1
        INTO l_dummy
        FROM EMPLOYEE
       WHERE
             EMPLOYEE_ID = employee_id_in
      ;
      RETURN TRUE;
   EXCEPTION WHEN NO_DATA_FOUND THEN RETURN FALSE;
             WHEN TOO_MANY_ROWS THEN RETURN TRUE;
   END ex_pky;
BEGIN
   NULL;
END EMPLOYEE_QP;
/
