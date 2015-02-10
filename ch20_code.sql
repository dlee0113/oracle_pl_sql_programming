/*
Oracle PL/SQL Programming 5th Edition

www.stevenfeuerstein.com/books

Objection creation and example scripts for Chapter 20

You will find below all non-trivial code snippets from the above chapter
that are NOT contained in their own files (as specified in the chapter),
plus any DDL object creation scripts required to get a clean compile
on the snippets.

Any references to Oracle's standard HR tables (employees, departments,
locations, regions, etc.) will NOT include the DDL creation scripts
in this file. Instead, run the hr_schema_install.sql script and all
those tables and related elements will be defined.
*/

    SELECT RPAD (' ', 3 * (LEVEL - 1)) || name || ' (' || TYPE || ') '
      FROM user_dependencies
CONNECT BY PRIOR RTRIM (name || TYPE) =
              RTRIM (referenced_name || referenced_type)
START WITH referenced_name = 'name' AND referenced_type = 'type'
/

/* Loopback example */
    CREATE DATABASE LINK loopback
       CONNECT TO bob IDENTIFIED BY swordfish USING 'localhost'
/

CREATE OR REPLACE PROCEDURE volatilecode
AS
BEGIN
   NULL;
END;
/

    CREATE OR REPLACE SYNONYM volatile_syn FOR volatilecode@loopback
/

CREATE OR REPLACE PROCEDURE save_from_recompile
AS
BEGIN
   volatile_syn;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'ALTER SESSION SET REMOTE_DEPENDENCIES_MODE SIGNATURE';

   save_from_recompile;
END;
/

/* Example of hiding mgt of cursor for remote invocation use */

CREATE OR REPLACE PACKAGE BODY book_maint
AS
   prv_book_cur_status   BOOLEAN;

   PROCEDURE open_book_cur
   IS
   BEGIN
      IF NOT book_maint.book_cur%ISOPEN
      THEN
         OPEN book_maint.book_cur;
      END IF;
   END;

   FUNCTION next_book_rec
      RETURN books%ROWTYPE
   IS
      l_book_rec   books%ROWTYPE;
   BEGIN
      FETCH book_maint.book_cur
      INTO l_book_rec;

      prv_book_cur_status := book_maint.book_cur%FOUND;
      RETURN l_book_rec;
   END;

   FUNCTION book_cur_is_found
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN prv_book_cur_status;
   END;

   PROCEDURE close_book_cur
   IS
   BEGIN
      IF book_maint.book_cur%ISOPEN
      THEN
         CLOSE book_maint.book_cur;
      END IF;
   END;
END;
/

SELECT    'ALTER '
       || object_type
       || ' '
       || object_name
       || ' COMPILE REUSE SETTINGS;'
  FROM user_objects
 WHERE status = 'INVALID'
/

BEGIN
   DBMS_TRACE.set_plsql_trace (DBMS_TRACE.trace_all_calls);
   
   DBMS_TRACE.SET_PLSQL_TRACE (DBMS_TRACE.trace_enabled_calls);
   
   DBMS_TRACE.set_plsql_trace (DBMS_TRACE.trace_all_exceptions);
   
   DBMS_TRACE.SET_PLSQL_TRACE (DBMS_TRACE.trace_enabled_exceptions);

   DBMS_TRACE.clear_plsql_trace;
   
   DBMS_TRACE.SET_PLSQL_TRACE (DBMS_TRACE.trace_pause);
END;
/