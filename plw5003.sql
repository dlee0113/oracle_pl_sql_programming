CREATE OR REPLACE PROCEDURE very_confusing (
   arg1   IN              VARCHAR2
 , arg2   IN OUT          VARCHAR2
 , arg3   IN OUT NOCOPY   VARCHAR2
)
IS
BEGIN
   arg2 := 'Second value';
   DBMS_OUTPUT.put_line ('arg2 assigned, arg1 = ' || arg1);
   arg3 := 'Third value';
   DBMS_OUTPUT.put_line ('arg3 assigned, arg1 = ' || arg1);
END;
/

DECLARE
   str   VARCHAR2 (100) := 'First value';
BEGIN
   DBMS_OUTPUT.put_line ('str before = ' || str);
   very_confusing (str, str, str);
   DBMS_OUTPUT.put_line ('str after = ' || str);
END;
/

CREATE OR REPLACE PROCEDURE plw5003
IS
   str   VARCHAR2 (100) := 'First value';
BEGIN
   DBMS_OUTPUT.put_line ('str before = ' || str);
   very_confusing (str, str, str);
   DBMS_OUTPUT.put_line ('str after = ' || str);
END plw5003;
/