/* Formatted on 2001/12/26 13:53 (Formatter Plus v4.5.2) */
CREATE TYPE strings_nt IS TABLE OF VARCHAR2 (100);
/

DECLARE
   TYPE strings_ibt IS TABLE OF VARCHAR2 (100)
      INDEX BY BINARY_INTEGER;

   strings   strings_nt := strings_nt ();
   ibt_strings strings_ibt;
BEGIN
   BEGIN
   IF ibt_strings(2) = 'a' THEN NULL; END IF;
   EXCEPTION
      WHEN OTHERS
         THEN DBMS_OUTPUT.put_line (   'a. ' || SQLERRM);
   END;
   BEGIN
      strings.EXTEND; strings (2) := 'b';
   EXCEPTION
      WHEN OTHERS
         THEN DBMS_OUTPUT.put_line (   'b. ' || SQLERRM);
   END;

   BEGIN
      strings (0) := 'c';
   EXCEPTION
      WHEN OTHERS
         THEN DBMS_OUTPUT.put_line (   'c. ' || SQLERRM);
   END;
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
