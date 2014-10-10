CREATE OR REPLACE PROCEDURE long_compilation
IS
BEGIN
$IF $$plsql_optimize_level != 1
$THEN
   $error 'This program must be compiled with optimization level = 1' $end
$END
   NULL;
END long_compilation;
/


/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/