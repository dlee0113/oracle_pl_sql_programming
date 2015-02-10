/*
|| AUtonomous transactions in database triggers.
|| This version shows that a RAISE in the 
|| AUTONOMOUS_TRANSACTION procedure will cause an
|| automatic rollback of the DML. Makes sense; it's
|| the top-level block in the transaction.
||
|| Steven Feuerstein
|| Copyright 1999.
*/

DROP TABLE ceo_compensation;

CREATE TABLE ceo_compensation (
   company VARCHAR2(100),
   name VARCHAR2(100), 
   compensation NUMBER,
   layoffs NUMBER);

DROP TABLE ceo_comp_history;

CREATE TABLE ceo_comp_history (
   name VARCHAR2(100), 
   description VARCHAR2(255),
   occurred_on DATE);

CREATE OR REPLACE PROCEDURE audit_ceo_comp (
   name IN VARCHAR2,
   description IN VARCHAR2,
   occurred_on IN DATE
   )
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   INSERT INTO ceo_comp_history VALUES (
      audit_ceo_comp.name,
      audit_ceo_comp.description,
      audit_ceo_comp.occurred_on
      );
      
   IF audit_ceo_comp.description LIKE 'AFTER%'
   THEN
      RAISE VALUE_ERROR;
   END IF;
   
   COMMIT;
END;
/
CREATE OR REPLACE TRIGGER bef_ins_ceo_comp
BEFORE INSERT ON ceo_compensation FOR EACH ROW
DECLARE
   ok BOOLEAN := TRUE;
BEGIN
   audit_ceo_comp (
      :new.name, 'BEFORE INSERT', SYSDATE);
END;
/

CREATE OR REPLACE TRIGGER aft_ins_ceo_comp
AFTER INSERT ON ceo_compensation FOR EACH ROW
DECLARE
   ok BOOLEAN := FALSE;
BEGIN
   audit_ceo_comp (
      :new.name, 'AFTER INSERT', SYSDATE);
END;
/

COLUMN name FORMAT a20
COLUMN description FORMAT a30

SELECT name, 
       description, 
       TO_CHAR (occurred_on, 'MM/DD/YYYY HH:MI:SS') occurred_on
  FROM ceo_comp_history;   

BEGIN
   INSERT INTO ceo_compensation VALUES (
      'Mattel', 'Jill Barad', 9100000, 2700);
      
   INSERT INTO ceo_compensation VALUES (
      'American Express Company', 'Harvey Golub', 33200000, 3300);
      
   INSERT INTO ceo_compensation VALUES (
      'Eastman Kodak', 'George Fisher', 10700000, 20100);
      
   ROLLBACK; -- I wish!
END;
/

SELECT name, 
       description, 
       TO_CHAR (occurred_on, 'MM/DD/YYYY HH:MI:SS') occurred_on
  FROM ceo_comp_history;   
   

/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
