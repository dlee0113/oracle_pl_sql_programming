CREATE OR REPLACE PACKAGE BODY sf_out
IS
/*----------------------------------------------------------------
||                  PL/Vision Professional
||----------------------------------------------------------------
||    File: p.spb
||  Author: Steven Feuerstein
||
||
|| Copyright (C) 1996-2002 Quest Software
|| All rights reserved.
||
-----------------------------------------------------------------*/
   c_max_dopl_line    INTEGER  := 255;
   c_delim   CONSTANT CHAR (3) := ' - ';
   g_showtime         BOOLEAN  := FALSE;
   g_lasttime         INTEGER  := NULL;
   v_linelen          INTEGER  := c_linelen;

   /*------------------- Private Modules -------------------*/
   PROCEDURE put_line (stg_in IN VARCHAR2)
   IS
   BEGIN
      DBMS_OUTPUT.put_line (stg_in);
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.ENABLE (1000000);
         DBMS_OUTPUT.put_line (v_prefix || stg_in);
   END;

   PROCEDURE display_line (line_in IN VARCHAR2)
   IS
   BEGIN
      IF RTRIM (line_in) IS NULL
      THEN
         DBMS_OUTPUT.put_line ('');
      ELSIF LENGTH (line_in) > linelen
      THEN
         DBMS_OUTPUT.put_line (SUBSTR (line_in, 1, linelen));
         display_line (SUBSTR (line_in, linelen + 1));
      ELSE
         DBMS_OUTPUT.put_line (line_in);
      END IF;
   END;

   /* Set line length before wrap */
   PROCEDURE set_linelen (len IN INTEGER := c_linelen)
   IS
   BEGIN
      v_linelen :=
                  LEAST (c_max_dopl_line, GREATEST (NVL (len, c_linelen), 1));
   END;

   FUNCTION linelen
      RETURN INTEGER
   IS
   BEGIN
      RETURN v_linelen;
   END;

   /*------------------ The p.l Procedures ----------------*/
   FUNCTION date_string (dt IN DATE, MASK IN VARCHAR2 := NULL)
      RETURN VARCHAR2
   IS
   BEGIN
      IF MASK IS NOT NULL
      THEN
         RETURN TO_CHAR (dt, MASK);
      ELSE
         RETURN TO_CHAR (dt);
      END IF;
   END;

   FUNCTION bool_string (val IN BOOLEAN)
      RETURN VARCHAR2
   IS
   BEGIN
      IF val
      THEN
         RETURN 'TRUE';
      ELSIF NOT val
      THEN
         RETURN 'FALSE';
      ELSE
         RETURN 'NULL';
      END IF;
   END;

   PROCEDURE l (dt IN DATE, mask_in IN VARCHAR2 := NULL)
   IS
   BEGIN
      display_line (date_string (dt, mask_in));
   END;

   PROCEDURE l (num IN NUMBER)
   IS
   BEGIN
      display_line (TO_CHAR (num));
   END;

   PROCEDURE l (stg IN VARCHAR2)
   IS
   BEGIN
      display_line (stg);
   END;

   PROCEDURE l (stg IN VARCHAR2, num IN NUMBER)
   IS
   BEGIN
      display_line (stg || c_delim || TO_CHAR (num));
   END;

   PROCEDURE l (stg IN VARCHAR2, dt IN DATE, mask_in IN VARCHAR2 := NULL)
   IS
   BEGIN
      display_line (stg || c_delim || date_string (dt, mask_in));
   END;

   PROCEDURE l (bool IN BOOLEAN)
   IS
   BEGIN
      display_line (bool_string (bool));
   END;

   PROCEDURE l (stg IN VARCHAR2, bool IN BOOLEAN)
   IS
   BEGIN
      display_line (stg || c_delim || bool_string (bool));
   END;

   PROCEDURE l (file_in IN UTL_FILE.file_type)
   IS
   BEGIN
      display_line (TO_CHAR (file_in.ID));
   END;

   PROCEDURE l (string_in IN VARCHAR2, file_in IN UTL_FILE.file_type)
   IS
   BEGIN
      l (string_in, file_in.ID, show_in);
   END;

   /* Additional overloadings */
   PROCEDURE l (num1 IN NUMBER, num2 IN NUMBER)
   IS
   BEGIN
      display_line (TO_CHAR (num1) || c_delim || TO_CHAR (num2));
   END;

   PROCEDURE l (str IN VARCHAR2, num1 IN NUMBER, num2 IN NUMBER)
   IS
   BEGIN
      display_line (str || c_delim || TO_CHAR (num1) || c_delim
                    || TO_CHAR (num2)
                   );
   END;

   PROCEDURE l (bool1 IN BOOLEAN, bool2 IN BOOLEAN)
   IS
   BEGIN
      display_line (bool_string (bool1) || c_delim || bool_string (bool2));
   END;

   PROCEDURE l (stg1 IN VARCHAR2, stg2 IN VARCHAR2)
   IS
   BEGIN
      display_line (stg1 || c_delim || stg2);
   END;

   PROCEDURE l (dt1 IN DATE, dt2 IN DATE, mask_in IN VARCHAR2 := NULL)
   IS
   BEGIN
      display_line (show_in
                  ,    date_string (dt1, mask_in)
                    || c_delim
                    || date_string (dt2, mask_in)
                   );
   END;

   PROCEDURE l (num IN NUMBER, dt IN DATE, mask_in IN VARCHAR2 := NULL)
   IS
   BEGIN
      display_line (TO_CHAR (num) || c_delim || date_string (dt, mask_in));
   END;

   PROCEDURE l (bool IN BOOLEAN, num IN NUMBER)
   IS
   BEGIN
      display_line (bool_string (bool) || c_delim || TO_CHAR (num));
   END;

   PROCEDURE l (bool IN BOOLEAN, dt IN DATE, mask_in IN VARCHAR2 := NULL)
   IS
   BEGIN
      display_line (bool_string (bool) || c_delim
                    || date_string (dt, mask_in));
   END;

   PROCEDURE l (bool IN BOOLEAN, stg IN VARCHAR2)
   IS
   BEGIN
      display_line (stg || c_delim || bool_string (bool));
   END;

   /* Show time stamp toggle. Default is NOSHOW. */
   PROCEDURE showtime
   IS
   BEGIN
      g_showtime := TRUE;
      g_lasttime := NULL;
   END;

   PROCEDURE noshowtime
   IS
   BEGIN
      g_showtime := TRUE;
      g_lasttime := NULL;
   END;

   FUNCTION showing_time
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN g_showtime;
   END;
END sf_out;
/