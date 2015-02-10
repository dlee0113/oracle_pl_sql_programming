/*
Oracle PL/SQL Programming 5th Edition
www.stevenfeuerstein.com/books

Objection creation and example scripts for Chapter 10

You will find below all non-trivial code snippets from the above chapter
that are NOT contained in their own files (as specified in the chapter),
plus any DDL object creation scripts required to get a clean compile
on the snippets.

Any references to Oracle's standard HR tables (employees, departments,
locations, regions, etc.) will NOT include the DDL creation scripts
in this file. Instead, run the hr_schema_install.sql script and all
those tables and related elements will be defined.
*/

DECLARE
   hire_date     timestamp (0) WITH TIME ZONE;
   todays_date   CONSTANT DATE := SYSDATE;
   pay_date      timestamp DEFAULT TO_TIMESTAMP ('20050204', 'YYYYMMDD');
BEGIN
   NULL;
END;
/

BEGIN
   DBMS_OUTPUT.put_line ('Session Timezone=' || SESSIONTIMEZONE);
   DBMS_OUTPUT.put_line ('Session Timestamp=' || CURRENT_TIMESTAMP);
   DBMS_OUTPUT.put_line ('DB Server Timestamp=' || SYSTIMESTAMP);
   DBMS_OUTPUT.put_line ('DB Timezone=' || DBTIMEZONE);

   EXECUTE IMMEDIATE 'ALTER SESSION SET TIME_ZONE=DBTIMEZONE';

   DBMS_OUTPUT.put_line ('DB Timestamp=' || CURRENT_TIMESTAMP);

   -- Revert session timezone to local setting
   EXECUTE IMMEDIATE 'ALTER SESSION SET TIME_ZONE=LOCAL';
END;
/

DECLARE
   ts1   timestamp;
   ts2   timestamp;
BEGIN
   ts1 := CAST (SYSTIMESTAMP AS timestamp);
   ts2 := SYSDATE;
   DBMS_OUTPUT.put_line (TO_CHAR (ts1, 'DD-MON-YYYY HH:MI:SS AM'));
   DBMS_OUTPUT.put_line (TO_CHAR (ts2, 'DD-MON-YYYY HH:MI:SS AM'));
END;
/

DROP TABLE assemblies
/

CREATE TABLE assemblies
(
   tracking_id   NUMBER NOT NULL
 , start_time    timestamp NOT NULL
 , build_time    INTERVAL DAY TO SECOND
)
/

CREATE OR REPLACE FUNCTION calc_build_time (
   esn IN assemblies.tracking_id%TYPE
)
   RETURN dsinterval_unconstrained
IS
   start_ts   assemblies.start_time%TYPE;
BEGIN
   SELECT start_time
     INTO start_ts
     FROM assemblies
    WHERE tracking_id = esn;

   RETURN LOCALTIMESTAMP - start_ts;
END;
/

DECLARE
   birthdate   DATE;
BEGIN
   birthdate := TO_DATE ('15-Nov-1961', 'dd-mon-yyyy');
END;
/

DECLARE
   dt      DATE;
   ts      timestamp;
   tstz    timestamp WITH TIME ZONE;
   tsltz   timestamp WITH LOCAL TIME ZONE;
BEGIN
   dt := TO_DATE ('12/26/2005', 'mm/dd/yyyy');
   ts := TO_TIMESTAMP ('24-Feb-2002 09.00.00.50 PM');
   tstz :=
      TO_TIMESTAMP_TZ ('06/2/2002 09:00:00.50 PM EST'
                     , 'mm/dd/yyyy hh:mi:ssxff AM TZD'
                      );
   tsltz :=
      TO_TIMESTAMP_TZ ('06/2/2002 09:00:00.50 PM EST'
                     , 'mm/dd/yyyy hh:mi:ssxff AM TZD'
                      );
   DBMS_OUTPUT.put_line (dt);
   DBMS_OUTPUT.put_line (ts);
   DBMS_OUTPUT.put_line (tstz);
   DBMS_OUTPUT.put_line (tsltz);
END;
/

DECLARE
   ts   timestamp WITH TIME ZONE;
