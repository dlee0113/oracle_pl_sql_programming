SET PAGESIZE 66
COLUMN object_type FORMAT A20
COLUMN object_name FORMAT A30
COLUMN status FORMAT A10
BREAK ON object_type SKIP 1
SPOOL psobj.lis
SELECT   object_type, object_name, status
    FROM user_objects
   WHERE object_type IN ('PACKAGE',
                        'PACKAGE BODY',
                        'FUNCTION',
                        'PROCEDURE',
                        'TYPE',
                        'TYPE BODY',
						'TRIGGER'
                       )
ORDER BY object_type, status, object_name
/

SPOOL OFF


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
