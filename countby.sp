CREATE OR REPLACE PROCEDURE countby (
   tab       IN   VARCHAR2,
   col       IN   VARCHAR2,
   atleast   IN   INTEGER := NULL,
   sch       IN   VARCHAR2 := NULL,
   MAXLEN    IN   INTEGER := 30
)
IS 
   TYPE cv_type IS REF CURSOR;

   cv           cv_type;
   sql_string   VARCHAR2 (32767)
      :=    'SELECT '
         || col
         || ', COUNT(*) 
         FROM '
         || NVL (sch, USER)
         || '.'
         || tab
         || ' GROUP BY '
         || col;
   v_hdr        VARCHAR2 (100) := 'Count by ' || UPPER (tab) || '.' || UPPER (
                                                                          col
                                                                       );
   v_val        VARCHAR2 (32767);
   v_count      INTEGER;
BEGIN
   IF atleast IS NOT NULL
   THEN
      sql_string := sql_string || ' HAVING COUNT(*) >= ' || atleast;
      v_hdr := v_hdr || ' with at least ' || atleast || ' occurrences';
   END IF;

   OPEN cv FOR sql_string;

   LOOP
      FETCH cv INTO v_val, v_count;
      EXIT WHEN cv%NOTFOUND;

      IF cv%ROWCOUNT = 1
      THEN
         DBMS_OUTPUT.put_line (RPAD ('-', 70, '-'));
         DBMS_OUTPUT.put_line (v_hdr);
         DBMS_OUTPUT.put_line (RPAD ('-', 70, '-'));
      END IF;

      DBMS_OUTPUT.put_line (RPAD (v_val, MAXLEN) || ' ' || v_count);
   END LOOP;

   CLOSE cv;
END;
/

/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
