CREATE OR REPLACE PROCEDURE perfect_triangles (p_max IN INTEGER)
IS
   t1             INTEGER;
   t2             INTEGER;
   LONG           INTEGER;
   short          INTEGER;
   hyp            NUMBER;
   ihyp           INTEGER;

   TYPE side_r IS RECORD (
      short                         INTEGER,
      LONG                          INTEGER);

   TYPE sides_t IS TABLE OF side_r
      INDEX BY BINARY_INTEGER;

   unique_sides   sides_t;
   n      INTEGER := 0 /* curr max elements in unique_sides */;
   dup_sides      sides_t;
   m      INTEGER := 0 /* curr max elements in dup_sides */;

   PROCEDURE store_dup_sides (p_long IN INTEGER, p_short IN INTEGER)
   IS
      mult         INTEGER := 2;
      long_mult    INTEGER :=  p_long * 2;
      short_mult   INTEGER :=  p_short * 2;
   BEGIN
      WHILE (long_mult < p_max)
         OR (short_mult < p_max)
      LOOP
         n :=   n
              + 1;
         dup_sides (n).LONG := long_mult;
         dup_sides (n).short := short_mult;
         mult :=   mult
                 + 1;
         long_mult := p_long * mult;
         short_mult := p_short * mult;
      END LOOP;
   END store_dup_sides;

   FUNCTION sides_are_unique (p_long IN INTEGER, p_short IN INTEGER)
      RETURN BOOLEAN
   IS
   BEGIN
      FOR j IN 1 .. n
      LOOP
         IF      (p_long = dup_sides (j).LONG)
             AND (p_short = dup_sides (j).short)
         THEN
            RETURN FALSE;
         END IF;
      END LOOP;

      RETURN TRUE;
   END sides_are_unique;
BEGIN                            /* Perfect_Triangles */
   t1 := DBMS_UTILITY.get_time;

   FOR LONG IN 1 .. p_max
   LOOP
      FOR short IN 1 .. LONG
      LOOP
         hyp := SQRT (  LONG * LONG
                      + short * short);
         ihyp := FLOOR (hyp);

         IF   hyp
            - ihyp < 0.01
         THEN
            IF (ihyp * ihyp =
                        LONG * LONG
                      + short * short
               )
            THEN
               IF sides_are_unique (LONG, short)
               THEN
                  m :=   m
                       + 1;
                  unique_sides (m).LONG := LONG;
                  unique_sides (m).short := short;
                  store_dup_sides (LONG, short);
               END IF;
            END IF;
         END IF;
      END LOOP;
   END LOOP;

   t2 := DBMS_UTILITY.get_time;
   DBMS_OUTPUT.put_line (
         CHR (10)
      || TO_CHAR (((  t2
                    - t1
                   ) / 100
                  ), '9999.9')
      || ' sec'
   );
END perfect_triangles;
/
