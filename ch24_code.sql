/*
Oracle PL/SQL Programming 5th Edition

www.stevenfeuerstein.com/books

Objection creation and example scripts for Chapter 24

You will find below all non-trivial code snippets from the above chapter
that are NOT contained in their own files (as specified in the chapter),
plus any DDL object creation scripts required to get a clean compile
on the snippets.

Any references to Oracle's standard HR tables (employees, departments,
locations, regions, etc.) will NOT include the DDL creation scripts
in this file. Instead, run the hr_schema_install.sql script and all
those tables and related elements will be defined.
*/

BEGIN
   $IF $$plsql_optimize_level = 2 AND appdef_pkg.long_compilation
   $THEN
      $ERROR 'Do not use optimization level 2 for this program!' $END
   $END
   NULL;
END;
/

CREATE OR REPLACE PROCEDURE calc_totals
IS
BEGIN
   $IF cc_debug.debug_active AND cc_debug.trace_level > 5
   $THEN
      log_info ();
   $END
   NULL;
END calc_totals;
/

SELECT name, plsql_ccflags
  FROM user_plsql_object_settings
 WHERE name LIKE '%CCFLAGS%'
/

DECLARE
   l_postproc_code   DBMS_PREPROCESSOR.source_lines_t;
   l_row             PLS_INTEGER;
BEGIN
   l_postproc_code :=
      DBMS_PREPROCESSOR.get_post_processed_source ('PROCEDURE'
                                                 , USER
                                                 , 'POST_PROCESSED'
                                                  );
   l_row := l_postproc_code.FIRST;

   WHILE (l_row IS NOT NULL)
   LOOP
      DBMS_OUTPUT.put_line(   LPAD (l_row, 3)
                           || ' - '
                           || RTRIM (l_postproc_code (l_row), CHR (10)));
      l_row := l_postproc_code.NEXT (l_row);
   END LOOP;
END;
/

DROP TABLE books
/

CREATE TABLE books (author VARCHAR2 (100), title VARCHAR2 (100))
/

CREATE OR REPLACE FUNCTION plsql_bookcount (author_in IN VARCHAR2)
   RETURN NUMBER
IS
   l_titlepattern   VARCHAR2 (10) := '%PL/SQL%';
   l_count          NUMBER;
BEGIN
   SELECT COUNT ( * )
     INTO l_count
     FROM books
    WHERE title LIKE l_titlepattern AND author = plsql_bookcount.author;

   RETURN lcount;
END;
/

COLUMN SQL_TEXT FORMAT A50 WORD_WRAP

SELECT executions, sql_text
  FROM v$sqlarea
 WHERE sql_text LIKE 'SELECT COUNT(*) FROM BOOKS%'
/

CREATE OR REPLACE FUNCTION count_recent_records (tablename_in IN VARCHAR2
                                               , since_in     IN VARCHAR2
                                                )
   RETURN PLS_INTEGER
AS
   count_l   PLS_INTEGER;
BEGIN
   EXECUTE IMMEDIATE   'SELECT COUNT(*) FROM '
                    || DBMS_ASSERT.simple_sql_name (tablename_in)
                    || ' WHERE lastupdate > TO_DATE('
                    || DBMS_ASSERT.enquote_literal (since_in)
                    || ', ''YYYYMMDD'')'
      INTO count_l;

   RETURN count_l;
END;
/

CREATE OR REPLACE FUNCTION count_recent_records (tablename_in IN VARCHAR2
                                               , since_in     IN VARCHAR2
                                                )
   RETURN PLS_INTEGER
AS
   count_l   PLS_INTEGER;
BEGIN
   EXECUTE IMMEDIATE   'SELECT COUNT(*) FROM '
                    || DBMS_ASSERT.simple_sql_name (tablename_in)
                    || ' WHERE lastupdate > :thedate'
      INTO count_l
      USING TO_DATE (since_in, 'YYYYMMDD');

   RETURN count_l;
END;
/

SELECT n.name, ROUND (m.VALUE / 1024) kbytes
  FROM v$statname n, v$mystat m
 WHERE n.statistic# = m.statistic# AND n.name LIKE 'session%memory%'
/