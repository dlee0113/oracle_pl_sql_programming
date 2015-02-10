/* Examples of the ROUND function being applied to datetime values. */
DECLARE
   date_in DATE := TO_DATE('24-Feb-2002 05:16:00 PM'
                    ,'DD-MON-YYYY HH:MI:SS AM');
   date_rounded DATE;
   date_truncated DATE;
BEGIN
   date_rounded := ROUND(date_in);
   date_truncated := TRUNC(date_in);

   DBMS_OUTPUT.PUT_LINE(
      TO_CHAR(date_rounded, 'DD-MON-YYYY HH:MI:SS AM'));
   DBMS_OUTPUT.PUT_LINE(
      TO_CHAR(date_truncated,'DD-MON-YYYY HH:MI:SS AM'));
END;
/

/* The following example is a couple pages past the previous example */
DECLARE
   date_in_1 DATE := TO_DATE('24-Feb-2002','DD-MON-YYYY');
   date_in_2 DATE := TO_DATE('24-Feb-1902','DD-MON-YYYY');
   date_in_3 DATE := TO_DATE('24-Feb-2002 05:36:00 PM'
                            ,'DD-MON-YYYY HH:MI:SS AM');

   round_1 DATE;
   round_2 DATE;
   round_3 DATE;

BEGIN
   round_1 := ROUND(date_in_1,'CC');
   round_2 := ROUND(date_in_2,'CC');
   round_3 := ROUND(date_in_3,'HH');

   DBMS_OUTPUT.PUT_LINE(TO_CHAR(round_1,'DD-MON-YYYY HH:MI:SS AM'));
   DBMS_OUTPUT.PUT_LINE(TO_CHAR(round_2,'DD-MON-YYYY HH:MI:SS AM'));
   DBMS_OUTPUT.PUT_LINE(TO_CHAR(round_3,'DD-MON-YYYY HH:MI:SS AM'));
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
