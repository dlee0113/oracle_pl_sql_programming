CREATE OR REPLACE TRIGGER after_suspend
AFTER SUSPEND
ON SCHEMA
DECLARE
  CURSOR curs_get_extents IS
  SELECT max_extents + 1
    FROM user_tables
   WHERE table_name = 'MONTHLY_SUMMARY';
  v_new_max NUMBER;
BEGIN
  OPEN curs_get_extents;
  FETCH curs_get_extents INTO v_new_max;
  CLOSE curs_get_extents;
  EXECUTE IMMEDIATE 'ALTER TABLE MONTHLY_SUMMARY ' ||
                    'STORAGE ( MAXEXTENTS '        ||
                    v_new_max                      || ')';
  DBMS_OUTPUT.PUT_LINE('Incremented MAXEXTENTS to ' || v_new_max);
END;
/
SHO ERR


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
