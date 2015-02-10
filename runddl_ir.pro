CREATE OR REPLACE PROCEDURE runddl (ddl_in in VARCHAR2)
   AUTHID CURRENT_USER 
IS
BEGIN
   EXECUTE IMMEDIATE ddl_in;
END;
/



/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
