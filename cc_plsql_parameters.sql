CREATE OR REPLACE PROCEDURE show_parameters
IS
BEGIN
   IF $$PLSQL_DEBUG  THEN
      DBMS_OUTPUT.PUT_LINE ('DEBUG ON');
   ELSE
      DBMS_OUTPUT.PUT_LINE ('DEBUG OFF');
   END IF;
   DBMS_OUTPUT.PUT_LINE ($$PLSQL_OPTIMIZE_LEVEL);
   DBMS_OUTPUT.PUT_LINE ($$PLSQL_CODE_TYPE);
   DBMS_OUTPUT.PUT_LINE ($$PLSQL_WARNINGS);
   DBMS_OUTPUT.PUT_LINE ($$NLS_LENGTH_SEMANTICS);
END show_parameters;
/


/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/