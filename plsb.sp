CREATE OR REPLACE PROCEDURE plsb (str IN VARCHAR2, bool IN BOOLEAN)
IS
BEGIN
   IF bool
   THEN
      DBMS_OUTPUT.PUT_LINE (str || ' - TRUE');
   ELSIF NOT bool
   THEN
      DBMS_OUTPUT.PUT_LINE (str || ' - FALSE');
   ELSE
      DBMS_OUTPUT.PUT_LINE (str || ' - NULL');
   END IF;
END plsb;
/



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
