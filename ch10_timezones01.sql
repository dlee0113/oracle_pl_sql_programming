/* Examples of converting time zones to character strings */
DECLARE
   A TIMESTAMP WITH TIME ZONE;
   B TIMESTAMP WITH TIME ZONE;
   C TIMESTAMP WITH TIME ZONE;
BEGIN
   A := TO_TIMESTAMP_TZ('2002-06-18 13:52:00.123456789 -5:00',
                        'YYYY-MM-DD HH24:MI:SS.FF TZH:TZM');
   B := TO_TIMESTAMP_TZ('2002-06-18 13:52:00.123456789 US/Eastern',
                        'YYYY-MM-DD HH24:MI:SS.FF TZR');
   C := TO_TIMESTAMP_TZ('2002-06-18 13:52:00.123456789 US/Eastern EDT',
                        'YYYY-MM-DD HH24:MI:SS.FF TZR TZD');

   DBMS_OUTPUT.PUT_LINE(TO_CHAR(A,
      'YYYY-MM-DD HH:MI:SS.FF AM TZH:TZM TZR TZD'));
   DBMS_OUTPUT.PUT_LINE(TO_CHAR(B,
      'YYYY-MM-DD HH:MI:SS.FF AM TZH:TZM TZR TZD'));
   DBMS_OUTPUT.PUT_LINE(TO_CHAR(C,
      'YYYY-MM-DD HH:MI:SS.FF AM TZH:TZM TZR TZD'));
END;
/



/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
