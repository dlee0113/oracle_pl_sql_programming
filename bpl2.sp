CREATE OR REPLACE PROCEDURE bpl (val IN BOOLEAN, str IN VARCHAR2)
IS
BEGIN
   IF val
   THEN
      DBMS_OUTPUT.put_line (str || '-TRUE');
   ELSIF NOT val
   THEN
      DBMS_OUTPUT.put_line (str || '-FALSE');
   ELSE
      DBMS_OUTPUT.put_line (str || '-NULL');
   END IF;
END;
/



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
