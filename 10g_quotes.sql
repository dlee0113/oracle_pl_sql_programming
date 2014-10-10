BEGIN
    DBMS_OUTPUT.PUT_LINE (
       q'[What's a quote among friends?]');
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE (
       q'!What's a quote among friends?!');
END;
/

CREATE OR REPLACE FUNCTION qstring (str_in IN VARCHAR2, qchar_in VARCHAR2 := '|')
   RETURN VARCHAR2
IS
-- Silly....
-- NOT a good use for encapsulation: still have to pass in the quote in the str_in!
--
   retval VARCHAR2(32767);
BEGIN
   EXECUTE IMMEDIATE 
      'BEGIN :var := q''' || qchar_in || str_in || qchar_in || '''; END;'
      USING OUT retval;
   RETURN retval;
END;
/



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/


