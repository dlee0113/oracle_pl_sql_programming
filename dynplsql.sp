CREATE OR REPLACE PROCEDURE dynPLSQL (blk IN VARCHAR2)
IS
BEGIN
   EXECUTE IMMEDIATE
      'BEGIN ' || RTRIM (blk, ';') || '; END;';
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
