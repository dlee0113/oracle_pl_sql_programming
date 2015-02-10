/* This is the TO_MULTI_BYTE example. To get the results shown in the book,
   you must be running with UTF-8 as the NATIONAL character set. */
DECLARE
   g_one_byte NVARCHAR2 (1 CHAR) := 'G';
   g_three_bytes NVARCHAR2 (1 CHAR);
   g_one_again NVARCHAR2(1 CHAR);
   dump_output VARCHAR2(30);
BEGIN
   --Convert single-byte "G" to its multibyte representation
   g_three_bytes := TO_MULTI_BYTE(g_one_byte);
   DBMS_OUTPUT.PUT_LINE(LENGTHB(g_one_byte));
   DBMS_OUTPUT.PUT_LINE(LENGTHB(g_three_bytes));
   SELECT DUMP(g_three_bytes) INTO dump_output FROM dual;
   DBMS_OUTPUT.PUT_LINE(dump_output);

   --Convert that multibyte representation back to a single byte
   g_one_again := TO_SINGLE_BYTE(g_three_bytes);
   DBMS_OUTPUT.PUT_LINE(g_one_again || ' is ' ||
                        TO_CHAR(LENGTHB(g_one_again))
                        || ' byte again.');
END;
/



/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
