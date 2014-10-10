/* Adding and subtracting intervals */
DECLARE
   a1 INTERVAL DAY TO SECOND := '2 3:4:5.6';
   b1 INTERVAL DAY TO SECOND := '1 1:1:1.1';

   a2 INTERVAL YEAR TO MONTH := '2-10';
   b2 INTERVAL YEAR TO MONTH := '1-1';

   a3 NUMBER := 3;
   b3 NUMBER := 1;
BEGIN
   DBMS_OUTPUT.PUT_LINE(a1 - b1);
   DBMS_OUTPUT.PUT_LINE(a2 - b2);
   DBMS_OUTPUT.PUT_LINE(a3 - b3);
END;
/




/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/