/*-- one_trigger_does_it_all.sql */
CREATE OR REPLACE TRIGGER three_for_the_price_of_one
BEFORE DELETE OR INSERT OR UPDATE ON account_transaction
FOR EACH ROW
BEGIN
  -- track who created the new row
  IF INSERTING THEN
    :NEW.created_by := USER;
    :NEW.created_date := SYSDATE;
  ELSIF DELETING THEN
       -- for delete write and audit using a
       -- central procedure
       audit_deletion(USER,SYSDATE);
  -- track who last updated the row
  ELSIF UPDATING THEN
    :NEW.LAST_UPDATED_BY := USER;
    :NEW.LAST_UPDATED_DATE := SYSDATE;
  END IF;
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
