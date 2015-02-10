DROP TABLE error_table
/

CREATE TABLE error_table (error_number INTEGER, error_string VARCHAR2 (4000), string_language varchar2(100))
/

CREATE OR REPLACE PROCEDURE raise_by_language (code_in IN PLS_INTEGER)
IS
   l_message   error_table.error_string%TYPE;
BEGIN
   SELECT error_string
     INTO l_message
     FROM error_table
    WHERE error_number = code_in AND string_language = USERENV ('LANG');

   raise_application_error (code_in, l_message);
END;
/

/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/