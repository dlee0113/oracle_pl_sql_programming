ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL'
/
CREATE OR REPLACE FUNCTION plw7204
   RETURN PLS_INTEGER
AS
   l_count PLS_INTEGER;
BEGIN
   SELECT COUNT(*) INTO l_count
     FROM employees
	WHERE salary = '10000';
   RETURN l_count;	
END plw7204;
/

SHOW ERRORS FUNCTION plw7204



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
