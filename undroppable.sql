CREATE OR REPLACE TRIGGER undroppable
BEFORE DROP ON SCHEMA
BEGIN
  RAISE_APPLICATION_ERROR(-20000,'You cannot drop me! I am invincible!');
END;
/




/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/

