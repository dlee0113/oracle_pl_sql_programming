DECLARE
   directions CLOB;
   amount BINARY_INTEGER;
   offset INTEGER;
   first_direction VARCHAR2(100);
   more_directions VARCHAR2(500);
BEGIN
   --Delete any existing rows for 'Munising Falls' so that this
   --example can be executed multiple times
   DELETE
     FROM waterfalls
    WHERE falls_name='Munising Falls';

   --Insert a new row using EMPTY_CLOB(  ) to create a LOB locator
   INSERT INTO waterfalls
             (falls_name,falls_directions)
      VALUES ('Munising Falls',EMPTY_CLOB(  ));

   --Retrieve the LOB locator created by the previous INSERT statement
   SELECT falls_directions
     INTO directions
     FROM waterfalls
    WHERE falls_name='Munising Falls';

   --Open the LOB; not strictly necessary, but best to open/close LOBs.
   DBMS_LOB.OPEN(directions, DBMS_LOB.LOB_READWRITE);

   --Use DBMS_LOB.WRITE to begin
   first_direction := 'Follow I-75 across the Mackinac Bridge.';
   amount := LENGTH(first_direction);  --number of characters to write
   offset := 1; --begin writing to the first character of the CLOB
   DBMS_LOB.WRITE(directions, amount, offset, first_direction);

   --Add some more directions using DBMS_LOB.WRITEAPPEND
   more_directions := ' Take US-2 west from St. Ignace to Blaney Park.'
                   || ' Turn north on M-77 and drive to Seney.'
                   || ' From Seney, take M-28 west to Munising.';
   DBMS_LOB.WRITEAPPEND(directions,
                        LENGTH(more_directions), more_directions);

   --Add yet more directions
   more_directions := ' In front of the paper mill, turn right on H-58.'
                   || ' Follow H-58 to Washington Street. Veer left onto'
                   || ' Washington Street. You''ll find the Munising'
                   || ' Falls visitor center across from the hospital at'
                   || ' the point where Washington Street becomes'
                   || ' Sand Point Road.';
   DBMS_LOB.WRITEAPPEND(directions,
                        LENGTH(more_directions), more_directions);

   --Close the LOB, and we are done.
   DBMS_LOB.CLOSE(directions);
END;

