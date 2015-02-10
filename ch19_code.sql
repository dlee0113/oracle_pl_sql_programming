/*
Oracle PL/SQL Programming 5th Edition

www.stevenfeuerstein.com/books

Objection creation and example scripts for Chapter 19

You will find below all non-trivial code snippets from the above chapter
that are NOT contained in their own files (as specified in the chapter),
plus any DDL object creation scripts required to get a clean compile
on the snippets.

Any references to Oracle's standard HR tables (employees, departments,
locations, regions, etc.) will NOT include the DDL creation scripts
in this file. Instead, run the hr_schema_install.sql script and all
those tables and related elements will be defined.
*/

CREATE OR REPLACE TRIGGER validate_employee_changes
   AFTER INSERT OR UPDATE
   ON employees
   FOR EACH ROW
DECLARE
   PROCEDURE check_date (date_in IN DATE)
   IS
   BEGIN
      NULL;
   END;

   PROCEDURE check_email (email_in IN VARCHAR2)
   IS
   BEGIN
      NULL;
   END;
BEGIN
   check_date (:new.hire_date);
   check_email (:new.email);
END;
/

DROP TABLE ceo_compensation
/

CREATE TABLE ceo_compensation (name VARCHAR2 (100), compensation NUMBER)
/

DROP TABLE ceo_comp_history
/

CREATE TABLE ceo_comp_history
(
   name               VARCHAR2 (100)
 , old_compensation   NUMBER
 , new_compensation   NUMBER
 , action             VARCHAR2 (100)
 , changed_on         DATE
)
/

CREATE OR REPLACE TRIGGER bef_ins_ceo_comp
   BEFORE INSERT
   ON ceo_compensation
   FOR EACH ROW
DECLARE
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   INSERT INTO ceo_comp_history
       VALUES (
                  :new.name
                , :old.compensation
                , :new.compensation
                , 'AFTER INSERT'
                , SYSDATE
              );

   COMMIT;
END;
/

CREATE OR REPLACE TRIGGER check_raise
   AFTER UPDATE OF salary
   ON employees
   FOR EACH ROW
   WHEN (   (old.salary != new.salary)
         OR (old.salary IS NULL AND new.salary IS NOT NULL)
         OR (old.salary IS NOT NULL AND new.salary IS NULL))
BEGIN
   NULL;
END;
/

/* Run bowlerama_tables.sql first */

SELECT bowler_id
     , game_id
     , frame_number
     , old_strike
     , new_strike
     , old_spare
     , new_spare
     , change_date
     , operation
  FROM frame_audit
/

CREATE OR REPLACE TRIGGER after_logon
   AFTER LOGON
   ON SCHEMA
DECLARE
   v_sql VARCHAR2 (100)
         :=    'ALTER SESSION ENABLE RESUMABLE '
            || 'TIMEOUT 10 NAME '
            || ''''
            || 'OLAP Session'
            || '''';
BEGIN
   EXECUTE IMMEDIATE v_sql;

   DBMS_SESSION.set_context ('OLAP Namespace'
                           , 'Customer ID'
                           , load_user_customer_id
                            );
END;
/

CREATE OR REPLACE TRIGGER before_logoff
   BEFORE LOGOFF
   ON DATABASE
BEGIN
   gather_session_stats;
END;
/

CREATE OR REPLACE TRIGGER error_echo
AFTER SERVERERROR
ON SCHEMA
BEGIN
  DBMS_OUTPUT.PUT_LINE ('You experienced an error');
END;
/