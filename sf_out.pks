CREATE OR REPLACE PACKAGE sf_out
/*----------------------------------------------------------------
||                  PL/Vision Professional
||----------------------------------------------------------------
||    File: p.sps
||  Author: Steven Feuerstein
||
||
|| Copyright (C) 1996-2002 Quest Software
|| All rights reserved.
||
-----------------------------------------------------------------*/
IS
   c_linelen   CONSTANT INTEGER  := 80;

   /* Set line length before wrap */
   PROCEDURE set_linelen (len IN INTEGER := c_linelen);

   FUNCTION linelen
      RETURN INTEGER;

/* The overloaded versions of the put-line procedure */

   /* Display a date. Can specify a format mask or use the default. */
   PROCEDURE pl (dt IN DATE, mask_in IN VARCHAR2 := NULL);

   /* Display a number. */
   PROCEDURE pl (num IN NUMBER);

   /* Display a string. */
   PROCEDURE pl (stg IN VARCHAR2);

   /* Display a string followed by a number. */
   PROCEDURE pl (stg IN VARCHAR2, num IN NUMBER);

   /* Display a string followed by a date. */
   PROCEDURE pl (stg IN VARCHAR2, dt IN DATE, mask_in IN VARCHAR2 := NULL);

   /* Display a Boolean value. */
   PROCEDURE pl (bool IN BOOLEAN);

   /* Display a string and then a Boolean value. */
   PROCEDURE pl (stg IN VARCHAR2, bool IN BOOLEAN, show_in IN BOOLEAN
            := FALSE);

   PROCEDURE pl (file_in IN UTL_FILE.file_type);

   PROCEDURE pl (
      string_in   IN   VARCHAR2
    , file_in     IN   UTL_FILE.file_type
    , show_in     IN   BOOLEAN := FALSE
   );

   /* Additional overloadings */
   PROCEDURE pl (num1 IN NUMBER, num2 IN NUMBER);

   PROCEDURE pl (str IN VARCHAR2, num1 IN NUMBER, num2 IN NUMBER);

   PROCEDURE pl (bool1 IN BOOLEAN, bool2 IN BOOLEAN);

   PROCEDURE pl (stg1 IN VARCHAR2, stg2 IN VARCHAR2);

   PROCEDURE pl (dt1 IN DATE, dt2 IN DATE, mask_in IN VARCHAR2 := NULL);

   PROCEDURE pl (num IN NUMBER, dt IN DATE, mask_in IN VARCHAR2 := NULL);

   PROCEDURE pl (bool IN BOOLEAN, num IN NUMBER);

   PROCEDURE pl (bool IN BOOLEAN, dt IN DATE, mask_in IN VARCHAR2 := NULL);

   PROCEDURE pl (bool IN BOOLEAN, stg IN VARCHAR2, show_in IN BOOLEAN
            := FALSE);
END sf_out;
/

REM SHOW ERRors