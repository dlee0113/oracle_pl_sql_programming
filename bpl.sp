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