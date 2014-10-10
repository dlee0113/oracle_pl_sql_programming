CREATE OR REPLACE PROCEDURE check_expressions
IS
BEGIN
-- =, !=, OR works fine.
$IF $$plsql_optimize_level != 1 OR $$plsql_optimize_level = 2
$THEN
   -- Placeholder 
$END
   NULL;
END check_expressions;
/
CREATE OR REPLACE PROCEDURE check_expressions
IS
BEGIN
-- >, <=, AND ok.
$IF $$plsql_optimize_level > 1 AND $$plsql_optimize_level <= 5 
$THEN
   -- Placeholder 
$END
   NULL;
END check_expressions;
/
CREATE OR REPLACE PROCEDURE check_expressions
IS
BEGIN
-- <> OK
$IF $$plsql_optimize_level <> 1  
$THEN
   -- Placeholder 
$END
   NULL;
END check_expressions;
/
CREATE OR REPLACE PROCEDURE check_expressions
IS
BEGIN
-- IS NULL and IS NOT NULL are OK
$IF $$plsql_optimize_level IS NULL OR $$plsql_optimize_level IS NOT NULL 
$THEN
   -- Placeholder 
$END
   NULL;
END check_expressions;
/


/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/