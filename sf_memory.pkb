CREATE OR REPLACE PACKAGE BODY sf_memory
IS
   g_uga_start   PLS_INTEGER;
   g_pga_start   PLS_INTEGER;

   FUNCTION statval (statname_in IN VARCHAR2)
      RETURN NUMBER
   IS
      l_memory   PLS_INTEGER;
   BEGIN
      SELECT s.VALUE
        INTO l_memory
        FROM SYS.v_$sesstat s, SYS.v_$statname n
       WHERE s.statistic# = n.statistic#
         AND s.SID = my_session.SID
         AND n.NAME = statname_in;

      RETURN l_memory;
   END statval;

   PROCEDURE reset_analysis
   IS
   BEGIN
      g_uga_start := NULL;
      g_pga_start := NULL;
   END reset_analysis;

   PROCEDURE get_memory_data (uga_out OUT PLS_INTEGER, pga_out OUT PLS_INTEGER)
   IS
   BEGIN
      uga_out := statval ('session uga memory');
      pga_out := statval ('session pga memory');
   END get_memory_data;

   PROCEDURE start_analysis
   IS
   BEGIN
      get_memory_data (g_uga_start, g_pga_start);
   END start_analysis;

   PROCEDURE show_memory_usage
   IS
      l_uga_usage   PLS_INTEGER;
      l_pga_usage   PLS_INTEGER;
   BEGIN
      get_memory_data (l_uga_usage, l_pga_usage);

      IF g_uga_start IS NULL
      THEN
         DBMS_OUTPUT.put_line ('   UGA memory: ' || l_uga_usage);
      ELSE
         DBMS_OUTPUT.put_line (   '   Change in UGA memory: '
                               || TO_CHAR (l_uga_usage - g_uga_start)
                               || ' (Current = '
                               || TO_CHAR (l_uga_usage)
                               || ')'
                              );
      END IF;

      IF g_pga_start IS NULL
      THEN
         DBMS_OUTPUT.put_line ('   PGA memory: ' || l_pga_usage);
      ELSE
         DBMS_OUTPUT.put_line (   '   Change in PGA memory: '
                               || TO_CHAR (l_pga_usage - g_pga_start)
                               || ' (Current = '
                               || TO_CHAR (l_pga_usage)
                               || ')'
                              );
      END IF;
   END show_memory_usage;
END sf_memory;
/