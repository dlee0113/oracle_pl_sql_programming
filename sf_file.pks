CREATE OR REPLACE PACKAGE sf_file
/*
|| sf_file: Xtra FILE access from PL/SQL
||
|| More complete file management capabilities for PL/SQL
||
|| You can install this package and then do a global search
|| and replace of "UTL_FILE" to "sf_file", and then switch
|| over to sf_file for all future file IO activities in PL/SQL.
||
|| Author: Steven Feuerstein
||
|| Modification History:
||   Date        Who         What
|| Oct 3 2007    SF          Add file_type record type to provide full
||                           compatibility with UTL_FILE.
|| Feb 26 1999   SF          Create package.
*/
IS
   c_dirdelim   CONSTANT CHAR (1) := '|';

   SUBTYPE maxvc2 IS VARCHAR2 (32767);

   -- List of file names
   TYPE list_aat IS TABLE OF maxvc2
      INDEX BY BINARY_INTEGER;

   /* Record that mimics UTL_FILE file handle record.
      WARNING! Must check each new version of Oracle
      to keep this in synch.
   */
   TYPE file_type IS RECORD (
      ID          BINARY_INTEGER
    , datatype    BINARY_INTEGER
    , byte_mode   BOOLEAN
   );

   /* Status of file */
   FUNCTION canread (FILE IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION canwrite (FILE IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION EXISTS (FILE IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION isdirectory (FILE IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION isfile (FILE IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION separator (FILE IN VARCHAR2)
      RETURN VARCHAR2;

   /* Information about file */
   FUNCTION LENGTH (FILE IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION parentdir (FILE IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION pathname (FILE IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION lastmodified (FILE IN VARCHAR2)
      RETURN NUMBER;

   /* Not a date; only useful for comparisions. */
   FUNCTION dircontents (dir IN VARCHAR2, delim IN VARCHAR2)
      RETURN VARCHAR2;

   PROCEDURE getdircontents (
      dir IN VARCHAR2
    , files IN OUT VARCHAR2
    , delim IN VARCHAR2 := c_dirdelim
   );

   PROCEDURE getdircontents (
      dir IN VARCHAR2
    , files IN OUT list_aat
    , delim IN VARCHAR2 := c_dirdelim
   );

   PROCEDURE getdircontents (
      dir IN VARCHAR2
    , filter IN VARCHAR2
    , files IN OUT list_aat
    , match_case IN BOOLEAN := TRUE
    , delim IN VARCHAR2 := c_dirdelim
   );

   PROCEDURE showdircontents (
      dir IN VARCHAR2
    , filter IN VARCHAR2
    , match_case IN BOOLEAN := TRUE
    , delim IN VARCHAR2 := c_dirdelim
   );

   FUNCTION DELETE (FILE IN VARCHAR2)
      RETURN BOOLEAN;

   PROCEDURE DELETE (
      dir IN VARCHAR2
    , FILE IN VARCHAR2 := NULL
    , match_case IN BOOLEAN := TRUE
    , show_deletes IN BOOLEAN := FALSE
   );

   FUNCTION mkdir (dir IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION RENAME (
      oldfile IN VARCHAR2
    , newfile IN VARCHAR2
    , showme IN BOOLEAN := FALSE
   )
      RETURN BOOLEAN;

   PROCEDURE chgext (
      dir IN VARCHAR2
    , oldext IN VARCHAR2
    , newext IN VARCHAR2
    , filter IN VARCHAR2 := '%'
    , showonly IN BOOLEAN := FALSE
   );

   /* UTL_FILE compatibility operations */
   FUNCTION fopen (
      LOCATION IN VARCHAR2
    , filename IN VARCHAR2
    , open_mode IN VARCHAR2
   )
      RETURN file_type;

   FUNCTION fopen (
      LOCATION IN VARCHAR2
    , filename IN VARCHAR2
    , open_mode IN VARCHAR2
    , max_linesize IN BINARY_INTEGER
   )
      RETURN file_type;

   PROCEDURE fclose (FILE IN OUT file_type);

   PROCEDURE fclose_all;

   PROCEDURE fflush (FILE IN file_type);

   PROCEDURE get_line (FILE IN file_type, buffer OUT VARCHAR2);

   PROCEDURE get_line (FILE IN file_type, buffer OUT VARCHAR2, eof OUT BOOLEAN);

   PROCEDURE put (FILE IN file_type, buffer IN VARCHAR2);

   PROCEDURE new_line (FILE IN file_type, lines IN NATURAL := 1);

   PROCEDURE put_line (FILE IN file_type, buffer IN VARCHAR2);

   PROCEDURE putf (
      FILE IN file_type
    , format IN VARCHAR2
    , arg1 IN VARCHAR2 DEFAULT NULL
    , arg2 IN VARCHAR2 DEFAULT NULL
    , arg3 IN VARCHAR2 DEFAULT NULL
    , arg4 IN VARCHAR2 DEFAULT NULL
    , arg5 IN VARCHAR2 DEFAULT NULL
   );

   FUNCTION loblength (dir IN VARCHAR2, FILE IN VARCHAR2)
      RETURN NUMBER;
END;
/

