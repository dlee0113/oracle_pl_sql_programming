/*-- old_and_new.sql */
-- default old and new
CREATE OR REPLACE TRIGGER old_new_insert
BEFORE INSERT ON frame
FOR EACH ROW
BEGIN
  DBMS_OUTPUT.PUT_LINE('Old Strike = ' || :old.strike);
  DBMS_OUTPUT.PUT_LINE('New Strike = ' || :new.strike);
END;
/

-- explicit default old and new
CREATE OR REPLACE TRIGGER old_new_update
BEFORE update ON frame
REFERENCING OLD AS old NEW AS new
FOR EACH ROW
BEGIN
  DBMS_OUTPUT.PUT_LINE('Old Strike = ' || :old.strike);
  DBMS_OUTPUT.PUT_LINE('New Strike = ' || :new.strike);
END;
/

-- changing the defaults
CREATE OR REPLACE TRIGGER old_new_delete
BEFORE delete ON frame
REFERENCING OLD AS old_values NEW AS new_values
FOR EACH ROW
BEGIN
  DBMS_OUTPUT.PUT_LINE('Old Strike = ' || :old_values.strike);
  DBMS_OUTPUT.PUT_LINE('New Strike = ' || :new_values.strike);
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
