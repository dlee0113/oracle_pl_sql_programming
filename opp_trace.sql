CREATE TABLE opp_trace_settings
(
   trace_on           VARCHAR2 (1),
   context_filter     VARCHAR2 (4000),
   trace_target       VARCHAR2 (1),
   callstack_filter   VARCHAR2 (4000)
)
/

CREATE TABLE opp_trace
(
   trace_id     INTEGER,
   context      VARCHAR2 (4000),
   text         CLOB,
   callstack    CLOB,
   created_on   DATE,
   created_by   VARCHAR2 (100)
)
/

CREATE SEQUENCE opp_trace_seq
/

CREATE OR REPLACE PACKAGE opp_trace_pkg
   AUTHID DEFINER
IS
   SUBTYPE maxvarchar2 IS VARCHAR2 (32767);

   TYPE maxvarchar2_aat IS TABLE OF VARCHAR2 (32767)
      INDEX BY PLS_INTEGER;

   c_date_mask   CONSTANT VARCHAR2 (30) := 'YYYY-MM-DD HH24:MI:SS';

   /* Where does the trace go? Table is default. */
   c_to_screen   CONSTANT CHAR (1) := 'S';
   c_to_table    CONSTANT CHAR (1) := 'T';

   PROCEDURE clear_trace_entries (before_in IN DATE DEFAULT NULL);

   PROCEDURE turn_on_trace (
      context_filter_in       IN VARCHAR2 DEFAULT NULL,
      callstack_contains_in   IN VARCHAR2 DEFAULT NULL,
      send_trace_to_in        IN VARCHAR2 DEFAULT c_to_table);

   PROCEDURE turn_off_trace;

   FUNCTION trace_is_on (context_filter_in IN VARCHAR2 DEFAULT NULL)
      RETURN BOOLEAN;

   PROCEDURE trace_activity (context_in   IN VARCHAR2,
                             data_in      IN VARCHAR2);

   PROCEDURE trace_activity (context_in IN VARCHAR2, data_in IN CLOB);

   PROCEDURE trace_activity (context_in   IN VARCHAR2,
                             data_in      IN BOOLEAN);

   /* Use this inside expressions and SQL. Always returns 1.*/
   FUNCTION trace_activity (context_in   IN VARCHAR2,
                            data_in      IN VARCHAR2)
      RETURN PLS_INTEGER;

   /* "Force" trace - even if disabled, will write to log */

   PROCEDURE trace_activity_force (context_in   IN VARCHAR2,
                                   data_in      IN VARCHAR2);

   PROCEDURE trace_activity_force (context_in   IN VARCHAR2,
                                   data_in      IN CLOB);

   PROCEDURE trace_activity_force (context_in   IN VARCHAR2,
                                   data_in      IN BOOLEAN);

   return                 PLS_INTEGER;

   /* Always returns 1 */
   FUNCTION trace_activity_force (context_in   IN VARCHAR2,
                                  data_in      IN VARCHAR2)
      RETURN PLS_INTEGER;

   /* Substitutes for DBMS_OUTPUT.PUT_LINE */

   FUNCTION bool2vc (bool IN BOOLEAN)
      RETURN VARCHAR2;

   PROCEDURE put_line (data_in IN VARCHAR2);

   PROCEDURE put_line (data_in IN BOOLEAN);

   PROCEDURE put_line (data_in     IN DATE,
                       format_in   IN VARCHAR2 DEFAULT c_date_mask);

   PROCEDURE put_line (clob_in            IN CLOB,
                       append_in          IN BOOLEAN DEFAULT TRUE,
                       preserve_code_in   IN BOOLEAN DEFAULT FALSE);
END opp_trace_pkg;
/

