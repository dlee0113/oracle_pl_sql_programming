CREATE OR REPLACE TRIGGER what_got_dropped
AFTER ALTER ON SCHEMA
BEGIN
  IF IS_DROP_COLUMN('COL2') THEN
    DBMS_OUTPUT.PUT_LINE('You dropped col2');
  END IF;
END;
/



/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
