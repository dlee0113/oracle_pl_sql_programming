CREATE OR REPLACE PROCEDURE plsb (str IN VARCHAR2, bool IN BOOLEAN)
IS
BEGIN
   IF bool
   THEN
      DBMS_OUTPUT.PUT_LINE (str || ' - TRUE');
   ELSIF NOT bool
   THEN
      DBMS_OUTPUT.PUT_LINE (str || ' - FALSE');
   ELSE
      DBMS_OUTPUT.PUT_LINE (str || ' - NULL');
   END IF;
END plsb;
/