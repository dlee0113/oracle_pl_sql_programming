CREATE OR REPLACE TRIGGER what_got_dropped
AFTER ALTER ON SCHEMA
BEGIN
  IF IS_DROP_COLUMN('COL2') THEN
    DBMS_OUTPUT.PUT_LINE('You dropped col2');
  END IF;
END;
/



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
