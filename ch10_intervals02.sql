/* Following are some more examples of interval arithmetic. */
DECLARE
   hire_date TIMESTAMP WITH TIME ZONE;

   a INTERVAL YEAR TO MONTH;
   b INTERVAL DAY TO SECOND;
BEGIN
   hire_date := TIMESTAMP '2000-09-01 00:00:00 -5:00';
   DBMS_OUTPUT.PUT_LINE(hire_date);

   a := INTERVAL '1-2' YEAR TO MONTH;
   b := INTERVAL '3 4:5:6.7' DAY TO SECOND;

   --Add some years and months
   hire_date := hire_date + a;
   DBMS_OUTPUT.PUT_LINE(hire_date);

   --Add some days, hours, minutes, and seconds
   hire_date := hire_date + b;
   DBMS_OUTPUT.PUT_LINE(hire_date);
END;
/


/* Following is the original version of the above example. It contains
   a third example that adds 36/24 to hire_date. You may need to work
   through the output with pencil and paper to convince yourself that
   the output is correct. */

 DECLARE
   hire_date TIMESTAMP WITH TIME ZONE;

   a INTERVAL YEAR TO MONTH;
   b INTERVAL DAY TO SECOND;
BEGIN
   hire_date := TIMESTAMP '2000-09-01 00:00:00 -5:00';
   DBMS_OUTPUT.PUT_LINE(hire_date);

   a := INTERVAL '1-2' YEAR TO MONTH;
   b := INTERVAL '3 4:5:6.7' DAY TO SECOND;

   --Add some years and months
   hire_date := hire_date + a;
   DBMS_OUTPUT.PUT_LINE(hire_date);

   --Add some days, hours, minutes, and seconds
   hire_date := hire_date + b;
   DBMS_OUTPUT.PUT_LINE(hire_date);

   --Get really complicated: add 1 year, 2 months,
   --3 days, 4 hours, 5 minutes, 6.7 seconds; and to
   --that, add in another 36 hours
   hire_date := hire_date + a + b + 36/24;
   DBMS_OUTPUT.PUT_LINE(hire_date);
END;
/




/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
