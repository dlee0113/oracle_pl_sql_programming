CALL DBMS_WARNING.SET_WARNING_SETTING_STRING('ENABLE:ALL' ,'SESSION');

CREATE OR REPLACE PROCEDURE cant_go_there 
AS
   l_salary NUMBER := 10000;
BEGIN
   IF l_salary > 20000
   THEN
      dbms_output.put_line ('Executive');
   ELSE
      dbms_output.put_line ('Drone');
   END IF;
END cant_go_there;
/

SHOW ERRORS

CREATE OR REPLACE PROCEDURE cant_go_there
AS
   l_name varchar2(100) := 'steven';
BEGIN
   IF l_name = 'STEVEN'
   THEN
      dbms_output.put_line ('Impossible');
   ELSE
      dbms_output.put_line ('Guaranteed');
   END IF;
END cant_go_there;
/

SHOW ERRORS



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/


