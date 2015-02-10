
DEFINE num_rows = &data_sample_size;

CREATE OR REPLACE DIRECTORY dir AS 'd:\oracle\dir';

DECLARE
   f UTL_FILE.FILE_TYPE := UTL_FILE.FOPEN('DIR', 'employees.dat', 'w');
   n PLS_INTEGER := &num_rows;
BEGIN
   FOR r IN (SELECT ROWNUM + 100000 AS employee_id
             ,      first_name
             ,      last_name
             ,      email
             ,      phone_number
             ,      hire_date
             ,      job_id
             ,      salary
             ,      commission_pct
             ,      manager_id
             ,      department_id
             FROM   hr.employees
             ,     (SELECT ROWNUM AS r FROM dual CONNECT BY ROWNUM <= n)
             WHERE  ROWNUM <= n)
   LOOP
      UTL_FILE.PUT_LINE(f, r.employee_id || ',' || r.first_name || ',' || r.last_name  || ',' ||
                           r.email || ',' || r.phone_number || ',' || TO_CHAR(r.hire_date, 'DD/MM/YYYY') || ',' ||
                           r.job_id || ',' || r.salary || ',' || r.commission_pct || ',' ||
                           r.manager_id || ',' || r.department_id );
   END LOOP;
   UTL_FILE.FCLOSE(f);
END;
/

CREATE TABLE employees_staging
( employee_id    NUMBER(6)
, first_name     VARCHAR2(20)
, last_name      VARCHAR2(25)
, email          VARCHAR2(25)
, phone_number   VARCHAR2(20)
, hire_date      DATE
, job_id         VARCHAR2(10)
, salary         NUMBER(8,2)
, commission_pct NUMBER(2,2)
, manager_id     NUMBER(6)
, department_id  NUMBER(4)
)
ORGANIZATION EXTERNAL
(
  TYPE ORACLE_LOADER
  DEFAULT DIRECTORY dir
  ACCESS PARAMETERS
  (
     RECORDS DELIMITED by NEWLINE
     NOBADFILE
     NOLOGFILE
     NODISCARDFILE
     FIELDS TERMINATED BY ','
     MISSING FIELD VALUES ARE NULL
     ( employee_id
     , first_name
     , last_name
     , email
     , phone_number
     , hire_date CHAR(20) DATE_FORMAT DATE MASK "DD/MM/YYYY"
     , job_id
     , salary
     , commission_pct
     , manager_id
     , department_id 
     )
  )
  LOCATION ('employees.dat')
)
REJECT LIMIT 0;

exec DBMS_STATS.GATHER_TABLE_STATS(USER, 'EMPLOYEES_STAGING', estimate_percent=>NULL);

CREATE TABLE employees
( employee_id    NUMBER(6) PRIMARY KEY
, first_name     VARCHAR2(20)
, last_name      VARCHAR2(25) NOT NULL
, email          VARCHAR2(25) NOT NULL
, phone_number   VARCHAR2(20)
, hire_date      DATE         NOT NULL
, job_id         VARCHAR2(10) NOT NULL
, salary         NUMBER(8,2)
, commission_pct NUMBER(2,2)
, manager_id     NUMBER(6)
, department_id  NUMBER(4)
, last_update    DATE         NOT NULL
);

INSERT INTO employees
SELECT es.*, SYSDATE
FROM   employees_staging es
WHERE  ROWNUM <= &num_rows/2;

COMMIT;

exec DBMS_STATS.GATHER_TABLE_STATS(USER, 'EMPLOYEES', estimate_percent=>NULL);
 
CREATE TYPE employee_ot AS OBJECT
( employee_id    NUMBER(6)
, first_name     VARCHAR2(20)
, last_name      VARCHAR2(25)
, email          VARCHAR2(25)
, phone_number   VARCHAR2(20)
, hire_date      DATE
, job_id         VARCHAR2(10)
, salary         NUMBER(8,2)
, commission_pct NUMBER(2,2)
, manager_id     NUMBER(6)
, department_id  NUMBER(4)
, last_update    DATE
);
/

CREATE TYPE employee_ntt AS TABLE OF employee_ot;
/

CREATE OR REPLACE PACKAGE employee_pkg AS

   c_default_limit CONSTANT PLS_INTEGER := 100;

   TYPE employee_rct IS REF CURSOR
      RETURN employees_staging%ROWTYPE;

   TYPE employee_aat IS TABLE OF employees_staging%ROWTYPE
      INDEX BY PLS_INTEGER;

   SUBTYPE employees_staging_rt IS employees_staging%ROWTYPE;

   SUBTYPE employees_rt IS employees%ROWTYPE;

   PROCEDURE upsert_employees;

   FUNCTION pipe_employees( 
            p_source_data IN employee_pkg.employee_rct,
            p_limit_size  IN PLS_INTEGER DEFAULT employee_pkg.c_default_limit
            ) RETURN employee_ntt 
              PIPELINED
              PARALLEL_ENABLE (PARTITION p_source_data BY ANY);

   PROCEDURE merge_employees;

