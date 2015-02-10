SET SERVEROUTPUT ON FORMAT WRAPPED

/* First, I create a simplistic tracing package */

CREATE OR REPLACE PACKAGE trace_pkg
IS
   PROCEDURE trace_it (info_in IN VARCHAR2);
END;
/

/* Inside the trace utility, I call the call_stack_string function
   to get a single string with all the programs in the call stack.
   I ask it NOT include the top-level anonymous block, put a line
   break between each element in the stack. I also "register" the
   trace package so any calls to subprograms in that package will not
   be included in the trace string. */

CREATE OR REPLACE PACKAGE BODY trace_pkg
IS
   PROCEDURE trace_it (info_in IN VARCHAR2)
   IS
   BEGIN
      DBMS_OUTPUT.put_line (info_in);

      DBMS_OUTPUT.put_line (
         utl_call_stack_helper.call_stack_string (
            include_anon_block_in   => FALSE,
            use_line_breaks_in      => TRUE,
            trace_pkg_in            => 'TRACE_PKG'));

-- See comment below about the output for this version:
--      DBMS_OUTPUT.put_line (
--         utl_call_stack_helper.call_stack_string (
--            include_anon_block_in   => TRUE,
--            use_line_breaks_in      => FALSE,
--            trace_pkg_in            => NULL));
   END;
END;
/

/* I call the trace program inside a nested subprogram of the procedure. 

   In other words, as you would expect, my "application code" does not
   contain calls to UTL_CALL_STACK. All that instrumentation logic is
   hidden inside the trace package.
*/

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
         trace_pkg.trace_it ('called nested subprogram');
      END;
   BEGIN
      nested_in_proc1;
   END;
END pkg1;
/

CREATE OR REPLACE PROCEDURE proc2
IS
BEGIN
   pkg1.proc1;
END;
/

BEGIN
   proc2;
END;
/

/* You will see

called nested subprogram
PROC2 (4)
 -> PKG1.PROC1 (11)
 -> PKG1.PROC1.NESTED_IN_PROC1 (8)
 
But if you use ask to include all elements in the execution call 
stack when calling call_stack_string (the commented-out version), you will see:

__anonymous_block (2) -> PROC2 (4) -> PKG1.PROC1 (11) -> PKG1.PROC1.NESTED_IN_PROC1 (8) -> TRACE_PKG.TRACE_IT (15)

*/ 

CREATE OR REPLACE PROCEDURE proc1
IS
   PROCEDURE nested_in_proc1
   IS
   BEGIN
      RAISE PROGRAM_ERROR;
   END;
BEGIN
   utl_call_stack_helper.show_summary;
   utl_call_stack_helper.show_call_stack_at;
END;
/

CREATE OR REPLACE PACKAGE pkg1
IS
   PROCEDURE proc2;
END pkg1;
/

CREATE OR REPLACE PACKAGE BODY pkg1
IS
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
   FOR indx IN 1 .. 1000
   LOOP
      NULL;
   END LOOP;

   pkg1.proc2;
END;
/

BEGIN
   proc3;
EXCEPTION
   WHEN OTHERS
   THEN
      utl_call_stack_helper.show_backtrace;
END;
/

CREATE OR REPLACE PROCEDURE proc1
IS
   PROCEDURE nested_in_proc1
   IS
   BEGIN
      RAISE PROGRAM_ERROR;
   END;
BEGIN
   nested_in_proc1;
END;
/

BEGIN
   proc3;
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (utl_call_stack_helper.backtrace_to);
      utl_call_stack_helper.show_backtrace;
END;
/