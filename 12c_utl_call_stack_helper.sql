CREATE OR REPLACE PACKAGE utl_call_stack_helper
/*
Helper package for UTL_CALL_STACK (Oracle Database 12c Release 1)
Author: Steven Feuerstein, steven@stevenfeuerstein.com
*/
IS
   c_anonymous_block   CONSTANT VARCHAR2 (50) := '__anonymous_block';

   /* Return the program unit and line number
      where the error was first raised. */

   FUNCTION backtrace_to
      RETURN VARCHAR2;

   FUNCTION backtrace_to_line
      RETURN PLS_INTEGER;

   FUNCTION call_stack_string (
      include_anon_block_in   IN BOOLEAN DEFAULT FALSE,
      use_line_breaks_in      IN BOOLEAN DEFAULT FALSE,
      trace_pkg_in            IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

   PROCEDURE show_summary;

   PROCEDURE show_call_stack_at (depth_in IN PLS_INTEGER DEFAULT 1);

   PROCEDURE show_call_stack;

   PROCEDURE show_error_stack_at (depth_in IN PLS_INTEGER DEFAULT 1);

   PROCEDURE show_error_stack;

   PROCEDURE show_backtrace_at (depth_in IN PLS_INTEGER DEFAULT 1);

   PROCEDURE show_backtrace;
END;
/

CREATE OR REPLACE PACKAGE BODY utl_call_stack_helper
IS
   FUNCTION backtrace_to
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN    utl_call_stack.backtrace_unit (utl_call_stack.error_depth)
             || ' line '
             || utl_call_stack.backtrace_line (utl_call_stack.error_depth);
   END;

   FUNCTION backtrace_to_line
      RETURN PLS_INTEGER
   IS
   BEGIN
      RETURN utl_call_stack.backtrace_line (utl_call_stack.error_depth);
   END;

   FUNCTION call_stack_string (
      include_anon_block_in   IN BOOLEAN DEFAULT FALSE,
      use_line_breaks_in      IN BOOLEAN DEFAULT FALSE,
      trace_pkg_in            IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      l_subprogram       VARCHAR2 (32767);
      l_add_subprogram   BOOLEAN;
      l_return           VARCHAR2 (32767);
   BEGIN
      /* 1 is always this function, so ignore it. */
      FOR indx IN REVERSE 2 .. utl_call_stack.dynamic_depth
      LOOP
         l_subprogram :=
            utl_call_stack.concatenate_subprogram (
               utl_call_stack.subprogram (indx));
         l_add_subprogram :=
            NOT (    l_return IS NULL
                 AND NOT include_anon_block_in
                 AND l_subprogram = c_anonymous_block);

         IF l_add_subprogram AND trace_pkg_in IS NOT NULL
         THEN
            l_add_subprogram :=
               INSTR (UPPER (l_subprogram), UPPER (trace_pkg_in) || '.') = 0;
         END IF;

         IF l_add_subprogram
         THEN
            l_return :=
                  l_return
               || CASE WHEN use_line_breaks_in THEN CHR (10) END
               || CASE WHEN l_return IS NOT NULL THEN ' -> ' END
               || l_subprogram
               || ' ('
               || TO_CHAR (utl_call_stack.unit_line (indx))
               || ')';
         END IF;
      END LOOP;

      RETURN l_return;
   END;

   PROCEDURE show_summary
   IS
   BEGIN
      DBMS_OUTPUT.put_line ('UTL_CALL_STACK Summary ');

      DBMS_OUTPUT.put_line (
         '> dynamic_depth ' || utl_call_stack.dynamic_depth);
      DBMS_OUTPUT.put_line ('> error_depth ' || utl_call_stack.error_depth);
      DBMS_OUTPUT.put_line (
         '> backtrace_depth ' || utl_call_stack.backtrace_depth);
      DBMS_OUTPUT.put_line ('> DBMS_UTILITY.FORMAT_CALL_STACK: ');
      DBMS_OUTPUT.put_line (DBMS_UTILITY.format_call_stack);

      IF SQLCODE <> 0
      THEN
         DBMS_OUTPUT.put_line ('> DBMS_UTILITY.FORMAT_ERROR_STACK: ');
         DBMS_OUTPUT.put_line (DBMS_UTILITY.format_error_stack);
         DBMS_OUTPUT.put_line ('> DBMS_UTILITY.FORMAT_ERROR_BACKTRACE: ');
         DBMS_OUTPUT.put_line (DBMS_UTILITY.format_error_backtrace);
      END IF;
   END;

   PROCEDURE show_call_stack_at (depth_in IN PLS_INTEGER DEFAULT 1)
   IS
      l_names   utl_call_stack.unit_qualified_name;
      l_name    VARCHAR2 (32767);
   BEGIN
      DBMS_OUTPUT.put_line ('Call Stack at Depth ' || depth_in);
      DBMS_OUTPUT.put_line ('> owner ' || utl_call_stack.owner (depth_in));

      DBMS_OUTPUT.put_line (
            '> concatenate_subprogram '
         || utl_call_stack.concatenate_subprogram (
               utl_call_stack.subprogram (depth_in)));

      DBMS_OUTPUT.put_line (
         '> lexical_depth ' || utl_call_stack.lexical_depth (depth_in));
      DBMS_OUTPUT.put_line (
         '> unit_line ' || utl_call_stack.unit_line (depth_in));
      DBMS_OUTPUT.put_line (
         '> current_edition ' || utl_call_stack.current_edition (depth_in));
   END;

   PROCEDURE show_call_stack
   IS
   BEGIN
      FOR indx IN 1 .. utl_call_stack.dynamic_depth
      LOOP
         show_call_stack_at (indx);
      END LOOP;
   END;

   PROCEDURE show_error_stack_at (depth_in IN PLS_INTEGER DEFAULT 1)
   IS
   BEGIN
      DBMS_OUTPUT.put_line ('Error Stack at Depth ' || depth_in);
      DBMS_OUTPUT.put_line (
         '> error_number ' || utl_call_stack.error_number (depth_in));
      DBMS_OUTPUT.put_line (
         '> error_msg ' || utl_call_stack.error_msg (depth_in));
   END;

   PROCEDURE show_error_stack
   IS
   BEGIN
      DBMS_OUTPUT.put_line ('DBMS_UTILITY.FORMAT_ERROR_STACK: ');
      DBMS_OUTPUT.put_line (DBMS_UTILITY.format_error_stack);

      FOR indx IN 1 .. utl_call_stack.error_depth
      LOOP
         show_error_stack_at (indx);
      END LOOP;
   END;

   PROCEDURE show_backtrace_at (depth_in IN PLS_INTEGER DEFAULT 1)
   IS
   BEGIN
      DBMS_OUTPUT.put_line ('Error Backtrace at Depth ' || depth_in);
      DBMS_OUTPUT.put_line (
         '> backtrace_unit ' || utl_call_stack.backtrace_unit (depth_in));
      DBMS_OUTPUT.put_line (
         '> backtrace_line ' || utl_call_stack.backtrace_line (depth_in));
   END;

   PROCEDURE show_backtrace
   IS
   BEGIN
      DBMS_OUTPUT.put_line ('DBMS_UTILITY.FORMAT_ERROR_BACKTRACE: ');
      DBMS_OUTPUT.put_line (DBMS_UTILITY.format_error_backtrace);

      FOR indx IN 1 .. utl_call_stack.backtrace_depth
      LOOP
         show_backtrace_at (indx);
      END LOOP;
   END;
END;
/

SHO ERR