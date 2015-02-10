/* Examples of the TRUNC function being applied to datetime values. */
DECLARE
   date_in DATE := TO_DATE('24-Feb-2002 05:36:00 PM'
                    ,'DD-MON-YYYY HH:MI:SS AM');
   trunc_to_year DATE;
   trunc_to_month DATE;

BEGIN
   trunc_to_year := TRUNC(date_in,'YYYY');
   trunc_to_month := TRUNC(date_in,'MM');

   DBMS_OUTPUT.PUT_LINE(
      TO_CHAR(trunc_to_year, 'DD-MON-YYYY HH:MI:SS AM'));
   DBMS_OUTPUT.PUT_LINE(
      TO_CHAR(trunc_to_month,'DD-MON-YYYY HH:MI:SS AM'));
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
