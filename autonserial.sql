DROP TABLE emp2;
CREATE TABLE emp2 AS SELECT * FROM emp;

CREATE OR REPLACE PROCEDURE fire_em_all
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   DELETE FROM emp2;

   COMMIT;
EXCEPTION -- London 2/18/2002: cover errors!
   WHEN OTHERS
   THEN
      log81.saveline (SQLCODE, 'error in fire_em_all');
      ROLLBACK;
END;
/

DECLARE
   num   INTEGER;
BEGIN
   SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

   SELECT COUNT (*)
     INTO num
     FROM emp2;

   DBMS_OUTPUT.put_line ('Before isolated AT delete ' || num);
   fire_em_all;

   SELECT COUNT (*)
     INTO num
     FROM emp2;

   DBMS_OUTPUT.put_line ('After isolated AT delete ' || num);
   COMMIT; -- ROLLBACK;

   SELECT COUNT (*)
     INTO num
     FROM emp2;

   DBMS_OUTPUT.put_line ('After MT commit ' || num);
END;
/
