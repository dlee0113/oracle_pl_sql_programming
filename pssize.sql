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

