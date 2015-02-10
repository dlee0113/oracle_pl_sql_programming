/* Use a SYS.HttpUriType value to retrieve a message from a URL */
DECLARE
   WebPageURL sys.HttpUriType;
   WebPage CLOB;
BEGIN
   --Create an instance of the type pointing
   --to a message from Jonathan Gennick
   WebPageURL := SYS.HttpUriType.createUri(
                    'http://gennick.com/message.plsql');

   --Retrieve the message via HTTP
   WebPage := WebPageURL.getclob();

   --Display the message
   DBMS_OUTPUT.PUT_LINE((SUBSTR(WebPage,1,60)));
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
