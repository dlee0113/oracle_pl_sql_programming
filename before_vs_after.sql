/*-- before_vs_after.sql */
-- a before statement level trigger
CREATE OR REPLACE TRIGGER before_statement_trigger
BEFORE INSERT ON to_table
BEGIN
  DBMS_OUTPUT.PUT_LINE('Before Insert Statement Level');
END;
/

-- a before row level trigger
CREATE OR REPLACE TRIGGER before_row_trigger
BEFORE INSERT ON to_table
FOR EACH ROW
BEGIN
  DBMS_OUTPUT.PUT_LINE('Before Insert Row Level');
END;
/




/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
