CREATE OR REPLACE TRIGGER employees_bi_trg
   BEFORE INSERT
   ON employees
   FOR EACH ROW
BEGIN
   :NEW.employee_id := employees_seq.NEXTVAL;
END;
/



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
