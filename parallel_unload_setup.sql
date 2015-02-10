
CREATE DIRECTORY dir AS 'D:\oracle\dir';

CREATE TYPE unload_ot AS OBJECT
( file_name  VARCHAR2(128)
, no_records NUMBER
, session_id NUMBER );
/

CREATE TYPE unload_ntt AS TABLE OF unload_ot;
/

CREATE PACKAGE unload_pkg AS

   c_default_limit CONSTANT PLS_INTEGER := 100;

   PROCEDURE legacy_unload( p_source     IN SYS_REFCURSOR,
                            p_filename   IN VARCHAR2,
                            p_directory  IN VARCHAR2,
                            p_limit_size IN PLS_INTEGER DEFAULT unload_pkg.c_default_limit );

   FUNCTION parallel_unload( p_source     IN SYS_REFCURSOR,
                             p_filename   IN VARCHAR2,
                             p_directory  IN VARCHAR2,
                             p_limit_size IN PLS_INTEGER DEFAULT unload_pkg.c_default_limit )
      RETURN unload_ntt 
      PIPELINED PARALLEL_ENABLE (PARTITION p_source BY ANY);

   FUNCTION parallel_unload_buffered( p_source     IN SYS_REFCURSOR,
                                      p_filename   IN VARCHAR2,
                                      p_directory  IN VARCHAR2,
                                      p_limit_size IN PLS_INTEGER DEFAULT unload_pkg.c_default_limit )
      RETURN unload_ntt 
      PIPELINED PARALLEL_ENABLE (PARTITION p_source BY ANY);

END unload_pkg;
/

CREATE PACKAGE BODY unload_pkg AS

   SUBTYPE st_maxline IS VARCHAR2(32767);
   c_maxline CONSTANT PLS_INTEGER := 32767;

   TYPE row_aat IS TABLE OF st_maxline
      INDEX BY PLS_INTEGER;

   PROCEDURE legacy_unload( p_source     IN SYS_REFCURSOR,
                            p_filename   IN VARCHAR2,
                            p_directory  IN VARCHAR2,
                            p_limit_size IN PLS_INTEGER DEFAULT unload_pkg.c_default_limit ) IS

      aa_rows row_aat;
      v_name  VARCHAR2(128) := p_filename || '.txt';
      v_file  UTL_FILE.FILE_TYPE;

   BEGIN

      v_file := UTL_FILE.FOPEN( p_directory, v_name, 'w', c_maxline );

      LOOP
         FETCH p_source BULK COLLECT INTO aa_rows LIMIT p_limit_size;
         EXIT WHEN aa_rows.COUNT = 0;
         FOR i IN 1 .. aa_rows.COUNT LOOP
            UTL_FILE.PUT_LINE(v_file, aa_rows(i));
         END LOOP;
      END LOOP;

      DBMS_OUTPUT.PUT_LINE(p_source%ROWCOUNT || ' rows unloaded');

      CLOSE p_source;
      UTL_FILE.FCLOSE(v_file);

   END legacy_unload;
      
   FUNCTION parallel_unload( p_source     IN SYS_REFCURSOR,
                             p_filename   IN VARCHAR2,
                             p_directory  IN VARCHAR2,
                             p_limit_size IN PLS_INTEGER DEFAULT unload_pkg.c_default_limit )
      RETURN unload_ntt 
      PIPELINED PARALLEL_ENABLE (PARTITION p_source BY ANY) AS

      aa_rows row_aat;
      v_sid   NUMBER := SYS_CONTEXT('USERENV','SID');
      v_name  VARCHAR2(128) := p_filename || '_' || v_sid || '.txt';
      v_file  UTL_FILE.FILE_TYPE;
      v_lines PLS_INTEGER;

   BEGIN

      v_file := UTL_FILE.FOPEN(p_directory, v_name, 'w', c_maxline);

      LOOP
         FETCH p_source BULK COLLECT INTO aa_rows LIMIT p_limit_size;
         EXIT WHEN aa_rows.COUNT = 0;
         FOR i IN 1 .. aa_rows.COUNT LOOP
            UTL_FILE.PUT_LINE(v_file, aa_rows(i));
         END LOOP;
      END LOOP;

      v_lines := p_source%ROWCOUNT;

      CLOSE p_source;
      UTL_FILE.FCLOSE(v_file);

      PIPE ROW (unload_ot(v_name, v_lines, v_sid));
      RETURN;

   END parallel_unload;

   FUNCTION parallel_unload_buffered( p_source    IN SYS_REFCURSOR,
                                      p_filename  IN VARCHAR2,
                                      p_directory IN VARCHAR2,
                                      p_limit_size IN PLS_INTEGER DEFAULT unload_pkg.c_default_limit )
      RETURN unload_ntt 
      PIPELINED PARALLEL_ENABLE (PARTITION p_source BY ANY) AS

      c_eol     CONSTANT VARCHAR2(1) := CHR(10);
      aa_rows   row_aat;
      v_buffer  VARCHAR2(32767);
      v_sid     NUMBER := SYS_CONTEXT('USERENV','SID');
      v_name    VARCHAR2(128) := p_filename || '_' || v_sid || '.txt';
      v_file    UTL_FILE.FILE_TYPE;
      v_lines   PLS_INTEGER;

   BEGIN

      v_file := UTL_FILE.FOPEN(p_directory, v_name, 'w', c_maxline);

      LOOP
         FETCH p_source BULK COLLECT INTO aa_rows LIMIT p_limit_size;
         FOR i IN 1 .. aa_rows.COUNT LOOP
            IF LENGTH(v_buffer) + 1 + LENGTH(aa_rows(i)) <= c_maxline THEN
               v_buffer := v_buffer || c_eol || aa_rows(i);
            ELSE
               IF v_buffer IS NOT NULL THEN
                  UTL_FILE.PUT_LINE(v_file, v_buffer);
               END IF;
               v_buffer := aa_rows(i);
            END IF;
         END LOOP;
         EXIT WHEN p_source%NOTFOUND;
      END LOOP;

      UTL_FILE.PUT_LINE(v_file, v_buffer);

      v_lines := p_source%ROWCOUNT;

      CLOSE p_source;
      UTL_FILE.FCLOSE(v_file);

      PIPE ROW (unload_ot(v_name, v_lines, v_sid));
      RETURN;

   END parallel_unload_buffered;

END unload_pkg;
/

