CREATE OR REPLACE FUNCTION betwnstr (string_in   IN VARCHAR2,
                                     start_in    IN INTEGER,
                                     end_in      IN INTEGER)
   RETURN VARCHAR2
IS
BEGIN
   /* Check to see if trace is turned on before calling
      the trace procedure, to minimize runtime overhead
      when tracing is disabled. */
      
   IF opp_trace_pkg.trace_is_on
   THEN
      opp_trace_pkg.trace_activity ('betwnstr string', string_in);
   END IF;

   opp_trace_pkg.trace_activity_force ('betwnstr start-end',
                                       start_in || '-' || end_in);

   RETURN (SUBSTR (string_in, start_in, end_in - start_in + 1));
END betwnstr;
/

BEGIN
   opp_trace_pkg.turn_on_trace;
   opp_trace_pkg.put_line (betwnstr ('abcdefg', 3, 5));
   opp_trace_pkg.turn_on_trace (context_filter_in => 'xyz');
   opp_trace_pkg.put_line (betwnstr ('abcdefg', 3, 5));
   opp_trace_pkg.turn_off_trace;
END;
/

  SELECT context || '-' || text
    FROM opp_trace
ORDER BY created_on
/

DELETE FROM opp_trace
/

COMMIT
/

/* Now write to screen */

BEGIN
   opp_trace_pkg.turn_on_trace (
      context_filter_in   => 'betwnstr',
      send_trace_to_in    => opp_trace_pkg.c_to_screen);
   opp_trace_pkg.put_line (betwnstr ('abcdefg', 3, 5));
   opp_trace_pkg.turn_off_trace;
END;
/

/* Demonstrate replacement for dbms_output.put_line */

BEGIN
   opp_trace_pkg.put_line ('abc');
   opp_trace_pkg.put_line (SYSDATE);
   opp_trace_pkg.put_line (TRUE);
END;
/