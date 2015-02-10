/* Create a BFILE locator */
DECLARE
   web_page BFILE;
BEGIN
   --Delete row for Tannery Falls so this example can
   --be executed multiple times
   DELETE FROM waterfalls WHERE falls_name='Tannery Falls';

   --Invoke BFILENAME to create a BFILE locator
   web_page := BFILENAME('BFILE_DATA','Tannery Falls.htm');

   --Save our new locator in the waterfalls table
   INSERT INTO waterfalls (falls_name, falls_web_page)
      VALUES ('Tannery Falls',web_page);
END;
/

DECLARE
   web_page BFILE;
   html RAW(60);
   amount BINARY_INTEGER := 60;
   offset INTEGER := 1;
BEGIN
   --Retrieve the LOB locater for the web page
   SELECT falls_web_page
     INTO web_page
     FROM waterfalls
    WHERE falls_name='Tannery Falls';

   --Open the locator, read 60 bytes, and close the locator
   DBMS_LOB.OPEN(web_page);
   DBMS_LOB.READ(web_page, amount, offset, html);
   DBMS_LOB.CLOSE(web_page);

   --Uncomment following line to display results in hex
   --DBMS_OUTPUT.PUT_LINE(RAWTOHEX(html));

   --Cast RAW results to a character string we can read
   DBMS_OUTPUT.PUT_LINE(UTL_RAW.CAST_TO_VARCHAR2(html));
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
