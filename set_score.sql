CREATE OR REPLACE TRIGGER set_score
BEFORE INSERT ON frame
FOR EACH ROW
WHEN ( new.score IS NULL )
BEGIN
  IF :NEW.strike = 'Y' THEN
    :NEW.score := 10;
  ELSIF :NEW.spare = 'Y' THEN
       :NEW.score := 5;
  END IF;
END;
/



/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
