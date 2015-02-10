CREATE OR REPLACE PACKAGE BODY sf_loop_killer
IS
   g_counter          PLS_INTEGER;
   g_max_iterations   PLS_INTEGER DEFAULT c_max_iterations;

   PROCEDURE kill_after (max_iterations_in IN PLS_INTEGER)
   IS
   BEGIN
      g_counter := 1;
      g_max_iterations :=
                      NVL (GREATEST (1, max_iterations_in), c_max_iterations);
   END kill_after;

   PROCEDURE increment_or_kill (by_in IN PLS_INTEGER DEFAULT 1)
   IS
      c_message   CONSTANT VARCHAR2 (32767)
               := 'Your loop exceeded ' || g_max_iterations || ' iterations.';
   BEGIN
      g_counter := g_counter + by_in;

      IF g_max_iterations <= g_counter
      THEN
         /*
         Dual notification: through DBMS_OUTPUT and by raising
         an exception.
         */
         DBMS_OUTPUT.put_line ('Loop killer failure: ' || c_message);
         DBMS_OUTPUT.put_line ('Call stack below shows location of problem:');
         DBMS_OUTPUT.put_line (DBMS_UTILITY.format_call_stack);
         raise_application_error (c_infinite_loop_detected
                                ,    c_message
                                  || ' Check system output for the call stack.'
                                 );
      END IF;
   END increment_or_kill;

   FUNCTION current_count
      RETURN PLS_INTEGER
   IS
   BEGIN
      RETURN g_counter;
   END current_count;
END sf_loop_killer;
/