BEGIN
   ts := TIMESTAMP '2002-02-19 13:52:00.123456789 -5:00';
   DBMS_OUTPUT.put_line (TO_CHAR (ts, 'YYYY-MM-DD HH:MI:SS.FF6 AM TZH:TZM'));
END;
/

BEGIN
   DBMS_OUTPUT.put_line (
      TO_TIMESTAMP_TZ ('1231200 083015.50 -5:00', 'MMDDYY HHMISS.FF TZH:TZM')
   );

   DBMS_OUTPUT.put_line(TO_TIMESTAMP_TZ ('01-Nov-2009 01:30:00 EST'
                                       , 'dd-Mon-yyyy hh:mi:ss TZR'
                                        ));
   DBMS_OUTPUT.put_line(TO_TIMESTAMP_TZ ('01-Nov-2009 01:30:00.00 EST EDT'
                                       , 'dd-Mon-yyyy hh:mi:ssxff TZR TZD'
                                        ));
   DBMS_OUTPUT.put_line(TO_TIMESTAMP_TZ ('01-Nov-2009 01:30:00.00 EST EST'
                                       , 'dd-Mon-yyyy hh:mi:ssxff TZR TZD'
                                        ));
   DBMS_OUTPUT.put_line (TO_DATE ('1-1-4', 'fxDD-MM-YYYY'));
   DBMS_OUTPUT.put_line (TO_DATE ('7/16/94', 'FXMM/DD/YY'));
   DBMS_OUTPUT.put_line (
      TO_DATE ('JANUARY^1^ the year of 94', 'FXMonth-dd-"WhatIsaynotdo"yy')
   );
   DBMS_OUTPUT.put_line (TO_DATE ('07-1-94', 'FXfmDD-FXMM-FXYYYY'));
END;
/

SELECT TO_CHAR (SYSDATE, 'MM/DD/YYYY') "Current Date"
     , TO_CHAR (TO_DATE ('14-OCT-88', 'DD-MON-RR'), 'YYYY') "Year 88"
     , TO_CHAR (TO_DATE ('14-OCT-18', 'DD-MON-RR'), 'YYYY') "Year 18"
  FROM DUAL
/

SELECT TO_CHAR (SYSDATE, 'MM/DD/YYYY') "Current Date"
     , TO_CHAR (TO_DATE ('10/14/88', 'MM/DD/RR'), 'YYYY') "Year 88"
     , TO_CHAR (TO_DATE ('10/14/18', 'MM/DD/RR'), 'YYYY') "Year 18"
  FROM DUAL
/

DECLARE
   ts1   timestamp WITH TIME ZONE;
   ts2   timestamp WITH TIME ZONE;
   ts3   timestamp WITH TIME ZONE;
BEGIN
   ts1 :=
      TO_TIMESTAMP_TZ ('2002-06-18 13:52:00.123456789 -5:00'
                     , 'YYYY-MM-DD HH24:MI:SS.FF TZH:TZM'
                      );
   ts2 :=
      TO_TIMESTAMP_TZ ('2002-06-18 13:52:00.123456789 US/Eastern'
                     , 'YYYY-MM-DD HH24:MI:SS.FF TZR'
                      );
   ts3 :=
      TO_TIMESTAMP_TZ ('2002-06-18 13:52:00.123456789 US/Eastern EDT'
                     , 'YYYY-MM-DD HH24:MI:SS.FF TZR TZD'
                      );

   DBMS_OUTPUT.put_line (
      TO_CHAR (ts1, 'YYYY-MM-DD HH:MI:SS.FF AM TZH:TZM TZR TZD')
   );
   DBMS_OUTPUT.put_line (
      TO_CHAR (ts2, 'YYYY-MM-DD HH:MI:SS.FF AM TZH:TZM TZR TZD')
   );
   DBMS_OUTPUT.put_line (
      TO_CHAR (ts3, 'YYYY-MM-DD HH:MI:SS.FF AM TZH:TZM TZR TZD')
   );
END;
/

