DROP TABLE ceo_compensation;

CREATE TABLE ceo_compensation (
   company VARCHAR2(100),
   NAME VARCHAR2(100),
   compensation NUMBER);

DROP TABLE ceo_comp_history;

CREATE TABLE ceo_comp_history (
   NAME VARCHAR2(100),
   description VARCHAR2(255),
   occurred_on DATE);

CREATE OR REPLACE TRIGGER bef_ins_ceo_comp
   BEFORE INSERT
   ON ceo_compensation
   FOR EACH ROW
DECLARE
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   INSERT INTO ceo_comp_history
        VALUES (:NEW.NAME, 'BEFORE INSERT', SYSDATE);

   COMMIT;
END;
/
CREATE OR REPLACE TRIGGER aft_ins_ceo_comp
   AFTER INSERT
   ON ceo_compensation
   FOR EACH ROW
DECLARE
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   -- Let's be reasonable.
   IF :NEW.compensation > 1000000000
   THEN
      RAISE VALUE_ERROR;
   ELSE
      INSERT INTO ceo_comp_history
           VALUES (:NEW.NAME, 'AFTER INSERT', SYSDATE);

      COMMIT;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      ROLLBACK;
      RAISE;
END;
/
COLUMN name FORMAT a20
COLUMN description FORMAT a30

SELECT NAME, description
     , TO_CHAR (occurred_on, 'MM/DD/YYYY HH:MI:SS') occurred_on
  FROM ceo_comp_history;

BEGIN
   INSERT INTO ceo_compensation
        VALUES ('BIG APPETITE', 'Joe Halabut', 9100000);

   INSERT INTO ceo_compensation
        VALUES ('BIGGER APPETITE', 'Ami Chiste', 10700000);

   INSERT INTO ceo_compensation
        VALUES ('BIGGEST APPETITE', 'Sally Bigdeal', 1000000001);

END;
/

SELECT   NAME, description
       , TO_CHAR (occurred_on, 'MM/DD/YYYY HH:MI:SS') occurred_on
    FROM ceo_comp_history
ORDER BY occurred_on;