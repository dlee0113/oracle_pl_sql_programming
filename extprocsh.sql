CREATE OR REPLACE LIBRARY extprocshell_lib AS 'c:\oracle\admin\local\lib\extprocsh.dll';
/

CREATE OR REPLACE PROCEDURE shell(cmd IN VARCHAR2)
AS
   LANGUAGE C
   LIBRARY extprocshell_lib
   NAME "extprocsh"
   WITH CONTEXT
   PARAMETERS (CONTEXT, cmd STRING, cmd INDICATOR);
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
