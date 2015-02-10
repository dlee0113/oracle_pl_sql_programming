CREATE OR REPLACE TRIGGER employees_bi_trg
   BEFORE INSERT
   ON employees
   FOR EACH ROW
BEGIN
   :NEW.employee_id := employees_seq.NEXTVAL;
END;
/
