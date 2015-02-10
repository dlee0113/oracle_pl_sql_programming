/* Extract and display the URL for Munising Falls */
<<demo_block>>
DECLARE
   fall SYS.XMLType;
   url VARCHAR2(80);
BEGIN
   --Retrieve XML for Munising Falls
   SELECT fall INTO demo_block.fall
   FROM falls f
   WHERE f.fall_id = 1;

   --Extract and display the URL for Munising Falls
   url := fall.extract('/fall/url/text()').getStringVal;
   DBMS_OUTPUT.PUT_LINE(url);
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
