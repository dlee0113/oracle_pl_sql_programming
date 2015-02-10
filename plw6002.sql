ALTER SESSION SET plsql_warnings = 'enable:all'
/

DROP FUNCTION plw6002;

CREATE OR REPLACE PROCEDURE plw6002
AS
   l_checking BOOLEAN := FALSE;
BEGIN
   NULL;
   IF l_checking
   THEN
      DBMS_OUTPUT.put_line ('Never here...');
   ELSE
      DBMS_OUTPUT.put_line ('Always here...');
	  GOTO end_of_function;
   END IF;
   <<end_of_function>>
   NULL;
END plw6002;
/

SHOW ERRORS PROCEDURE plw6002

REM And this program does not generate any warnings...

DROP PROCEDURE plw6002;

CREATE OR REPLACE FUNCTION plw6002 RETURN VARCHAR2
AS
BEGIN
   RETURN NULL;
   DBMS_OUTPUT.put_line ('Never here...');
END plw6002;
/

SHOW ERRORS PROCEDURE plw6002
