/*-- statement_vs_row.sql */
-- an after statement level trigger
CREATE OR REPLACE TRIGGER statement_trigger
AFTER INSERT ON to_table
BEGIN
  DBMS_OUTPUT.PUT_LINE('After Insert Statement Level');
END;
/
/*-- an after row level trigger */
CREATE OR REPLACE TRIGGER row_trigger
AFTER INSERT ON to_table
FOR EACH ROW
BEGIN
  DBMS_OUTPUT.PUT_LINE('After Insert Row Level');
END;
/

/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
