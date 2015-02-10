SELECT object_name shortname,
       DBMS_JAVA.LONGNAME (object_name) longname
  FROM USER_OBJECTS 
  WHERE object_type = 'JAVA CLASS'
    AND object_name != DBMS_JAVA.LONGNAME (object_name);


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