CREATE OR REPLACE PACKAGE BODY opp_trace_pkg
IS
   FUNCTION bool2vc (bool IN BOOLEAN)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN CASE
                WHEN bool THEN 'TRUE'
                WHEN NOT bool THEN 'FALSE'
                ELSE 'NULL'
             END;
   END;

   PROCEDURE turn_on_trace (
      context_filter_in       IN VARCHAR2 DEFAULT NULL,
      callstack_contains_in   IN VARCHAR2 DEFAULT NULL,
      send_trace_to_in        IN VARCHAR2 DEFAULT c_to_table)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      UPDATE opp_trace_settings
         SET trace_on = 'Y',
             context_filter =
                CASE
                   WHEN context_filter_in IS NULL THEN '%'
                   ELSE '%' || UPPER (context_filter_in) || '%'
                END,
             callstack_filter = UPPER (callstack_contains_in),
             trace_target = send_trace_to_in;

      COMMIT;
   END;

   PROCEDURE turn_off_trace
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      UPDATE opp_trace_settings
         SET trace_on = 'N', context_filter = '%';

      COMMIT;
   END;

   FUNCTION trace_is_on (context_filter_in IN VARCHAR2 DEFAULT NULL)
      RETURN BOOLEAN
   IS
      l_trace_settings   opp_trace_settings%ROWTYPE;
      l_trace            CHAR (1);
      l_filter           VARCHAR2 (100);
      l_return           BOOLEAN DEFAULT FALSE;
   BEGIN
      SELECT * INTO l_trace_settings FROM opp_trace_settings;

      l_return := l_trace_settings.trace_on = 'Y';

      IF l_return AND context_filter_in IS NOT NULL
      THEN
         l_return :=
            UPPER (context_filter_in) LIKE
               l_trace_settings.context_filter;
      END IF;

      RETURN l_return;
   END trace_is_on;

   PROCEDURE internal_trace (context_in    IN VARCHAR2,
                             data_in       IN VARCHAR2,
                             override_in   IN BOOLEAN)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      c_callstack   CONSTANT maxvarchar2
                                := DBMS_UTILITY.format_call_stack ;
      l_trace_settings       opp_trace_settings%ROWTYPE;

      l_trace_it             BOOLEAN
         := override_in OR trace_is_on (context_in);

      c_context     CONSTANT opp_trace.text%TYPE
                                := SUBSTR (context_in, 1, 4000) ;
   BEGIN
      IF l_trace_it
      THEN
         SELECT * INTO l_trace_settings FROM opp_trace_settings;

         IF l_trace_settings.callstack_filter IS NOT NULL
         THEN
            l_trace_it :=
               INSTR (c_callstack, l_trace_settings.callstack_filter) >
                  0;
         END IF;
      END IF;

      IF l_trace_it
      THEN
         CASE l_trace_settings.trace_target
            WHEN c_to_screen
            THEN
               put_line (context_in || ': ' || data_in);
            ELSE
               INSERT INTO opp_trace (trace_id,
                                      context,
                                      text,
                                      callstack)
                    VALUES (opp_trace_seq.NEXTVAL,
                            c_context,
                            data_in,
                            c_callstack);

               COMMIT;
         END CASE;
      END IF;
   END;

   PROCEDURE internal_trace (context_in    IN VARCHAR2,
                             data_in       IN CLOB,
                             override_in   IN BOOLEAN)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      l_trace_settings     opp_trace_settings%ROWTYPE;
      l_trace_it           BOOLEAN
         := override_in OR trace_is_on (context_in);
      c_context   CONSTANT opp_trace.text%TYPE
                              := SUBSTR (context_in, 1, 4000) ;
   BEGIN
      SELECT * INTO l_trace_settings FROM opp_trace_settings;

      IF     NOT l_trace_it
         AND l_trace_settings.callstack_filter IS NOT NULL
      THEN
         l_trace_it :=
            INSTR (DBMS_UTILITY.format_call_stack,
                   l_trace_settings.callstack_filter) > 0;
      END IF;

      IF l_trace_it
      THEN
         CASE l_trace_settings.trace_target
            WHEN c_to_screen
            THEN
               put_line (context_in || ': ' || data_in);
            ELSE
               INSERT INTO opp_trace (context, text, callstack)
                    VALUES (
                              c_context,
                              data_in,
                              DBMS_UTILITY.format_call_stack);

               COMMIT;
         END CASE;
      END IF;
   END;

   PROCEDURE trace_activity (context_in   IN VARCHAR2,
                             data_in      IN VARCHAR2)
   IS
   BEGIN
      internal_trace (context_in, data_in, override_in => FALSE);
   END;

   PROCEDURE trace_activity (context_in IN VARCHAR2, data_in IN CLOB)
   IS
   BEGIN
      internal_trace (context_in, data_in, override_in => FALSE);
   END;

   PROCEDURE trace_activity (context_in   IN VARCHAR2,
                             data_in      IN BOOLEAN)
   IS
   BEGIN
      internal_trace (context_in,
                      bool2vc (data_in),
                      override_in   => FALSE);
   END;

   /* Use this inside expressions and SQL */

   FUNCTION trace_activity (context_in   IN VARCHAR2,
                            data_in      IN VARCHAR2)
      RETURN PLS_INTEGER
   IS
   BEGIN
      trace_activity (context_in, data_in);
      RETURN 1;
   END;

   FUNCTION trace_activity_force (context_in   IN VARCHAR2,
                                  data_in      IN VARCHAR2)
      RETURN PLS_INTEGER
   IS
   BEGIN
      trace_activity_force (context_in, data_in);
      RETURN 1;
   END;

   PROCEDURE trace_activity_force (context_in   IN VARCHAR2,
                                   data_in      IN VARCHAR2)
   IS
   BEGIN
      internal_trace (context_in, data_in, override_in => TRUE);
   END;

   PROCEDURE trace_activity_force (context_in   IN VARCHAR2,
                                   data_in      IN CLOB)
   IS
   BEGIN
      internal_trace (context_in, data_in, override_in => TRUE);
   END;

   PROCEDURE trace_activity_force (context_in   IN VARCHAR2,
                                   data_in      IN BOOLEAN)
   IS
   BEGIN
      internal_trace (context_in,
                      bool2vc (data_in),
                      override_in   => TRUE);
   END;

   PROCEDURE clear_trace_entries (before_in IN DATE DEFAULT NULL)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      DELETE FROM opp_trace
            WHERE created_on <= NVL (before_in, SYSDATE);

      COMMIT;
   END;

   /* End Trace Functionality */

   /* Substitutes for DBMS_OUTPUT.PUT_LINE */

   --   PROCEDURE pl (string_in          IN VARCHAR2,
   --                 show_null_in       IN BOOLEAN DEFAULT TRUE,
   --                 to_log_in          IN BOOLEAN DEFAULT FALSE,
   --                 log_context_in     IN VARCHAR2 DEFAULT NULL,
   --                 to_collection_in   IN BOOLEAN DEFAULT FALSE,
   --                 indent_in          IN INTEGER DEFAULT 0,
   --                 prefix_in          IN VARCHAR2 DEFAULT '|')
   --   IS
   --      FUNCTION padit (str VARCHAR2, indent_in IN INTEGER)
   --         RETURN VARCHAR2
   --      IS
   --      BEGIN
   --         RETURN    CASE
   --                      WHEN prefix_in IS NULL THEN NULL
   --                      ELSE '| '
   --                   END
   --                || LPAD (str, LENGTH (str) + indent_in, ' ');
   --      END;
   --   BEGIN
   --      IF show_null_in OR string_in IS NOT NULL
   --      THEN
   --         IF to_log_in
   --         THEN
   --            trace_activity_force (log_context_in,
   --                                  padit (string_in, indent_in));
   --         ELSIF to_collection_in
   --         THEN
   --            g_output (g_output.COUNT + 1) :=
   --               padit (string_in, indent_in);
   --         ELSE
   --            DBMS_OUTPUT.put_line (padit (string_in, indent_in));
   --         END IF;
   --      END IF;
   --   END;

   PROCEDURE put_line (data_in IN VARCHAR2)
   IS
   BEGIN
      DBMS_OUTPUT.put_line (data_in);
   END;

   PROCEDURE put_line (data_in     IN DATE,
                       format_in   IN VARCHAR2 DEFAULT c_date_mask)
   IS
   BEGIN
      DBMS_OUTPUT.put_line (TO_CHAR (data_in, format_in));
   END;

   PROCEDURE put_line (data_in IN BOOLEAN)
   IS
   BEGIN
      DBMS_OUTPUT.put_line (bool2vc (data_in));
   END;

   PROCEDURE put_line (title_in IN VARCHAR2, data_in IN BOOLEAN)
   IS
   BEGIN
      DBMS_OUTPUT.put_line (title_in || ' - ' || bool2vc (data_in));
   END;

   PROCEDURE put_line (clob_in            IN CLOB,
                       append_in          IN BOOLEAN DEFAULT TRUE,
                       preserve_code_in   IN BOOLEAN DEFAULT FALSE)
   IS
      l_lines   DBMS_SQL.varchar2s;

      PROCEDURE clob_to_code_lines (
         clob_in       IN            CLOB,
         lines_inout   IN OUT NOCOPY DBMS_SQL.varchar2s)
      IS
         c_array_max         CONSTANT PLS_INTEGER DEFAULT 250;
         c_delim_not_found   CONSTANT PLS_INTEGER DEFAULT 99999999;
         c_length            CONSTANT PLS_INTEGER := LENGTH (clob_in);
         l_string                     VARCHAR2 (255);
         l_start                      PLS_INTEGER := 1;
         l_latest_delim               PLS_INTEGER;

         TYPE delims_t IS TABLE OF VARCHAR2 (1);

         l_delims                     delims_t
            := delims_t (' ', ';', CHR (10));

         FUNCTION latest_delim (string_in   IN CLOB,
                                start_in    IN PLS_INTEGER)
            RETURN PLS_INTEGER
         IS
            l_string      VARCHAR2 (32767)
               := SUBSTR (string_in, start_in, c_array_max);
            l_location    PLS_INTEGER := c_delim_not_found;
            l_delim_loc   PLS_INTEGER;
         BEGIN
            /* The string fits within the limits */
            IF LENGTH (l_string) < c_array_max
            THEN
               l_location := 0;
            ELSE
               /* Find the location of the last delimiter that falls before the 255 limit
                                             and use that to break up the string. */
               FOR indx IN 1 .. l_delims.COUNT
               LOOP
                  l_delim_loc :=
                     INSTR (l_string,
                            l_delims (indx),
                            -1,
                            1);

                  IF l_delim_loc > 0
                  THEN
                     l_location := LEAST (l_location, l_delim_loc);
                  END IF;
               END LOOP;

               /* If a location was found, then shift it back into the bigger string. */
               IF l_location > 0
               THEN
                  l_location := l_location + start_in - 1;
               END IF;
            END IF;

            RETURN l_location;
         END latest_delim;
      BEGIN
         IF NOT append_in
         THEN
            lines_inout.delete;
         END IF;

         WHILE (l_start <= c_length)
         LOOP
            IF preserve_code_in
            THEN
               /* Do more complex parsing. */
               l_latest_delim := latest_delim (clob_in, l_start);

               -- l_next_lf := INSTR (string_in, CHR (10), l_start);
               IF l_latest_delim = c_delim_not_found
               THEN
                  /* No delimiter found.*/
                  IF c_length - l_start + 1 > c_array_max
                  THEN
                     raise_application_error (
                        -20000,
                        'Unable to parse a CLOB without delimiters - string block too long.');
                  ELSE
                     l_string :=
                        SUBSTR (clob_in,
                                l_start,
                                c_array_max + l_start - 1);
                     l_start := l_start + c_array_max;
                  END IF;
               ELSIF l_latest_delim > 0
               THEN
                  l_string :=
                     SUBSTR (clob_in,
                             l_start,
                             l_latest_delim - l_start + 1);
                  l_start := l_latest_delim + 1;
               ELSE
                  l_string :=
                     SUBSTR (clob_in,
                             l_start,
                             c_array_max + l_start - 1);
                  l_start := l_start + c_array_max;
               END IF;
            ELSE
               /* Just break up the line at the c_array_max */
               l_string := SUBSTR (clob_in, l_start, c_array_max);
               l_start := l_start + c_array_max;
            END IF;

            lines_inout (lines_inout.COUNT + 1) := l_string;
         END LOOP;
      END clob_to_code_lines;
   BEGIN
      clob_to_code_lines (clob_in, l_lines);

      FOR indx IN 1 .. l_lines.COUNT
      LOOP
         DBMS_OUTPUT.put_line (l_lines (indx));
      END LOOP;
   EXCEPTION
      WHEN NO_DATA_FOUND OR VALUE_ERROR
      THEN
         /* All done! */
         NULL;
   END put_line;

   PROCEDURE initialize
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      l_count   PLS_INTEGER;
   BEGIN
      /* Make sure there is a row */

      SELECT COUNT (*) INTO l_count FROM opp_trace_settings;

      IF l_count = 0
      THEN
         INSERT INTO opp_trace_settings (trace_on,
                                         context_filter,
                                         trace_target,
                                         callstack_filter)
              VALUES ('N',
                      NULL,
                      c_to_table,
                      NULL);

         COMMIT;
      END IF;
   END;
BEGIN
   initialize;
END opp_trace_pkg;
/