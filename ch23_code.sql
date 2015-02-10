/*
Oracle PL/SQL Programming 5th Edition

www.stevenfeuerstein.com/books

Objection creation and example scripts for Chapter 23

You will find below all non-trivial code snippets from the above chapter
that are NOT contained in their own files (as specified in the chapter),
plus any DDL object creation scripts required to get a clean compile
on the snippets.

Any references to Oracle's standard HR tables (employees, departments,
locations, regions, etc.) will NOT include the DDL creation scripts
in this file. Instead, run the hr_schema_install.sql script and all
those tables and related elements will be defined.
*/

DECLARE
   l_level   PLS_INTEGER;
BEGIN
   l_level :=
        DBMS_CRYPTO.encrypt_aes128
      + DBMS_CRYPTO.chain_cbc
      + DBMS_CRYPTO.pad_pkcs5;

   l_level :=
        DBMS_CRYPTO.encrypt_aes128
      + DBMS_CRYPTO.chain_cbc
      + DBMS_CRYPTO.pad_none;
END;
/

DECLARE
   l_raw      RAW (200);
   l_in_val   VARCHAR2 (200) := 'Confidential Data';
BEGIN
   l_raw := UTL_I18N.string_to_raw (l_in_val, 'AL32UTF8');
END;
/

DECLARE
   l_key   RAW (16);
BEGIN
   l_key := DBMS_CRYPTO.randombytes (16);
END;
/

DECLARE
   l_in_val   VARCHAR2 (2000) := 'Critical Data';
   l_key      VARCHAR2 (2000) := 'SecretKey';
   l_mac      RAW (2000);
BEGIN
   l_mac :=
      DBMS_CRYPTO.mac (src => UTL_I18N.string_to_raw (l_in_val, 'AL32UTF8')
                     , typ => DBMS_CRYPTO.hmac_sh1
                     , key => UTL_I18N.string_to_raw (l_key, 'AL32UTF8')
                      );
   DBMS_OUTPUT.put_line ('MAC=' || l_mac);
   -- let's use a different key
   l_key := 'Another Key';
   l_mac :=
      DBMS_CRYPTO.mac (src => UTL_I18N.string_to_raw (l_in_val, 'AL32UTF8')
                     , typ => DBMS_CRYPTO.hmac_sh1
                     , key => UTL_I18N.string_to_raw (l_key, 'AL32UTF8')
                      );
   DBMS_OUTPUT.put_line ('MAC=' || l_mac);
END;
/

ALTER TABLE accounts MODIFY (ssn ENCRYPT USING 'AES256')
/

ALTER SYSTEM SET ENCRYPTION WALLET OPEN AUTHENTICATED BY "pooh"
/

CREATE TABLESPACE securets1
   DATAFILE '+DG1/securets1_01.dbf'
   SIZE 10 M
   ENCRYPTION USING 'AES128'
   DEFAULT STORAGE (ENCRYPT)
/

DROP TABLE emp CASCADE CONSTRAINTS
/

CREATE TABLE emp
(
   empno      NUMBER (4)
 , ename      VARCHAR2 (10 BYTE)
 , job        VARCHAR2 (9 BYTE)
 , mgr        NUMBER (4)
 , hiredate   DATE
 , sal        NUMBER (7, 2)
 , comm       NUMBER (7, 2)
 , deptno     NUMBER (2)
)
/

CREATE OR REPLACE FUNCTION authorized_emps (p_schema_name IN VARCHAR2
                                          , p_object_name IN VARCHAR2
                                           )
   RETURN VARCHAR2
IS
   l_return_val   VARCHAR2 (2000);
BEGIN
   l_return_val := 'SAL <= 1500';
   RETURN l_return_val;
END authorized_emps;
/

DECLARE
   l_return_string   VARCHAR2 (2000);
BEGIN
   l_return_string := authorized_emps ('X', 'X');
   DBMS_OUTPUT.put_line ('Return String = "' || l_return_string || '"');
END;
/

BEGIN
   DBMS_RLS.add_policy (object_schema => 'HR'
                      , object_name => 'EMP'
                      , policy_name => 'EMP_POLICY'
                      , function_schema => 'HR'
                      , policy_function => 'AUTHORIZED_EMPS'
                      , statement_types => 'INSERT, UPDATE, DELETE, SELECT'
                       );
