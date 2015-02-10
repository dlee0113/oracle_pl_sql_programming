/* Formatted by PL/Formatter v3.0.5.0 on 2000/06/29 07:04 */

CREATE OR REPLACE PROCEDURE gentrigrec (
   table_in IN VARCHAR2,
   owner_in IN VARCHAR2 := USER
)
IS
   CURSOR col_cur
   IS
      SELECT LOWER (column_name) column_name
        FROM all_tab_columns
       WHERE owner = UPPER (owner_in)
         AND table_name = UPPER (table_in);
BEGIN
   DBMS_OUTPUT.put_line (
      '   myNew ' || table_in || '%ROWTYPE;'
   );
   DBMS_OUTPUT.put_line (
      '   myOld ' || table_in || '%ROWTYPE;'
   );
   DBMS_OUTPUT.put_line ('BEGIN');
   DBMS_OUTPUT.put_line (
      '   -- Transfer NEW to local record.'
   );

   FOR rec IN col_cur
   LOOP
      DBMS_OUTPUT.put_line (
         '   myNew.' || rec.column_name || ' := ' || ':NEW.' ||
            rec.column_name ||
            ';'
      );
   END LOOP;

   DBMS_OUTPUT.put_line (' ');
   DBMS_OUTPUT.put_line (
      '   -- Transfer NEW to local record.'
   );

   FOR rec IN col_cur
   LOOP
      DBMS_OUTPUT.put_line (
         '   myOld.' || rec.column_name || ' := ' || ':OLD.' ||
            rec.column_name ||
            ';'
      );
   END LOOP;
END;
/




/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
