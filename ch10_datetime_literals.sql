/* This example demonstrates the various types of date and
   timestamp literals. Note that this example generates no
   output. */
DECLARE
   a TIMESTAMP WITH TIME ZONE;
   b TIMESTAMP WITH TIME ZONE;
   c TIMESTAMP WITH TIME ZONE;
   d TIMESTAMP WITH TIME ZONE;
   e DATE;
BEGIN
   --Two digits for fractional seconds
   a := TIMESTAMP '2002-02-19 11:52:00.00 -05:00';

   --Nine digits for fractional seconds, 24-hour clock, 14:00 = 2:00 PM
   b := TIMESTAMP '2002-02-19 14:00:00.000000000 -5:00';

   --No fractional seconds at all
   c := TIMESTAMP '2002-02-19 13:52:00 -5:00';

   --No time zone, defaults to session time zone
   d := TIMESTAMP '2002-02-19 13:52:00';

   --A date literal
   e := DATE '2002-02-19';
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
