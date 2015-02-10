/* Demonstrates that empty strings are NULL */
DECLARE
   empty_varchar2 VARCHAR2(10) := '';
   empty_char CHAR(10) := '';
BEGIN
   IF empty_varchar2 IS NULL THEN
      DBMS_OUTPUT.PUT_LINE('empty_varchar2 is NULL');
   END IF;

   IF '' IS NULL THEN
      DBMS_OUTPUT.PUT_LINE(''''' is NULL');
   END IF;

   IF empty_char IS NULL THEN
      DBMS_OUTPUT.PUT_LINE('empty_char is NULL');
   END IF;
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
