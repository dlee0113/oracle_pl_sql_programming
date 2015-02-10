/* Interval value expressions. Note that this example generates
   no output. */
DECLARE
   A INTERVAL YEAR TO MONTH;
   B INTERVAL YEAR TO MONTH;
   C INTERVAL DAY TO SECOND;
   D INTERVAL DAY TO SECOND;
BEGIN
   /* Some YEAR TO MONTH examples */
   A := INTERVAL '40-3' YEAR TO MONTH;
   B := INTERVAL '40' YEAR;

   /* Some DAY TO SECOND examples */
   C := INTERVAL '10 1:02:10.123' DAY TO SECOND;

   /* Fails in Oracle9i, Release 1 because of a bug */
   --D := INTERVAL '1:02' HOUR TO MINUTE;

   /* Following are two workarounds for defining intervals,
      such as HOUR TO MINUTE, that represent only a portion of the
      DAY TO SECOND range. */
   SELECT INTERVAL '1:02' HOUR TO MINUTE
   INTO D
   FROM dual;

   D := INTERVAL '1' HOUR + INTERVAL '02' MINUTE;
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
