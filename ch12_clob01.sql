/* Demonstrates the difference between an empty LOB and a NULL LOB */
DECLARE
   directions CLOB;
BEGIN
   --Delete any existing rows for 'Munising Falls' so that this
   --example can be executed multiple times
   DELETE
     FROM waterfalls
    WHERE falls_name='Munising Falls';

   --Insert a new row using EMPTY_CLOB() to create a LOB locator
   INSERT INTO waterfalls
             (falls_name,falls_directions)
      VALUES ('Munising Falls',EMPTY_CLOB());

   --Retrieve the LOB locater created by the previous INSERT statement
   SELECT falls_directions
     INTO directions
     FROM waterfalls
    WHERE falls_name='Munising Falls';

   IF directions IS NULL THEN
      DBMS_OUTPUT.PUT_LINE('directions is NULL');
   ELSE
      DBMS_OUTPUT.PUT_LINE('directions is not NULL');
   END IF;

   DBMS_OUTPUT.PUT_LINE('Length = '
                        || DBMS_LOB.GETLENGTH(directions));
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
