CREATE OR REPLACE PROCEDURE bpl (boolean_in IN BOOLEAN)
IS
BEGIN
   DBMS_OUTPUT.put_line (CASE boolean_in
                            WHEN TRUE THEN 'TRUE'
                            WHEN FALSE THEN 'FALSE'
                            ELSE 'NULL'
                         END);
END bpl;
/



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