DECLARE
   ts1   timestamp WITH TIME ZONE;
   ts2   timestamp WITH TIME ZONE;
   ts3   timestamp WITH TIME ZONE;
   ts4   timestamp WITH TIME ZONE;
   ts5   DATE;
BEGIN
   --Two digits for fractional seconds
   ts1 := TIMESTAMP '2002-02-19 11:52:00.00 -05:00';

   --Nine digits for fractional seconds, 24-hour clock, 14:00 = 2:00 PM
   ts2 := TIMESTAMP '2002-02-19 14:00:00.000000000 -5:00';

   --No fractional seconds at all
   ts3 := TIMESTAMP '2002-02-19 13:52:00 -5:00';

   --No time zone, defaults to session time zone
   ts4 := TIMESTAMP '2002-02-19 13:52:00';

   --A date literal
   ts5 := DATE '2002-02-19';
END;
/

DECLARE
   y2m   INTERVAL YEAR TO MONTH;
BEGIN
   y2m := NUMTOYMINTERVAL (10.5, 'Year');
   DBMS_OUTPUT.put_line (y2m);
END;
/

DECLARE
   an_interval   INTERVAL DAY TO SECOND;
BEGIN
   an_interval := NUMTODSINTERVAL (1440, 'Minute');
   DBMS_OUTPUT.put_line (an_interval);
END;
/

DECLARE
   y2m    INTERVAL YEAR TO MONTH;
   d2s1   INTERVAL DAY TO SECOND;
   d2s2   INTERVAL DAY TO SECOND;
BEGIN
   y2m := TO_YMINTERVAL ('40-3');                                     --my age
   d2s1 := TO_DSINTERVAL ('10 1:02:10');
   d2s2 := TO_DSINTERVAL ('10 1:02:10.123');              --fractional seconds
END;
/

DECLARE
   y2m   INTERVAL YEAR TO MONTH;
BEGIN
   y2m := INTERVAL '40-3' YEAR TO MONTH;

   DBMS_OUTPUT.put_line (TO_CHAR (y2m, 'YY "Years" and MM "Months"'));
END;
/

DECLARE
   y2m   INTERVAL YEAR TO MONTH;
BEGIN
   y2m := INTERVAL '40-3' YEAR TO MONTH;

   DBMS_OUTPUT.put_line(   EXTRACT (YEAR FROM y2m)
                        || ' Years and '
                        || EXTRACT (MONTH FROM y2m)
                        || ' Months');
END;
/

DECLARE
   y2ma   INTERVAL YEAR TO MONTH;
   y2mb   INTERVAL YEAR TO MONTH;
   d2sa   INTERVAL DAY TO SECOND;
   d2sb   INTERVAL DAY TO SECOND;
BEGIN
   /* Some YEAR TO MONTH examples */
   y2ma := INTERVAL '40-3' YEAR TO MONTH;
   y2mb := INTERVAL '40' YEAR;

   /* Some DAY TO SECOND examples */
   d2sa := INTERVAL '10 1:02:10.123' DAY TO SECOND;

   /* Fails in Oracle9i through 11gR2 because of a bug */
   --d2sb := INTERVAL '1:02' HOUR TO MINUTE;

   /* Following are two workarounds for defining intervals,
      such as HOUR TO MINUTE, that represent only a portion of the
      DAY TO SECOND range. */
   SELECT INTERVAL '1:02' HOUR TO MINUTE
     INTO d2sb
     FROM DUAL;

   d2sb := INTERVAL '1' HOUR + INTERVAL '02' MINUTE;
END;
/

DECLARE
   y2ma   INTERVAL YEAR TO MONTH;
   y2mb   INTERVAL YEAR TO MONTH;
   d2sa   INTERVAL DAY TO SECOND;
   d2sb   INTERVAL DAY TO SECOND;
BEGIN
   /* Some YEAR TO MONTH examples */
   y2ma := INTERVAL '40-3' YEAR TO MONTH;
   y2mb := INTERVAL '40' YEAR;

   /* Some DAY TO SECOND examples */
   d2sa := INTERVAL '10 1:02:10.123' DAY TO SECOND;

   /* Fails in Oracle9i through 11gR2 because of a bug */
   --d2sb := INTERVAL '1:02' HOUR TO MINUTE;

   /* Following are two workarounds for defining intervals,
      such as HOUR TO MINUTE, that represent only a portion of the
      DAY TO SECOND range. */
   SELECT INTERVAL '1:02' HOUR TO MINUTE
     INTO d2sb
     FROM DUAL;

   d2sb := INTERVAL '1' HOUR + INTERVAL '02' MINUTE;
