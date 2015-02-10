COLUMN object_name FORMAT A30
SELECT object_name, object_type, status, timestamp
  FROM user_objects
 WHERE (object_name NOT LIKE 'SYS_%'
         AND object_name NOT LIKE 'CREATE$%'
         AND object_name NOT LIKE 'JAVA$%'
         AND object_name NOT LIKE 'LOADLOB%')
   AND object_type LIKE 'JAVA %'
 ORDER BY object_type, object_name;


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
