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
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
