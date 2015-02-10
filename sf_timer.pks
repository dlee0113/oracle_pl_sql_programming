CREATE OR REPLACE PACKAGE sf_timer
/*----------------------------------------------------------------
||                  PL/Vision Professional
||----------------------------------------------------------------
||    File: sf_timer.pkg
||  Author: Steven Feuerstein
||
|| This is a part of the PL/Vision Professional Code library.
|| Copyright (C) 1996-1999 RevealNet, Inc.
|| All rights reserved.
||
|| For more information, call RevealNet at 1-800-REVEAL4
|| or check out our Web page: www.revealnet.com
||
|| This file is an abbreviated version of sf_timer designed
|| to be used with the scripts on this disk.
||
******************************************************************/
IS
   /* Specification of Set/Get for "factor" */
   PROCEDURE set_factor (factor_in IN NUMBER);

   FUNCTION factor
      RETURN NUMBER;

   /* Capture current value in DBMS_UTILITY.GET_TIME */
   PROCEDURE start_timer (context_in IN VARCHAR2 := NULL);

   /* Return amount of time elapsed since call to capture */
   FUNCTION elapsed_time
      RETURN NUMBER;

   /* Construct message showing time elapsed since call to capture */
   FUNCTION elapsed_message (
      prefix_in          IN   VARCHAR2 := NULL
    , adjust_in          IN   NUMBER := 0
    , reset_in           IN   BOOLEAN := TRUE
    , reset_context_in   IN   VARCHAR2 := NULL
   )
      RETURN VARCHAR2;

   /* Display message of elapsed time */
   PROCEDURE show_elapsed_time (
      prefix_in   IN   VARCHAR2 := NULL
    , adjust_in   IN   NUMBER := 0
    , reset_in    IN   BOOLEAN := TRUE
   );
END sf_timer;
/

