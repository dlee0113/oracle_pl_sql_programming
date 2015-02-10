CREATE OR REPLACE PROCEDURE obfuscate_from_file (
   dir_in    IN   VARCHAR2
 , file_in   IN   VARCHAR2
)
IS
   l_file    UTL_FILE.file_type;
   l_lines   DBMS_SQL.varchar2s;

   PROCEDURE read_file (lines_out IN OUT NOCOPY DBMS_SQL.varchar2s)
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
   DBMS_DDL.create_wrapped (l_lines
                 , l_lines.FIRST
                 , l_lines.LAST
                  );
END obfuscate_from_file;
/
