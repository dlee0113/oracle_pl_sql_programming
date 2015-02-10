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