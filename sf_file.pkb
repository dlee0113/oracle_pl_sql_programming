CREATE OR REPLACE PACKAGE BODY sf_file
IS
   /* Used to handle conversion from number to boolean. */
   g_true    INTEGER;
   g_false   INTEGER;

   FUNCTION tval
      RETURN NUMBER
   AS
      LANGUAGE JAVA
      NAME 'JFile.tVal () return int';

   FUNCTION fval
      RETURN NUMBER
   AS
      LANGUAGE JAVA
      NAME 'JFile.fVal () return int';

   FUNCTION separator (FILE IN VARCHAR2)
      RETURN VARCHAR2
   AS
      LANGUAGE JAVA
      NAME 'JFile.separator (java.lang.String) return java.lang.String';

   FUNCTION icanread (FILE IN VARCHAR2)
      RETURN NUMBER
   AS
      LANGUAGE JAVA
      NAME 'JFile.canRead (java.lang.String) return int';

   FUNCTION icanwrite (FILE IN VARCHAR2)
      RETURN NUMBER
   AS
      LANGUAGE JAVA
      NAME 'JFile.canWrite (java.lang.String) return int';

   FUNCTION iexists (FILE IN VARCHAR2)
      RETURN NUMBER
   AS
      LANGUAGE JAVA
      NAME 'JFile.exists (java.lang.String) return int';

   FUNCTION iisdirectory (FILE IN VARCHAR2)
      RETURN NUMBER
   AS
      LANGUAGE JAVA
      NAME 'JFile.isDirectory (java.lang.String) return int';

   FUNCTION iisfile (FILE IN VARCHAR2)
      RETURN NUMBER
   AS
      LANGUAGE JAVA
      NAME 'JFile.isFile (java.lang.String) return int';

---------------------
   FUNCTION canread (FILE IN VARCHAR2)
      RETURN BOOLEAN
   AS
   BEGIN
      RETURN icanread (FILE) = g_true;
   END;

   FUNCTION canwrite (FILE IN VARCHAR2)
      RETURN BOOLEAN
   AS
   BEGIN
      RETURN icanwrite (FILE) = g_true;
   END;

   FUNCTION EXISTS (FILE IN VARCHAR2)
      RETURN BOOLEAN
   AS
   BEGIN
      RETURN iexists (FILE) = g_true;
   END;

   FUNCTION isdirectory (FILE IN VARCHAR2)
      RETURN BOOLEAN
   AS
   BEGIN
      RETURN iisdirectory (FILE) = g_true;
   END;

   FUNCTION isfile (FILE IN VARCHAR2)
      RETURN BOOLEAN
   AS
   BEGIN
      RETURN iisfile (FILE) = g_true;
   END;

---------------------
   FUNCTION LENGTH (FILE IN VARCHAR2)
      RETURN NUMBER
   AS
      LANGUAGE JAVA
      NAME 'JFile.length (java.lang.String) return long';

   FUNCTION parentdir (FILE IN VARCHAR2)
      RETURN VARCHAR2
   AS
      LANGUAGE JAVA
      NAME 'JFile.parentDir (java.lang.String) return java.lang.String';

   FUNCTION pathname (FILE IN VARCHAR2)
      RETURN VARCHAR2
   AS
      LANGUAGE JAVA
      NAME 'JFile.pathName (java.lang.String) return java.lang.String';

   FUNCTION lastmodified (FILE IN VARCHAR2)
      RETURN NUMBER
   AS
      LANGUAGE JAVA
      NAME 'JFile.lastModified (java.lang.String) return long';

   FUNCTION dircontents (dir IN VARCHAR2, delim IN VARCHAR2)
      RETURN VARCHAR2
   AS
      LANGUAGE JAVA
      NAME 'JFile.dirContents (java.lang.String, java.lang.String) return java.lang.String';

   PROCEDURE getdircontents (
      dir IN VARCHAR2
    , files IN OUT VARCHAR2
    , delim IN VARCHAR2 := c_dirdelim
   )
   IS
   BEGIN
      files := dircontents (dir, delim);
   END;

   PROCEDURE list_to_coll (
      str IN VARCHAR2
    , list_inout IN OUT list_aat
    , delim IN VARCHAR2 DEFAULT ','
    , append_to_list_in IN BOOLEAN DEFAULT TRUE
   )
   IS
      v_loc        PLS_INTEGER;
      v_row        PLS_INTEGER;
      v_startloc   PLS_INTEGER := 1;
      v_item       maxvc2;
   BEGIN
      IF append_to_list_in
      THEN
         v_row := NVL (list_inout.LAST, 0) + 1;
      ELSE
         list_inout.DELETE;
         v_row := 1;
      END IF;

      IF str IS NOT NULL
      THEN
         LOOP
            v_loc := INSTR (str, delim, v_startloc);

            IF v_loc = v_startloc
            THEN
               v_item := NULL;
            ELSIF v_loc = 0
            THEN
               v_item := SUBSTR (str, v_startloc);
            ELSE
               v_item := SUBSTR (str, v_startloc, v_loc - v_startloc);
            END IF;

            list_inout (v_row) := v_item;

            IF v_loc = 0
            THEN
               EXIT;
            ELSE
               v_startloc := v_loc + 1;
               v_row := v_row + 1;
            END IF;
         END LOOP;
      END IF;
   END list_to_coll;

   PROCEDURE getdircontents (
      dir IN VARCHAR2
    , files IN OUT list_aat
    , delim IN VARCHAR2 := c_dirdelim
   )
   IS
      filenum   PLS_INTEGER;
   BEGIN
      list_to_coll (dir, files, delim, append_to_list_in => FALSE);
   END;

   PROCEDURE getdircontents (
      dir IN VARCHAR2
    , filter IN VARCHAR2
    , files IN OUT list_aat
    , match_case IN BOOLEAN := TRUE
    , delim IN VARCHAR2 := c_dirdelim
   )
   IS
      filenum   PLS_INTEGER;

      FUNCTION MATCHED (file1 IN VARCHAR2, file2 IN VARCHAR2)
         RETURN BOOLEAN
      IS
         retval   BOOLEAN := FALSE;
      BEGIN
         IF match_case
         THEN
            retval := file1 LIKE file2;
         ELSE
            retval := LOWER (file1) LIKE LOWER (file2);
         END IF;

         RETURN retval;
      END;
   BEGIN
      list_to_coll (dircontents (dir, delim)
                  , files
                  , delim
                  , append_to_list_in      => FALSE
                   );
      filenum := files.FIRST;

      LOOP
         EXIT WHEN filenum IS NULL;

         IF NOT MATCHED (files (filenum), filter)
         THEN
            files.DELETE (filenum);
         END IF;

         filenum := files.NEXT (filenum);
      END LOOP;
   END;

   PROCEDURE showdircontents (
      dir IN VARCHAR2
    , filter IN VARCHAR2
    , match_case IN BOOLEAN := TRUE
    , delim IN VARCHAR2 := c_dirdelim
   )
   IS
      filestab   list_aat;
      filenum    PLS_INTEGER;
   BEGIN
      getdircontents (dir, filter, filestab, match_case, delim);
      filenum := filestab.FIRST;

      LOOP
         EXIT WHEN filenum IS NULL;
         DBMS_OUTPUT.put_line (filestab (filenum));
         filenum := filestab.NEXT (filenum);
      END LOOP;
   END;

