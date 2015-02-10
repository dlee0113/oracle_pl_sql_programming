REM Create a table to hold various kinds of messages.

DROP TABLE msg_info;

CREATE TABLE msg_info (
   msgcode PLS_INTEGER,
   msgtype VARCHAR2(30),
   msgtext VARCHAR2(2000),
   msgname VARCHAR2(30),
   description VARCHAR2(2000)
   );

CREATE OR REPLACE PACKAGE msginfo
IS
   -- Return the text (message) for a given code.
   -- Will "fall back" on SQLERRM if there is no message in the table
   -- for this code and type combination.
   FUNCTION text (
      code_in IN PLS_INTEGER
    , type_in IN VARCHAR2
    , use_sqlerrm IN BOOLEAN := TRUE
   )
      RETURN VARCHAR2;

   -- Return the identifier name for a given code-type combination.
   FUNCTION NAME (code_in IN PLS_INTEGER, type_in IN VARCHAR2)
      RETURN VARCHAR2;

   -- Generate a package containing the declarations of error numbers
   -- and exceptions for each of the -20,NNN exceptions defined in the
   -- msginfo table.
   PROCEDURE genpkg (
      NAME_IN IN VARCHAR2
    , oradev_use IN BOOLEAN := FALSE
    , to_file_in IN BOOLEAN := TRUE
    , dir_in IN VARCHAR2 := 'DEMO' -- Oracle9i R2 directory
    , ext_in IN VARCHAR2 := 'pkg'
   );
END;
/

CREATE OR REPLACE PACKAGE BODY msginfo
IS
   FUNCTION msgrow (code_in IN PLS_INTEGER, type_in IN VARCHAR2)
      RETURN msg_info%ROWTYPE
   IS
      CURSOR msg_cur
      IS
         SELECT *
           FROM msg_info
          WHERE msgtype = type_in AND msgcode = code_in;

      msg_rec   msg_info%ROWTYPE;
   BEGIN
      OPEN msg_cur;
      FETCH msg_cur INTO msg_rec;
      CLOSE msg_cur;
      RETURN msg_rec;
   END;

   FUNCTION text (
      code_in IN PLS_INTEGER
    , type_in IN VARCHAR2
    , use_sqlerrm IN BOOLEAN := TRUE
   )
      RETURN VARCHAR2
   IS
      msg_rec   msg_info%ROWTYPE   := msgrow (code_in, type_in);
   BEGIN
      IF msg_rec.msgtext IS NULL AND use_sqlerrm
      THEN
         msg_rec.msgtext := SQLERRM (code_in);
      END IF;

      RETURN msg_rec.msgtext;
   END;

   FUNCTION NAME (code_in IN PLS_INTEGER, type_in IN VARCHAR2)
      RETURN VARCHAR2
   IS
      msg_rec   msg_info%ROWTYPE   := msgrow (code_in, type_in);
   BEGIN
      RETURN msg_rec.msgname;
   END;

   PROCEDURE genpkg (
      NAME_IN IN VARCHAR2
    , oradev_use IN BOOLEAN := FALSE
    , to_file_in IN BOOLEAN := TRUE
    , dir_in IN VARCHAR2 := 'DEMO'
    , ext_in IN VARCHAR2 := 'pkg'
   )
   IS
      CURSOR exc_20000
      IS
         SELECT *
           FROM msg_info
          WHERE msgcode BETWEEN -20999 AND -20000 AND msgtype = 'EXCEPTION';

      -- Send output to file or screen?
      v_to_screen   BOOLEAN         := NVL (NOT to_file_in, TRUE);
      v_file        VARCHAR2 (1000) := name_in || '.' || ext_in;

      -- Array of output for package
      TYPE lines_t IS TABLE OF VARCHAR2 (1000)
         INDEX BY BINARY_PLS_INTEGER;

      output        lines_t;

      -- Now pl simply writes to the array.
      PROCEDURE pl (str IN VARCHAR2)
      IS
      BEGIN
         output (NVL (output.LAST, 0) + 1) := str;
      END;

      -- Dump to screen or file.
      PROCEDURE dump_output
      IS
      BEGIN
         IF v_to_screen
         THEN
            FOR indx IN output.FIRST .. output.LAST
            LOOP
               DBMS_OUTPUT.put_line (output (indx));
            END LOOP;
         ELSE
            -- Send output to the specified file.
            DECLARE
               fid   UTL_FILE.file_type;
            BEGIN
               fid := UTL_FILE.fopen (dir_in, v_file, 'W');

               FOR indx IN output.FIRST .. output.LAST
               LOOP
                  UTL_FILE.put_line (fid, output (indx));
               END LOOP;

               UTL_FILE.fclose (fid);
            EXCEPTION
               WHEN OTHERS
               THEN
                  DBMS_OUTPUT.put_line (   'Failure to write output to '
                                        || dir_in
                                        || '/'
                                        || v_file
                                       );
                  UTL_FILE.fclose (fid);
            END;
         END IF;
      END dump_output;
   BEGIN
      /* Simple generator, based on DBMS_OUTPUT. */
      pl ('CREATE OR REPLACE PACKAGE ' || NAME_IN);
      pl ('IS ');

      FOR msg_rec IN exc_20000
      LOOP
         IF exc_20000%ROWCOUNT > 1
         THEN
            pl (' ');
         END IF;

         pl ('   exc_' || msg_rec.msgname || ' EXCEPTION;');
         pl (   '   en_'
             || msg_rec.msgname
             || ' CONSTANT PLS_INTEGER := '
             || msg_rec.msgcode
             || ';'
            );
         pl (   '   PRAGMA EXCEPTION_INIT (exc_'
             || msg_rec.msgname
             || ', '
             || msg_rec.msgcode
             || ');'
            );

         IF oradev_use
         THEN
            pl ('   FUNCTION ' || msg_rec.msgname || ' RETURN PLS_INTEGER;');
         END IF;
      END LOOP;

      pl ('END ' || NAME_IN || ';');
      pl ('/');

      IF oradev_use
      THEN
         pl ('CREATE OR REPLACE PACKAGE BODY ' || NAME_IN);
         pl ('IS ');

         FOR msg_rec IN exc_20000
         LOOP
            pl ('   FUNCTION ' || msg_rec.msgname || ' RETURN PLS_INTEGER');
            pl ('   IS BEGIN RETURN en_' || msg_rec.msgname || '; END;');
            pl ('   ');
         END LOOP;

         pl ('END ' || NAME_IN || ';');
         pl ('/');
      END IF;

      dump_output;
   END;
END;
/

/* Sample data to be used in package generation. */

INSERT INTO msg_info
     VALUES (-20100, 'EXCEPTION', 'Balance too low', 'bal_too_low'
           , 'Description');
INSERT INTO msg_info
     VALUES (-20200, 'EXCEPTION', 'Employee too young', 'emp_too_young'
           , 'Description');

COMMIT ;

