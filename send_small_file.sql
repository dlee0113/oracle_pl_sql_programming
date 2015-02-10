CREATE OR REPLACE DIRECTORY tmpdir AS '/tmp';
/ 
DECLARE
   the_file BFILE := BFILENAME('TMPDIR', 'hugo.txt.gz');
   rawbuf RAW(32767);
   amt PLS_INTEGER :=  32767;
   offset PLS_INTEGER := 1;
BEGIN
   DBMS_LOB.fileopen(the_file, DBMS_LOB.file_readonly);
   DBMS_LOB.read(the_file, amt, offset, rawbuf);
   UTL_MAIL.send_attach_raw 
(
      sender => 'my@myname.com'
     ,recipients => 'you@yourname.com'
     ,subject => 'Attachment demo'
     ,message => 'Dear Scott...'
     ,att_mime_type => 'application/x-gzip'
     ,attachment => rawbuf
     ,att_inline => TRUE
     ,att_filename => 'hugo.txt.gz'
   );
 
   DBMS_LOB.close(the_file);
END;
