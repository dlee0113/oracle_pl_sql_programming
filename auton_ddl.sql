REM Pass in -- for parameter to turn off autonomous transaction
REM Pass in /**/ to turn it on.

DROP TABLE temp_table;

CREATE OR REPLACE PROCEDURE execddl 
AUTHID CURRENT_USER
IS
   &1 PRAGMA AUTONOMOUS_TRANSACTION;                            
BEGIN
   EXECUTE IMMEDIATE 'create table temp_table (d date)';
END;
/

DROP TABLE emp_temp;

CREATE TABLE emp_temp AS SELECT * FROM emp;

SELECT COUNT (*)
  FROM emp_temp;

DELETE FROM emp_temp;

SELECT COUNT (*)
  FROM emp_temp;

EXEC execddl

ROLLBACK ;

SELECT COUNT (*)
  FROM emp_temp;



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/

