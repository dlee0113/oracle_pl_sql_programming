/* These are the four Unicode-related INSTR examples.
   You MUST execute these examples on a system using UTF-8 as
   the database character set and UTF-16 as the national character
   set. Otherwise, your output will not match that shown in the book. */
DECLARE
   --The underlying database datatype for this example is Unicode UTF-8
   x CHAR(30 CHAR) := 'The character ã is two-bytes.';
BEGIN
   --Find the location of "is" in terms of characters
   DBMS_OUTPUT.PUT_LINE(INSTR(x,'is'));

   --Find the location of "is" in terms of bytes
   DBMS_OUTPUT.PUT_LINE(INSTRB(x,'is'));
END;
/

DECLARE
   --The underlying database datatype for this example is Unicode UTF-8
   x CHAR(40 CHAR) := UNISTR('The character a\0303 could be composed.');
BEGIN
   --INSTR won't see that a\0303 is the same as ã
   DBMS_OUTPUT.PUT_LINE(INSTR(x,'ã'));

   --INSTRC, however, will recognize that a\0303 = ã
   DBMS_OUTPUT.PUT_LINE(INSTRC(x,'ã'));
END;
/

DECLARE
   --The underlying database datatype for this example is Unicode UTF-16
   x NCHAR(40) := UNISTR('The character a\0303 could be composed.');
BEGIN
   --Find the location of "\0303" using INSTRC
   DBMS_OUTPUT.PUT_LINE(INSTRC(x,UNISTR('\0303')));

   --Find the location of "\0303" using INSTR4
   DBMS_OUTPUT.PUT_LINE(INSTR4(x,UNISTR('\0303')));
END;
/

DECLARE
  x NCHAR(40) := UNISTR('This is a \D834\DD1E test');
BEGIN
  DBMS_OUTPUT.PUT_LINE (INSTR2(x, UNISTR('\D834')));
  DBMS_OUTPUT.PUT_LINE (INSTR4(x, UNISTR('\D834')));
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
