CREATE OR REPLACE TRIGGER preserve_app_cols
   AFTER ALTER ON SCHEMA
DECLARE
   -- cursor to get columns in a table
   CURSOR curs_get_columns (cp_owner VARCHAR2, cp_table VARCHAR2)
   IS
      SELECT column_name
        FROM all_tab_columns
       WHERE owner = cp_owner AND table_name = cp_table;
BEGIN
   -- if it was a table that was altered...
   IF ora_dict_obj_type = 'TABLE'
   THEN
      -- for every column in the table...
      FOR v_column_rec IN curs_get_columns (
                             ora_dict_obj_owner,
                             ora_dict_obj_name
                          )
      LOOP
         -- if the current column was the one that was altered then say so
         IF ora_is_alter_column (v_column_rec.column_name)
         THEN
            -- if the table/column is core…
            IF is_application_column (
                  ora_dict_obj_owner,
                  ora_dict_obj_name,
                  v_column_rec.column_name
               )
            THEN
               RAISE_APPLICATION_ERROR (
                  -20001,
                  'Cannot alter core application attributes'
               );
            END IF; -- table/column is core
         END IF; -- current column was altered
      END LOOP; -- every column in the table
   END IF; -- table was altered
END;


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
