/* Read back the directions that ch12_clob02.sql wrote to the waterfalls table. */
DECLARE
   directions CLOB;
   directions_1 VARCHAR2(300);
   directions_2 VARCHAR2(300);
   chars_read_1 BINARY_INTEGER;
   chars_read_2 BINARY_INTEGER;
   offset INTEGER;
BEGIN
   --Retrieve the LOB locater inserted previously
   SELECT falls_directions
     INTO directions
     FROM waterfalls
    WHERE falls_name='Munising Falls';

   --Begin reading with the first character
   offset := 1;

   --Attempt to read 229 characters of directions, chars_read_1 will
   --be updated with the actual number of characters read
   chars_read_1 := 229;
   DBMS_LOB.READ(directions, chars_read_1, offset, directions_1);

   --If we read 229 characters, update the offset and try to
   --read 255 more.
   IF chars_read_1 = 229 THEN
      offset := offset + chars_read_1;
      chars_read_2 := 255;
      DBMS_LOB.READ(directions, chars_read_2, offset, directions_2);
   ELSE
      chars_read_2 := 0;
      directions_2 := '';
   END IF;

   --Display the total number of characters read
   DBMS_OUTPUT.PUT_LINE('Characters read = ' ||
                        TO_CHAR(chars_read_1+chars_read_2));

   --Display the directions
   DBMS_OUTPUT.PUT_LINE(directions_1);
   DBMS_OUTPUT.PUT_LINE(directions_2);
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