END;
/

BEGIN
   DBMS_RLS.add_policy (
      object_schema => 'HR'
    , object_name => 'EMP'
    , policy_name => 'EMP_POLICY'
    , function_schema => 'HR'
    , policy_function => 'AUTHORIZED_EMPS'
    , statement_types => 'INSERT, UPDATE, DELETE, SELECT, INDEX'
   );
END;
/

BEGIN
   DBMS_RLS.drop_policy (object_schema => 'HR'
                       , object_name => 'EMP'
                       , policy_name => 'EMP_POLICY'
                        );
END;
/

BEGIN
   DBMS_RLS.add_policy (object_name => 'EMP'
                      , policy_name => 'EMP_POLICY'
                      , function_schema => 'HR'
                      , policy_function => 'AUTHORIZED_EMPS'
                      , statement_types => 'INSERT, UPDATE, DELETE, SELECT'
                      , update_check => TRUE
                       );
END;
/

CREATE OR REPLACE FUNCTION authorized_emps (p_schema_name IN VARCHAR2
                                          , p_object_name IN VARCHAR2
                                           )
   RETURN VARCHAR2
IS
   l_deptno       NUMBER;
   l_return_val   VARCHAR2 (2000);
BEGIN
   IF (p_schema_name = USER)
   THEN
      l_return_val := NULL;
   ELSE
      SELECT deptno
        INTO l_deptno
        FROM emp
       WHERE ename = USER;

      l_return_val := 'DEPTNO = ' || l_deptno;
   END IF;

   RETURN l_return_val;
END;
/

BEGIN
   DBMS_RLS.drop_policy (object_schema => 'HR'
                       , object_name => 'DEPT'
                       , policy_name => 'EMP_DEPT_POLICY'
                        );
   DBMS_RLS.add_policy (object_schema => 'HR'
                      , object_name => 'DEPT'
                      , policy_name => 'EMP_DEPT_POLICY'
                      , function_schema => 'RLSOWNER'
                      , policy_function => 'AUTHORIZED_EMPS'
                      , statement_types => 'SELECT, INSERT, UPDATE, DELETE'
                      , update_check => TRUE
                      , policy_type => DBMS_RLS.shared_static
                       );
   DBMS_RLS.add_policy (object_schema => 'HR'
                      , object_name => 'EMP'
                      , policy_name => 'EMP_DEPT_POLICY'
                      , function_schema => 'RLSOWNER'
                      , policy_function => 'AUTHORIZED_EMPS'
                      , statement_types => 'SELECT, INSERT, UPDATE, DELETE'
                      , update_check => TRUE
                      , policy_type => DBMS_RLS.shared_static
                       );
END;
/

BEGIN
   DBMS_RLS.drop_policy (object_schema => 'HR'
                       , object_name => 'DEPT'
                       , policy_name => 'EMP_DEPT_POLICY'
                        );
   DBMS_RLS.add_policy (object_schema => 'HR'
                      , object_name => 'DEPT'
                      , policy_name => 'EMP_DEPT_POLICY'
                      , function_schema => 'RLSOWNER'
                      , policy_function => 'AUTHORIZED_EMPS'
                      , statement_types => 'SELECT, INSERT, UPDATE, DELETE'
                      , update_check => TRUE
                      , policy_type => DBMS_RLS.context_sensitive
                       );
   DBMS_RLS.add_policy (object_schema => 'HR'
                      , object_name => 'EMP'
                      , policy_name => 'EMP_DEPT_POLICY'
                      , function_schema => 'RLSOWNER'
                      , policy_function => 'AUTHORIZED_EMPS'
                      , statement_types => 'SELECT, INSERT, UPDATE, DELETE'
                      , update_check => TRUE
                      , policy_type => DBMS_RLS.context_sensitive23
                       );
END;
/

DECLARE
   l_start_time   PLS_INTEGER;
   l_count        PLS_INTEGER;
BEGIN
   l_start_time := DBMS_UTILITY.get_time;

   SELECT COUNT ( * )
     INTO l_count
     FROM emp;

   DBMS_OUTPUT.put_line (DBMS_UTILITY.get_time - l_start_time);
END;
/

