CREATE OR REPLACE PROCEDURE bpl (val IN BOOLEAN, str IN VARCHAR2)
IS
BEGIN
   IF val
   THEN
      DBMS_OUTPUT.put_line (str || '-TRUE');
   ELSIF NOT val
   THEN
      DBMS_OUTPUT.put_line (str || '-FALSE');
   ELSE
      DBMS_OUTPUT.put_line (str || '-NULL');
   END IF;
END;
/