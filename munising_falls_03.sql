DECLARE
   tannery_falls_directions BFILE
         := BFILENAME ('BFILE_DATA', 'TanneryFalls.directions');
   directions           CLOB;
   destination_offset   INTEGER := 1;
   source_offset        INTEGER := 1;
   language_context     INTEGER := DBMS_LOB.default_lang_ctx;
   warning_message      INTEGER;
BEGIN
   --Delete row for Tannery Falls, so this example
   --can run multiple times.
   DELETE FROM waterfalls
         WHERE falls_name = 'Tannery Falls';

   --Insert a new row using EMPTY_CLOB() to create a LOB locator
   INSERT INTO waterfalls (falls_name, falls_directions
                          )
       VALUES ('Tannery Falls', EMPTY_CLOB ()
              );

   --Retrieve the LOB locator created by the previous INSERT statement
   SELECT falls_directions
     INTO directions
     FROM waterfalls
    WHERE falls_name = 'Tannery Falls';

   --Open the target CLOB and the source BFILE
   DBMS_LOB.open (directions, DBMS_LOB.lob_readwrite);
   DBMS_LOB.open (tannery_falls_directions);

   --Load the contents of the BFILE into the CLOB column
   DBMS_LOB.loadclobfromfile (directions
                            , tannery_falls_directions
                            , DBMS_LOB.lobmaxsize
                            , destination_offset
                            , source_offset
                            , NLS_CHARSET_ID ('US7ASCII')
                            , language_context
                            , warning_message
                             );

   --Check for the only possible warning message.
   IF warning_message = DBMS_LOB.warn_inconvertible_char
   THEN
      DBMS_OUTPUT.put_line (
         'Warning! Some characters couldn''t be converted.'
      );
   END IF;

   --Close both LOBs
   DBMS_LOB.close (directions);
   DBMS_LOB.close (tannery_falls_directions);
END;
/