BEGIN
   /* Drop the policy first. */
   DBMS_RLS.drop_policy (object_schema => 'HR'
                       , object_name => 'EMP'
                       , policy_name => 'EMP_POLICY'
                        );
   /* Add the policy. */
   DBMS_RLS.add_policy (object_schema => 'HR'
                      , object_name => 'EMP'
                      , policy_name => 'EMP_POLICY'
                      , function_schema => 'RLSOWNER'
                      , policy_function => 'AUTHORIZED_EMPS'
                      , statement_types => 'INSERT, UPDATE, DELETE, SELECT'
                      , update_check => TRUE
                      , sec_relevant_cols => 'SAL, COMM'
                       );
END;
/

BEGIN
   DBMS_RLS.drop_policy (object_schema => 'HR'
                       , object_name => 'EMP'
                       , policy_name => 'EMP_POLICY'
                        );
   DBMS_RLS.add_policy (object_schema => 'HR'
                      , object_name => 'EMP'
                      , policy_name => 'EMP_POLICY'
                      , function_schema => 'RLSOWNER'
                      , policy_function => 'AUTHORIZED_EMPS'
                      , statement_types => 'SELECT'
                      , update_check => TRUE
                      , sec_relevant_cols => 'SAL, COMM'
                      , sec_relevant_cols_opt => DBMS_RLS.all_rows
                       );
END;
/

CREATE OR REPLACE PROCEDURE set_dept_ctx (p_attr IN VARCHAR2
                                        , p_val  IN VARCHAR2
                                         )
IS
BEGIN
   DBMS_SESSION.set_context ('DEPT_CTX', p_attr, p_val);
END;
/

DECLARE
   l_ret   VARCHAR2 (20);
BEGIN
   l_ret := SYS_CONTEXT ('DEPT_CTX', 'DEPTNO');
   DBMS_OUTPUT.put_line ('Value of DEPTNO = ' || l_ret);
END;
/

BEGIN
   DBMS_OUTPUT.put_line (
      'The Terminal ID is ' || SYS_CONTEXT ('USERENV', 'TERMINAL')
   );
END;
/

BEGIN
   DBMS_FGA.add_policy (object_schema => 'HR'
                      , object_name => 'EMP'
                      , policy_name => 'EMP_SEL'
                      , audit_column => 'SAL, COMM'
                      , audit_condition => 'SAL >= 150000 OR EMPID = 100'
                       );
END;
/

BEGIN
   DBMS_FGA.add_policy (object_schema => 'HR'
                      , object_name => 'EMP'
                      , policy_name => 'EMP_DML'
                      , audit_column => 'SALARY, COMM'
                      , audit_condition => 'SALARY >= 150000 OR EMPID = 100'
                      , statement_types => 'SELECT, INSERT, DELETE, UPDATE'
                       );
END;
/

BEGIN
   DBMS_FGA.add_policy (object_schema => 'HR'
                      , object_name => 'EMP'
                      , policy_name => 'EMP_SEL'
                      , audit_column => 'SALARY, COMM'
                      , audit_condition => 'USER=''SCOTT'''
                       );
END;
/

BEGIN
   DBMS_FGA.add_policy (object_schema => 'HR'
                      , object_name => 'EMP'
                      , policy_name => 'EMP_DML'
                      , audit_column => 'SALARY, EMPNAME'
                      , audit_condition => 'USER=''SCOTT'''
                      , statement_types => 'SELECT, INSERT, DELETE, UPDATE'
                      , audit_column_opts => DBMS_FGA.all_columns
                       );
END;
/

SELECT db_user, sql_text
  FROM dba_fga_audit_trail
 WHERE object_schema = 'HR' AND object_name = 'EMP'
/

DECLARE
   l_empid    PLS_INTEGER := 100;
   l_salary   NUMBER := 150000;

   TYPE emps_t IS TABLE OF emp%ROWTYPE;

   l_emps     empts_t;
BEGIN
   SELECT *
     BULK COLLECT
     INTO l_emps
     FROM hr.emp
    WHERE empid = l_empid OR salary > l_salary;
END;
/

BEGIN
   DBMS_FGA.add_policy (object_schema => 'HR'
                      , object_name => 'EMP'
                      , policy_name => 'EMP_SEL'
                      , audit_column => 'SALARY, COMM'
                      , audit_condition => 'SALARY >= 150000 OR EMPID = 100'
                      , handler_schema => 'FGA_ADMIN'
                      , handler_module => 'MYPROC'
                       );
END;
/