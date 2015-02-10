/* File on web: binary_performance.sql */

DECLARE
   bd             BINARY_DOUBLE;
   bd_area        BINARY_DOUBLE;
   bd_sine        BINARY_DOUBLE;
   nm             NUMBER;
   nm_area        NUMBER;
   nm_sine        NUMBER;
   pi_bd          BINARY_DOUBLE := 3.1415926536d;
   pi_nm          NUMBER := 3.1415926536;
   bd_begin       TIMESTAMP (9);
   bd_end         TIMESTAMP (9);
   bd_wall_time   INTERVAL DAY TO SECOND (9);
   nm_begin       TIMESTAMP (9);
   nm_end         TIMESTAMP (9);
   nm_wall_time   INTERVAL DAY TO SECOND (9);
BEGIN
   --Compute area 5,000,000 times using binary doubles
   bd_begin := SYSTIMESTAMP;
   bd := 1d;

   LOOP
      bd_area := bd * bd * pi_bd;
      bd := bd + 1d;
      EXIT WHEN bd > 5000000;
   END LOOP;

   bd_end := SYSTIMESTAMP;

   --Compute area 5,000,000 times using NUMBERs
   nm_begin := SYSTIMESTAMP;
   nm := 1;

   LOOP
      nm_area := nm * nm * 2 * pi_nm;
      nm := nm + 1;
      EXIT WHEN nm > 5000000;
   END LOOP;

   nm_end := SYSTIMESTAMP;

   --Compute and display elapsed, wall-clock time
   bd_wall_time := bd_end - bd_begin;
   nm_wall_time := nm_end - nm_begin;
   DBMS_OUTPUT.put_line ('BINARY_DOUBLE area = ' || bd_wall_time);
   DBMS_OUTPUT.put_line ('NUMBER area = ' || nm_wall_time);

   --Compute sine 5,000,000 times using binary doubles
   bd_begin := SYSTIMESTAMP;
   bd := 1d;

   LOOP
      bd_sine := SIN (bd);
      bd := bd + 1d;
      EXIT WHEN bd > 5000000;
   END LOOP;

   bd_end := SYSTIMESTAMP;

   --Compute sine 5,000,000 times using NUMBERs
   nm_begin := SYSTIMESTAMP;
   nm := 1;

   LOOP
      nm_sine := SIN (nm);
      nm := nm + 1;
      EXIT WHEN nm > 5000000;
   END LOOP;

   nm_end := SYSTIMESTAMP;

   --Compute and display elapsed, wall-clock time for sine
   bd_wall_time := bd_end - bd_begin;
   nm_wall_time := nm_end - nm_begin;
   DBMS_OUTPUT.put_line ('BINARY_DOUBLE sine = ' || bd_wall_time);
   DBMS_OUTPUT.put_line ('NUMBER sine = ' || nm_wall_time);
END;