/* Multiplying and dividing intervals */
DECLARE
   a1 INTERVAL DAY TO SECOND := '2 3:4:5.6';
   a2 INTERVAL YEAR TO MONTH := '2-10';
   a3 NUMBER := 3;
BEGIN
   --Show some interval multiplication
   DBMS_OUTPUT.PUT_LINE(a1 * 2);
   DBMS_OUTPUT.PUT_LINE(a2 * 2);
   DBMS_OUTPUT.PUT_LINE(a3 * 2);

   --Show some interval division
   DBMS_OUTPUT.PUT_LINE(a1 / 2);
   DBMS_OUTPUT.PUT_LINE(a2 / 2);
   DBMS_OUTPUT.PUT_LINE(a3 / 2);
END;
/




/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/