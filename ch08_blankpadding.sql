/* Shows the difference between blank-padded string
   comparisions and non-blank-padded string comparisions. */
DECLARE
   company_name CHAR(30)
      := 'Feuerstein and Friends';
   char_parent_company_name CHAR(35)
      := 'Feuerstein and Friends';
   varchar2_parent_company_name VARCHAR2(35)
      := 'Feuerstein and Friends';
BEGIN
   --Compare two CHARs, so blank-padding is used
   IF company_name = char_parent_company_name THEN
      DBMS_OUTPUT.PUT_LINE ('first comparison is TRUE');
   ELSE
      DBMS_OUTPUT.PUT_LINE ('first comparison is FALSE');
   END IF;

   --Compare a CHAR and a VARCHAR2, so nonblank-padding is used
   IF company_name = varchar2_parent_company_name THEN
      DBMS_OUTPUT.PUT_LINE ('second comparison is TRUE');
   ELSE
      DBMS_OUTPUT.PUT_LINE ('second comparison is FALSE');
   END IF;
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