END;
/

DECLARE
   tstz     timestamp WITH TIME ZONE;
   string   VARCHAR2 (40);
   tsltz    timestamp WITH LOCAL TIME ZONE;
BEGIN
   -- convert string to datetime
   tstz :=
      CAST (
         '24-Feb-2009 09.00.00.00 PM US/Eastern' AS timestamp WITH TIME ZONE
      );
   -- convert datetime back to string
   string := CAST (tstz AS varchar2);
   tsltz :=
      CAST ('24-Feb-2009 09.00.00.00 PM' AS timestamp WITH LOCAL TIME ZONE);

   DBMS_OUTPUT.put_line (tstz);
   DBMS_OUTPUT.put_line (string);
   DBMS_OUTPUT.put_line (tsltz);
END;
/

BEGIN
   IF EXTRACT (MONTH FROM SYSDATE) = 11
   THEN
      DBMS_OUTPUT.put_line ('It is November');
   ELSE
      DBMS_OUTPUT.put_line ('It is not November');
   END IF;
END;
/

DECLARE
   CURRENT_DATE   timestamp;
   result_date    timestamp;
BEGIN
   CURRENT_DATE := SYSTIMESTAMP;
   result_date := CURRENT_DATE + INTERVAL '1500 4:30:2' DAY TO SECOND;
   DBMS_OUTPUT.put_line (result_date);
END;
/

DECLARE
   end_of_may2008   timestamp;
   next_month       timestamp;
BEGIN
   end_of_may2008 := TO_TIMESTAMP ('31-May-2008', 'DD-Mon-YYYY');
   next_month := TO_TIMESTAMP (ADD_MONTHS (end_of_may2008, 1));
   DBMS_OUTPUT.put_line (next_month);
END;
/

DECLARE
   four_hours   NUMBER := 4 / 24;
BEGIN
   DBMS_OUTPUT.put_line ('Now + 4 hours =' || TO_CHAR (SYSDATE + four_hours));
END;
/

DECLARE
   leave_on_trip      timestamp := TIMESTAMP '2005-03-22 06:11:00.00';
   return_from_trip   timestamp := TIMESTAMP '2005-03-25 15:50:00.00';
   trip_length        INTERVAL DAY TO SECOND;
BEGIN
   trip_length := return_from_trip - leave_on_trip;

   DBMS_OUTPUT.put_line (
      'Length in days hours:minutes:seconds is ' || trip_length
   );
END;
/

BEGIN
   DBMS_OUTPUT.put_line(TO_DATE ('25-Mar-2005 3:50 pm'
                               , 'dd-Mon-yyyy hh:mi am'
                                )
                        - TO_DATE ('22-Mar-2005 6:11 am'
                                 , 'dd-Mon-yyyy hh:mi am'
                                  ));
END;
/

BEGIN
   --Calculate two ends of month, the first earlier than the second:
   DBMS_OUTPUT.put_line (MONTHS_BETWEEN ('31-JAN-1994', '28-FEB-1994'));

   --Calculate two ends of month, the first later than the second:
   DBMS_OUTPUT.put_line (MONTHS_BETWEEN ('31-MAR-1995', '28-FEB-1994'));

   --Calculate when both dates fall in the same month:
   DBMS_OUTPUT.put_line (MONTHS_BETWEEN ('28-FEB-1994', '15-FEB-1994'));

   --Perform months_between calculations with a fractional component:
   DBMS_OUTPUT.put_line (MONTHS_BETWEEN ('31-JAN-1994', '1-MAR-1994'));
   DBMS_OUTPUT.put_line (MONTHS_BETWEEN ('31-JAN-1994', '2-MAR-1994'));
   DBMS_OUTPUT.put_line (MONTHS_BETWEEN ('31-JAN-1994', '10-MAR-1994'));
