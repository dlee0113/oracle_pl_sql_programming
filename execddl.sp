CREATE OR REPLACE PROCEDURE execDDL (ddl_string IN VARCHAR2)
   AUTHID CURRENT_USER IS
BEGIN
   EXECUTE IMMEDIATE ddl_string;
EXCEPTION
   WHEN OTHERS
   THEN
      -- Display or otherwise log the error and in particular
	  -- show what the SQL string that is causing the problem.
      DBMS_OUTPUT.PUT_LINE ('Dynamic SQL Failure: ' || SQLERRM);
      DBMS_OUTPUT.PUT_LINE (
         '   on statement: "' || ddl_string || '"');
     
	  -- Re-raise the exception to indicate there is a problem
	  RAISE;
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
