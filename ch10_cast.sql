/* CAST examples */

DECLARE
   a TIMESTAMP WITH TIME ZONE;
   b VARCHAR2(40);
   c TIMESTAMP WITH LOCAL TIME ZONE;
BEGIN
   a := CAST ('24-Feb-2002 09.00.00.00 PM US/Eastern'
              AS TIMESTAMP WITH TIME ZONE);
   b := CAST (a AS VARCHAR2);
   c := CAST (a AS TIMESTAMP WITH LOCAL TIME ZONE);

   DBMS_OUTPUT.PUT_LINE(a);
   DBMS_OUTPUT.PUT_LINE(b);
   DBMS_OUTPUT.PUT_LINE(c);
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