END;
/

DECLARE
   dt1   DATE;
   dt2   DATE;
   d2s   INTERVAL DAY (3) TO SECOND (0);
BEGIN
   dt1 := TO_DATE ('15-Nov-1961 12:01 am', 'dd-Mon-yyyy hh:mi am');
   dt2 := TO_DATE ('18-Jun-1961 11:59 pm', 'dd-Mon-yyyy hh:mi am');

   d2s := CAST (dt1 AS timestamp) - CAST (dt2 AS timestamp);

   DBMS_OUTPUT.put_line (d2s);
END;
/

DECLARE
   dt     DATE;
   ts     timestamp;
   d2s1   INTERVAL DAY (3) TO SECOND (0);
   d2s2   INTERVAL DAY (3) TO SECOND (0);
BEGIN
   dt := TO_DATE ('15-Nov-1961 12:01 am', 'dd-Mon-yyyy hh:mi am');
   ts := TO_TIMESTAMP ('18-Jun-1961 11:59 pm', 'dd-Mon-yyyy hh:mi am');

   d2s1 := dt - ts;
   d2s2 := ts - dt;

   DBMS_OUTPUT.put_line (d2s1);
   DBMS_OUTPUT.put_line (d2s2);
END;
/

DECLARE
   dts1    INTERVAL DAY TO SECOND := '2 3:4:5.6';
   dts2    INTERVAL DAY TO SECOND := '1 1:1:1.1';

   ytm1    INTERVAL YEAR TO MONTH := '2-10';
   ytm2    INTERVAL YEAR TO MONTH := '1-1';

   days1   NUMBER := 3;
   days2   NUMBER := 1;
BEGIN
   DBMS_OUTPUT.put_line (dts1 - dts2);
   DBMS_OUTPUT.put_line (ytm1 - ytm2);
   DBMS_OUTPUT.put_line (days1 - days2);
END;
/

DECLARE
   dts1   INTERVAL DAY TO SECOND := '2 3:4:5.6';
   dts2   INTERVAL YEAR TO MONTH := '2-10';
   dts3   NUMBER := 3;
BEGIN
   --Show some interval multiplication
   DBMS_OUTPUT.put_line (dts1 * 2);
   DBMS_OUTPUT.put_line (dts2 * 2);
   DBMS_OUTPUT.put_line (dts3 * 2);

   --Show some interval division
   DBMS_OUTPUT.put_line (dts1 / 2);
   DBMS_OUTPUT.put_line (dts2 / 2);
   DBMS_OUTPUT.put_line (dts3 / 2);
END;
/

DECLARE
   dts   INTERVAL DAY (9) TO SECOND (9);

   FUNCTION double_my_interval (dts_in IN INTERVAL DAY TO SECOND)
      RETURN INTERVAL DAY TO SECOND
   IS
   BEGIN
      RETURN dts_in * 2;
   END;
BEGIN
   dts := '1 0:0:0.123456789';
   DBMS_OUTPUT.put_line (dts);
   DBMS_OUTPUT.put_line (double_my_interval (dts));
END;
/

DECLARE
   dts   INTERVAL DAY (9) TO SECOND (9);

   FUNCTION double_my_interval (dts_in IN dsinterval_unconstrained)
      RETURN dsinterval_unconstrained
   IS
   BEGIN
      RETURN dts_in * 2;
   END;
BEGIN
   dts := '100 0:0:0.123456789';
   DBMS_OUTPUT.put_line (dts);
   DBMS_OUTPUT.put_line (double_my_interval (dts));
END;
/

DECLARE
   ts   timestamp WITH TIME ZONE;
BEGIN
   ts := SYSTIMESTAMP;

   --Notice that ts now specifies fractional seconds
   --AND a time zone.
   DBMS_OUTPUT.put_line (ts);

   --Modify ts using one of the built-in date functions.
   ts := LAST_DAY (ts);

   --We've now LOST our fractional seconds, and the
   --time zone has changed to our session time zone.
   DBMS_OUTPUT.put_line (ts);
END;
/