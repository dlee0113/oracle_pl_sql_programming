/*-- overloaded_update.sql */
CREATE OR REPLACE TRIGGER validate_update
BEFORE UPDATE ON account_transaction
FOR EACH ROW
BEGIN
  IF UPDATING('ACCOUNT_NO') THEN
    application_error_handler('ERROR',
      'Account number cannot be updated');
  END IF;
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
