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
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
