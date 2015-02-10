CREATE OR REPLACE TRIGGER undroppable
BEFORE DROP ON SCHEMA
BEGIN
  RAISE_APPLICATION_ERROR(-20000,'You cannot drop me! I am invincible!');
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
