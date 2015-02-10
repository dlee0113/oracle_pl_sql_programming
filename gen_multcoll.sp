CREATE OR REPLACE PROCEDURE gen_multcoll (
   LEVELS IN INTEGER,
   showit IN BOOLEAN := FALSE
)
IS
   lines DBMS_SQL.varchar2s;
   typestr VARCHAR2 (100) := 'VARCHAR2(100)';

   PROCEDURE exec_array (array_in IN DBMS_SQL.varchar2s)
   IS
      v_cur PLS_INTEGER := DBMS_SQL.open_cursor;
   BEGIN
      DBMS_SQL.parse (v_cur,
                      array_in,
                      array_in.FIRST,
                      array_in.LAST,
                      TRUE,
                      DBMS_SQL.native
                     );
      DBMS_SQL.close_cursor (v_cur);
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_SQL.close_cursor (v_cur);
         DBMS_OUTPUT.put_line ('EXEC_ARRAY Failure: ');
         DBMS_OUTPUT.put_line (SUBSTR (SQLERRM, 1, 255));
   END exec_array;

   PROCEDURE addline (line_in IN VARCHAR2)
   IS
   BEGIN
      lines (NVL (lines.LAST, 0) + 1) := line_in;

      IF showit
      THEN
         DBMS_OUTPUT.put_line (line_in);
      END IF;
   END;
BEGIN
   addline ('create or replace procedure multcoll_test is');

   FOR indx IN 1 .. LEVELS
   LOOP
      addline (   'type ibtab'
               || indx
               || ' is table of '
               || typestr
               || ' index by binary_integer;'
              );
      typestr := 'ibtab' || indx;
   END LOOP;

   addline ('mytab ibtab' || LEVELS || ';');
   addline ('begin');
   addline ('mytab');

   FOR indx IN 1 .. LEVELS
   LOOP
      addline ('(1)');
   END LOOP;

   addline (' := ''abc'';');
   addline ('dbms_output.put_line (mytab');

   FOR indx IN 1 .. LEVELS
   LOOP
      addline ('(1)');
   END LOOP;

   addline (');');
   addline ('end;');
   exec_array (lines);
   lines.DELETE;
   lines (1) := 'begin multcoll_test; end;';
   exec_array (lines);
END;
/