/* Demonstrates the effects of NULLs on Boolean expressions */
DECLARE
   x NUMBER := NULL;
BEGIN
   IF x = 2 THEN
      DBMS_OUTPUT.PUT_LINE('x contains 2');
   ELSE
      DBMS_OUTPUT.PUT_LINE('x doesn''t contain 2');
   END IF;

   IF x <> 2 THEN
      DBMS_OUTPUT.PUT_LINE('x doesn''t contain 2');
   ELSE
      DBMS_OUTPUT.PUT_LINE('x contains 2');
   END IF;
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
