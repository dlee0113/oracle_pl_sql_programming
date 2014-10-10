CREATE OR REPLACE TRIGGER DEPARTMENT_bir
  BEFORE INSERT ON DEPARTMENT
  FOR EACH ROW
DECLARE
BEGIN
   IF :NEW.DEPARTMENT_ID IS NULL
   THEN
      :NEW.DEPARTMENT_ID := DEPARTMENT_CP.next_key;
   END IF;
  :new.CREATED_ON := SYSDATE;
  :new.CREATED_BY := USER;
  :new.CHANGED_ON := SYSDATE;
  :new.CHANGED_BY := USER;
END DEPARTMENT_bir;
/

CREATE OR REPLACE TRIGGER DEPARTMENT_bur
  BEFORE UPDATE ON DEPARTMENT
  FOR EACH ROW
DECLARE
BEGIN
  :new.CHANGED_ON := SYSDATE;
  :new.CHANGED_BY := USER;
END DEPARTMENT_bur;
/



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