---------------------
   FUNCTION idelete (FILE IN VARCHAR2)
      RETURN NUMBER
   AS
      LANGUAGE JAVA
      NAME 'JFile.delete (java.lang.String) return int';

   FUNCTION DELETE (FILE IN VARCHAR2)
      RETURN BOOLEAN
   AS
   BEGIN
      RETURN idelete (FILE) = g_true;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line ('Error deleting: ' || SQLERRM);
         RETURN FALSE;
   END;

   PROCEDURE DELETE (
      dir IN VARCHAR2
    , FILE IN VARCHAR2 := NULL
    , match_case IN BOOLEAN := TRUE
    , show_deletes IN BOOLEAN := FALSE
   )
   IS
      filestab   list_aat;
      filenum    PLS_INTEGER;
      deleted    BOOLEAN;
      v_file     VARCHAR2 (2000);
   BEGIN
      getdircontents (dir, FILE, filestab);
      filenum := filestab.FIRST;

      LOOP
         EXIT WHEN filenum IS NULL;
         v_file := dir || separator (filestab (filenum))
                   || filestab (filenum);
         deleted := sf_file.DELETE (v_file);

         IF show_deletes AND deleted
         THEN
            DBMS_OUTPUT.put_line ('Deleted ' || v_file);
         ELSIF show_deletes AND NOT deleted
         THEN
            DBMS_OUTPUT.put_line ('Unable to delete ' || v_file);
         END IF;

         filenum := filestab.NEXT (filenum);
      END LOOP;
   END;

   FUNCTION imkdir (dir IN VARCHAR2)
      RETURN NUMBER
   AS
      LANGUAGE JAVA
      NAME 'JFile.mkdir (java.lang.String) return int';

   FUNCTION mkdir (dir IN VARCHAR2)
      RETURN BOOLEAN
   AS
   BEGIN
      RETURN imkdir (dir) = g_true;
   END;

   FUNCTION irename (oldfile IN VARCHAR2, newfile IN VARCHAR2)
      RETURN NUMBER
   AS
      LANGUAGE JAVA
      NAME 'JFile.rename (java.lang.String, java.lang.String) return int';

   FUNCTION RENAME (
      oldfile IN VARCHAR2
    , newfile IN VARCHAR2
    , showme IN BOOLEAN := FALSE
   )
      RETURN BOOLEAN
   AS
      v_bool   BOOLEAN := irename (oldfile, newfile) = g_true;
   BEGIN
      IF v_bool AND showme
      THEN
         DBMS_OUTPUT.put_line ('Renamed ' || oldfile || ' to ' || newfile);
      END IF;

      RETURN v_bool;
   END;

   PROCEDURE chgext (
      dir IN VARCHAR2
    , oldext IN VARCHAR2
    , newext IN VARCHAR2
    , filter IN VARCHAR2 := '%'
    , showonly IN BOOLEAN := FALSE
   )
   IS
      files     list_aat;
      filenum   PLS_INTEGER;
      newfile   VARCHAR2 (200);
      renamed   BOOLEAN;
   BEGIN
      sf_file.getdircontents (dir
                          , filter || '.' || oldext
                          , files
                          , match_case      => FALSE
                           );
      filenum := files.FIRST;

      LOOP
         EXIT WHEN filenum IS NULL;
         newfile :=
               dir
            || '\'
            || SUBSTR (files (filenum), 1, INSTR (files (filenum), '.'))
            || newext;

         IF showonly
         THEN
            DBMS_OUTPUT.put_line ('Change to ' || newfile);
         ELSE
            renamed := sf_file.RENAME (dir || '\' || files (filenum), newfile);
         END IF;

         filenum := files.NEXT (filenum);
      END LOOP;
   END;

   /*
      UTL_FILE compatibility operations.
   */
   FUNCTION to_sf_file_file_type (file_type_in IN UTL_FILE.file_type)
      RETURN file_type
   IS
      l_return   file_type;
   BEGIN
      l_return.ID := file_type_in.ID;
      l_return.datatype := file_type_in.datatype;
      l_return.byte_mode := file_type_in.byte_mode;
      RETURN l_return;
   END to_sf_file_file_type;

   FUNCTION to_utl_file_type (file_type_in IN file_type)
      RETURN UTL_FILE.file_type
   IS
      l_return   UTL_FILE.file_type;
   BEGIN
      l_return.ID := file_type_in.ID;
      l_return.datatype := file_type_in.datatype;
      l_return.byte_mode := file_type_in.byte_mode;
      RETURN l_return;
   END to_utl_file_type;

   FUNCTION fopen (
      LOCATION IN VARCHAR2
    , filename IN VARCHAR2
    , open_mode IN VARCHAR2
   )
      RETURN file_type
   IS
   BEGIN
      RETURN to_sf_file_file_type (UTL_FILE.fopen (LOCATION, filename
                                               , open_mode)
                                );
   END;

   FUNCTION fopen (
      LOCATION IN VARCHAR2
    , filename IN VARCHAR2
    , open_mode IN VARCHAR2
    , max_linesize IN BINARY_INTEGER
   )
      RETURN file_type
   IS
   BEGIN
      RETURN to_sf_file_file_type (UTL_FILE.fopen (LOCATION
                                               , filename
                                               , open_mode
                                               , max_linesize
                                                )
                                );
   END;

   PROCEDURE fclose (FILE IN OUT file_type)
   IS
      l_file   UTL_FILE.file_type := to_utl_file_type (FILE);
   BEGIN
      UTL_FILE.fclose (l_file);
      FILE := to_sf_file_file_type (l_file);
   END;

   PROCEDURE fclose_all
   IS
   BEGIN
      UTL_FILE.fclose_all;
   END;

   PROCEDURE fflush (FILE IN file_type)
   IS
   BEGIN
      UTL_FILE.fflush (to_utl_file_type (FILE));
   END;

   PROCEDURE get_line (FILE IN file_type, buffer OUT VARCHAR2)
   IS
   BEGIN
      UTL_FILE.get_line (to_utl_file_type (FILE), buffer);
   END;

   PROCEDURE get_line (FILE IN file_type, buffer OUT VARCHAR2, eof OUT BOOLEAN)
   IS
   BEGIN
      UTL_FILE.get_line (to_utl_file_type (FILE), buffer);
      eof := FALSE;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         buffer := NULL;
         eof := TRUE;
   END;

   PROCEDURE put (FILE IN file_type, buffer IN VARCHAR2)
   IS
   BEGIN
      UTL_FILE.put (to_utl_file_type (FILE), buffer);
   END;

   PROCEDURE new_line (FILE IN file_type, lines IN NATURAL := 1)
   IS
   BEGIN
      UTL_FILE.new_line (to_utl_file_type (FILE), lines);
   END;

   PROCEDURE put_line (FILE IN file_type, buffer IN VARCHAR2)
   IS
   BEGIN
      UTL_FILE.put_line (to_utl_file_type (FILE), buffer);
   END;

   PROCEDURE putf (
      FILE IN file_type
    , format IN VARCHAR2
    , arg1 IN VARCHAR2 DEFAULT NULL
    , arg2 IN VARCHAR2 DEFAULT NULL
    , arg3 IN VARCHAR2 DEFAULT NULL
    , arg4 IN VARCHAR2 DEFAULT NULL
    , arg5 IN VARCHAR2 DEFAULT NULL
   )
   IS
   BEGIN
      UTL_FILE.putf (to_utl_file_type (FILE)
                   , format
                   , arg1
                   , arg2
                   , arg3
                   , arg4
                   , arg5
                    );
   END;

   FUNCTION loblength (dir IN VARCHAR2, FILE IN VARCHAR2)
      RETURN NUMBER
   IS
      v_loc   BFILE := BFILENAME (dir, FILE);
   BEGIN
      RETURN DBMS_LOB.getlength (v_loc);
   END;
BEGIN
   g_true := tval;
   g_false := fval;
END;
/