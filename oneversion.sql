SET FEEDBACK OFF
SET VERIFY ON

REM
REM SQL*Plus script that automatically detects the Oracle version
REM and sets substitution variables that turn on or off
REM the new 8i AUTHID CURRENT_USER feature
REM
REM Steven Feuerstein

REM Detect version and set variables accordingly.
COLUMN col NOPRINT NEW_VALUE v_orcl_vers

SELECT SUBSTR(version,1,3) col
  FROM product_component_version
 WHERE UPPER(product) LIKE 'ORACLE7%'
    OR UPPER(product) LIKE 'PERSONAL ORACLE%'
    OR UPPER(product) LIKE 'ORACLE8%'
	OR UPPER(product) LIKE 'ORACLE9%';

COLUMN col NOPRINT NEW_VALUE authidopen
SELECT DECODE (upper('&&v_orcl_vers'),
               '8.1', '/**/','9.0', '/**/',
               '/* Oracle 8.1 Only!') col  
  FROM dual;

COLUMN col NOPRINT NEW_VALUE authidclose
SELECT DECODE (upper('&&v_orcl_vers'),
               '8.1', '/**/','9.0', '/**/',
               '*/') col  
  FROM dual;
    
REM Now I can use those variables...

CREATE OR REPLACE PROCEDURE either_way 
   &&authidopen AUTHID CURRENT_USER &&authidclose
IS
   v_count PLS_INTEGER;
BEGIN
   SELECT COUNT(*) INTO v_count FROM emp;   
   DBMS_OUTPUT.PUT_LINE ('Emp count: ' || v_count);
END;
/
GRANT EXECUTE ON either_way TO PUBLIC;

SET SERVEROUTPUT ON
exec either_way;

CONNECT demo/demo
create table emp as select * from scott.emp;
SET SERVEROUTPUT ON

DELETE FROM emp;

exec SCOTT.either_way;

ROLLBACK;


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
