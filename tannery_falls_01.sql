DECLARE
   Tannery_Falls_Directions BFILE
      := BFILENAME('BFILE_DATA','TanneryFalls.directions');
   directions CLOB;
   destination_offset INTEGER := 1;
   source_offset INTEGER := 1;
   language_context INTEGER := DBMS_LOB.default_lang_ctx;
   warning_message INTEGER;
BEGIN
   --Delete row for Tannery Falls, so this example
   --can run multiple times.
   DELETE FROM waterfalls WHERE falls_name='Tannery Falls';

   --Insert a new row using EMPTY_CLOB(  ) to create a LOB locator
   INSERT INTO waterfalls
             (falls_name,falls_directions)
      VALUES ('Tannery Falls',EMPTY_CLOB(  ));

   --Retrieve the LOB locator created by the previous INSERT statement
   SELECT falls_directions
     INTO directions
     FROM waterfalls
    WHERE falls_name='Tannery Falls';

   --Open the target CLOB and the source BFILE
   DBMS_LOB.OPEN(directions, DBMS_LOB.LOB_READWRITE);
   DBMS_LOB.OPEN(Tannery_Falls_Directions);

   --Load the contents of the BFILE into the CLOB column
   DBMS_LOB.LOADCLOBFROMFILE(directions, Tannery_Falls_Directions,
                             DBMS_LOB.LOBMAXSIZE,
                             destination_offset, source_offset,
                             NLS_CHARSET_ID('US7ASCII'),
                             language_context, warning_message);

   --Check for the only possible warning message.
   IF warning_message = DBMS_LOB.WARN_INCONVERTIBLE_CHAR THEN
        dbms_output.put_line(
           'Warning! Some characters couldn''t be converted.');
   END IF;

   --Close both LOBs
   DBMS_LOB.CLOSE(directions);
   DBMS_LOB.CLOSE(Tannery_Falls_Directions);
END;

