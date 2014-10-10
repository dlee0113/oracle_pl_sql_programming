CREATE OR REPLACE TRIGGER no_create
AFTER DDL ON SCHEMA
BEGIN
  IF ORA_SYSEVENT = 'CREATE' THEN
    RAISE_APPLICATION_ERROR(-20000,'Cannot create the ' || ORA_DICT_OBJ_TYPE ||
                                   ' named '            || ORA_DICT_OBJ_NAME ||
                                   ' as requested by '  || ORA_DICT_OBJ_OWNER);
  END IF;
END;
/




/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/

