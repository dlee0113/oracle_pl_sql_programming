CREATE OR REPLACE PACKAGE p
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
   c_prefix CONSTANT CHAR(1) := CHR(8);
   c_linelen CONSTANT INTEGER := 80;

   /* Toggles output from p.l */
   PROCEDURE turn_on;
   PROCEDURE turn_off;

   /* Specification of Set/Get for "linesep" */
   PROCEDURE set_linesep (linesep_in IN VARCHAR2);
   FUNCTION linesep RETURN VARCHAR2;

   /* Specification of Set/Get for "prefix" */
   PROCEDURE set_prefix (prefix_in IN VARCHAR2 := c_prefix);
   FUNCTION prefix RETURN VARCHAR2;

   /* Set line length before wrap */
   PROCEDURE set_linelen (len IN INTEGER := c_linelen);
   FUNCTION linelen RETURN INTEGER;

/* The overloaded versions of the p.l procedure */

   /* Display a date. Can specify a format mask or use the default. */
   PROCEDURE l 
      (dt IN DATE, 
       mask_in IN VARCHAR2 := NULL,
       show_in IN BOOLEAN := FALSE); 

   /* Display a number. */
   PROCEDURE l (num IN NUMBER, show_in IN BOOLEAN := FALSE);

   /* Display a string. */
   PROCEDURE l (stg IN VARCHAR2, show_in IN BOOLEAN := FALSE);

   /* Display a string followed by a number. */
   PROCEDURE l 
      (stg IN VARCHAR2, num IN NUMBER, 
       show_in IN BOOLEAN := FALSE);

   /* Display a string followed by a date. */
   PROCEDURE l 
      (stg IN VARCHAR2, dt IN DATE,
       mask_in IN VARCHAR2 := NULL,
       show_in IN BOOLEAN := FALSE);

   /* Display a Boolean value. */
   PROCEDURE l (bool IN BOOLEAN, show_in IN BOOLEAN := FALSE);

   /* Display a string and then a Boolean value. */   
   PROCEDURE l 
      (stg IN VARCHAR2, bool IN BOOLEAN, 
       show_in IN BOOLEAN := FALSE);

   PROCEDURE l 
     (file_in IN UTL_FILE.FILE_TYPE, 
      show_in IN BOOLEAN := FALSE);

   PROCEDURE l 
     (string_in IN VARCHAR2,
      file_in IN UTL_FILE.FILE_TYPE,
      show_in IN BOOLEAN := FALSE); 

   /* Additional overloadings */
   PROCEDURE l (num1 IN NUMBER, num2 IN NUMBER, show_in IN BOOLEAN := FALSE);
   PROCEDURE l (str IN VARCHAR2,
      num1 IN NUMBER, num2 IN NUMBER, show_in IN BOOLEAN := FALSE); 
   PROCEDURE l (bool1 IN BOOLEAN, bool2 IN BOOLEAN, show_in IN BOOLEAN := FALSE);
   PROCEDURE l (stg1 IN VARCHAR2, stg2 IN VARCHAR2, show_in IN BOOLEAN := FALSE);
   PROCEDURE l (dt1 IN DATE, dt2 IN DATE, 
      mask_in IN VARCHAR2 := NULL, show_in IN BOOLEAN := FALSE);
   PROCEDURE l (num IN NUMBER, dt IN DATE, 
      mask_in IN VARCHAR2 := NULL, show_in IN BOOLEAN := FALSE);
   PROCEDURE l (bool IN BOOLEAN, num IN NUMBER, show_in IN BOOLEAN := FALSE);
   PROCEDURE l (bool IN BOOLEAN, dt IN DATE,  
      mask_in IN VARCHAR2 := NULL, show_in IN BOOLEAN := FALSE);
   PROCEDURE l (bool IN BOOLEAN, stg IN VARCHAR2, show_in IN BOOLEAN := FALSE);

   PROCEDURE help (topic_in IN VARCHAR2 := NULL);
END p;
/
REM SHOW ERRors
