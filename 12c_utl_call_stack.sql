SET SERVEROUTPUT ON

/* Some simple examples demonstrating the package */

/* 1. Show the unit-qualified name that includes
      a nested subprogram. */

CREATE OR REPLACE PACKAGE pkg1
IS
   PROCEDURE proc1;
END pkg1;
/

CREATE OR REPLACE PACKAGE BODY pkg1
IS
   PROCEDURE proc1
   IS
      PROCEDURE nested_in_proc1
      IS
      BEGIN
         DBMS_OUTPUT.put_line (
            utl_call_stack.concatenate_subprogram (
               utl_call_stack.subprogram (1)));
      END;
   BEGIN
      nested_in_proc1;
   END;
END pkg1;
/

BEGIN
   pkg1.proc1;
END;
/

/* Displays:

PKG1.PROC1.NESTED_IN_PROC1

Prior to 12c, you couldn't get any names beyond "PKG1".

*/

/* 2. Show the subprogram and line number on which 
      the error was raised. */


CREATE OR REPLACE FUNCTION backtrace_to
   RETURN VARCHAR2
IS
BEGIN
   RETURN    utl_call_stack.backtrace_unit (
                utl_call_stack.error_depth)
          || ' line '
          || utl_call_stack.backtrace_line (
                utl_call_stack.error_depth);
END;
/

CREATE OR REPLACE PACKAGE pkg1
IS
   PROCEDURE proc1;

   PROCEDURE proc2;
END;
/

CREATE OR REPLACE PACKAGE BODY pkg1
IS
   PROCEDURE proc1
   IS
      PROCEDURE nested_in_proc1
      IS
      BEGIN
         RAISE VALUE_ERROR;
      END;
   BEGIN
      nested_in_proc1;
   END;

   PROCEDURE proc2
   IS
   BEGIN
      proc1;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE NO_DATA_FOUND;
   END;
END pkg1;
/

CREATE OR REPLACE PROCEDURE proc3
IS
BEGIN
   pkg1.proc2;
END;
/

BEGIN
   proc3;
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (backtrace_to);
END;
/

/*
HR.PKG1 line 19
*/