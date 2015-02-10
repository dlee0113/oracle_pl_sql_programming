CREATE OR REPLACE TRIGGER what_column
AFTER ALTER ON SCHEMA
DECLARE

  -- cursor to get columns in a table
  CURSOR curs_get_columns ( cp_owner VARCHAR2,
                            cp_table VARCHAR2 ) IS
  SELECT column_name
    FROM all_tab_columns
   WHERE owner = cp_owner
     AND table_name = cp_table;

BEGIN

  -- if it was a table that was altered...
  IF ORA_DICT_OBJ_TYPE = 'TABLE' THEN

    -- for every column in the table...
    FOR v_column_rec IN curs_get_columns(ORA_DICT_OBJ_OWNER,
                                         ORA_DICT_OBJ_NAME) LOOP

      -- if the current column was the one that was altered then say so
      IF ORA_IS_ALTER_COLUMN(v_column_rec.column_name) THEN

        DBMS_OUTPUT.PUT_LINE('Thank you for altering ' ||
                             ORA_DICT_OBJ_OWNER        || '.' ||
                             ORA_DICT_OBJ_NAME         || '.' ||
                             v_column_rec.column_name);

      END IF;  -- current column was altered

    END LOOP;  -- every column in the table

  END IF;  -- table was altered

END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