END employee_pkg;
/


CREATE PACKAGE BODY employee_pkg AS

   -----------------------------------------------------------------------
   PROCEDURE upsert_employees IS
      n PLS_INTEGER := 0;
   BEGIN
      FOR r_emp IN (SELECT * FROM employees_staging) LOOP

         UPDATE employees
         SET    first_name     = r_emp.first_name
         ,      last_name      = r_emp.last_name
         ,      email          = r_emp.email
         ,      phone_number   = r_emp.phone_number
         ,      hire_date      = r_emp.hire_date
         ,      job_id         = r_emp.job_id
         ,      salary         = r_emp.salary
         ,      commission_pct = r_emp.commission_pct
         ,      manager_id     = r_emp.manager_id
         ,      department_id  = r_emp.department_id
         ,      last_update    = SYSDATE
         WHERE  employee_id = r_emp.employee_id;

         IF SQL%ROWCOUNT = 0 THEN
            INSERT INTO employees ( employee_id, first_name, last_name
                                  , email, phone_number, hire_date
                                  , job_id, salary, commission_pct
                                  , manager_id, department_id, last_update )
            VALUES ( r_emp.employee_id, r_emp.first_name, r_emp.last_name
                   , r_emp.email, r_emp.phone_number, r_emp.hire_date
                   , r_emp.job_id, r_emp.salary, r_emp.commission_pct
                   , r_emp.manager_id, r_emp.department_id, SYSDATE );
         END IF;
         
         n := n + 1;

      END LOOP;

      DBMS_OUTPUT.PUT_LINE( n || ' rows merged.' );

   END upsert_employees;

   -----------------------------------------------------------------------
   FUNCTION pipe_employees( 
            p_source_data IN employee_pkg.employee_rct,
            p_limit_size  IN PLS_INTEGER DEFAULT employee_pkg.c_default_limit
            ) RETURN employee_ntt 
              PIPELINED
              PARALLEL_ENABLE (PARTITION p_source_data BY ANY) IS

      aa_source_data employee_pkg.employee_aat;

   BEGIN
      LOOP
         FETCH p_source_data BULK COLLECT INTO aa_source_data LIMIT p_limit_size;
         EXIT WHEN aa_source_data.COUNT = 0;

         FOR i IN 1 .. aa_source_data.COUNT LOOP
            PIPE ROW (employee_ot( aa_source_data(i).employee_id,
                                   aa_source_data(i).first_name,
                                   aa_source_data(i).last_name,
                                   aa_source_data(i).email,
                                   aa_source_data(i).phone_number,
                                   aa_source_data(i).hire_date,
                                   aa_source_data(i).job_id,
                                   aa_source_data(i).salary,
                                   aa_source_data(i).commission_pct,
                                   aa_source_data(i).manager_id,
                                   aa_source_data(i).department_id,
                                   SYSDATE));
         END LOOP;
      END LOOP;
      CLOSE p_source_data;
      RETURN;

   END pipe_employees;

   -----------------------------------------------------------------------
   PROCEDURE merge_employees IS
   BEGIN

      EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';

      MERGE /*+ PARALLEL(e, 4) */ 
         INTO  employees e
         USING TABLE(
                  employee_pkg.pipe_employees(
                     CURSOR(SELECT /*+ PARALLEL(es, 4) */ * FROM employees_staging es))) s
         ON   (e.employee_id = s.employee_id)
      WHEN MATCHED THEN
         UPDATE
         SET    e.first_name     = s.first_name
         ,      e.last_name      = s.last_name
         ,      e.email          = s.email
         ,      e.phone_number   = s.phone_number
         ,      e.hire_date      = s.hire_date
         ,      e.job_id         = s.job_id
         ,      e.salary         = s.salary
         ,      e.commission_pct = s.commission_pct
         ,      e.manager_id     = s.manager_id
         ,      e.department_id  = s.department_id
         ,      e.last_update    = SYSDATE
      WHEN NOT MATCHED THEN
         INSERT ( e.employee_id
                , e.first_name
                , e.last_name
                , e.email
                , e.phone_number
                , e.hire_date
                , e.job_id
                , e.salary
                , e.commission_pct
                , e.manager_id
                , e.department_id 
                , e.last_update
                )
         VALUES ( s.employee_id
                , s.first_name
                , s.last_name
                , s.email
                , s.phone_number
                , s.hire_date
                , s.job_id
                , s.salary
                , s.commission_pct
                , s.manager_id
                , s.department_id 
                , SYSDATE
                );

      DBMS_OUTPUT.PUT_LINE( SQL%ROWCOUNT || ' rows merged.' );

   END merge_employees;

END employee_pkg;
/

sho err
