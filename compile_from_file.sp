CREATE OR REPLACE PROCEDURE compile_from_file (dir_in IN VARCHAR2
                                             , file_in IN VARCHAR2
                                              )
IS
   l_file    UTL_FILE.file_type;
   l_lines   DBMS_SQL.varchar2s;
   l_cur     PLS_INTEGER := DBMS_SQL.open_cursor;

   PROCEDURE read_file (lines_out IN OUT DBMS_SQL.varchar2s)
   IS
   BEGIN
      l_file := UTL_FILE.fopen (dir_in, file_in, 'R');

      LOOP
         UTL_FILE.get_line (l_file, l_lines (lines_out.COUNT + 1));
      END LOOP;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         UTL_FILE.fclose (l_file);
   END read_file;
BEGIN
   read_file (l_lines);
   /* Parse all the lines in the array (going from FIRST to LAST) */
   DBMS_SQL.parse (l_cur
                 , l_lines
                 , l_lines.FIRST
                 , l_lines.LAST
                 , TRUE
                 , DBMS_SQL.native
                  );
   DBMS_SQL.close_cursor (l_cur);
END compile_from_file;
/
