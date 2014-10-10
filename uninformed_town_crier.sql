CREATE OR REPLACE TRIGGER town_crier
AFTER CREATE ON SCHEMA
BEGIN
  DBMS_OUTPUT.PUT_LINE('I believe you have created something!');
END;
/

SET SERVEROUTPUT ON
DROP TABLE a_table;
CREATE TABLE a_table
(col1 NUMBER);

CREATE INDEX an_index ON a_table(col1);

DROP FUNCTION a_function;
CREATE FUNCTION a_function RETURN BOOLEAN AS
BEGIN
  RETURN(TRUE);
END;
/

/*-- a CRLF to flush DBMS_OUTPUTs buffer */
EXEC DBMS_OUTPUT.PUT_LINE(CHR(10));




/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
