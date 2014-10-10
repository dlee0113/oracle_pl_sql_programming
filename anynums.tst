@@wildside.sql
@@anynums.pkg

DECLARE
   mynums   anynums_pkg.numbers_t;
BEGIN
   mynums := anynums_pkg.getvals;
   DBMS_OUTPUT.PUT_LINE (mynums.count);
   mynums := anynums_pkg.getvals ('> 100');
   DBMS_OUTPUT.PUT_LINE (mynums.count);
END;
/




/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/

