SET PAGESIZE 66
COLUMN name FORMAT A30
COLUMN type FORMAT A15
COLUMN source_size FORMAT 999999
COLUMN parsed_size FORMAT 999999
COLUMN code_size FORMAT 999999
TTITLE 'Size of PL/SQL Objects > &&1 KBytes'
SPOOL pssize.lis
SELECT name, type, source_size, parsed_size, code_size
  FROM user_object_size
 WHERE code_size > &&1 * 1000
 ORDER BY code_size DESC
/
SPOOL OFF
TTITLE OFF



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/


