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



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/

