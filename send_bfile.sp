CREATE OR REPLACE PROCEDURE send_bfile (
   sender IN VARCHAR2
 , recipient IN VARCHAR2
 , subject IN VARCHAR2 DEFAULT NULL
 , MESSAGE IN VARCHAR2 DEFAULT NULL
 , att_bfile IN OUT BFILE
 , att_mime_type IN VARCHAR2
 , mailhost IN VARCHAR2 DEFAULT 'mailhost'
)
IS
   crlf                     CONSTANT VARCHAR2 (2) := CHR (13) || CHR (10);
   smtp_tcpip_port          CONSTANT PLS_INTEGER := 25;
   bytes_per_read           CONSTANT PLS_INTEGER := 23829;
   boundary CONSTANT VARCHAR2 (78)
         := '-------5e9i1BxFQrgl9cOgs90-------' ;
   encapsulation_boundary   CONSTANT VARCHAR2 (78) := '--' || boundary;
   final_boundary CONSTANT VARCHAR2 (78)
         := '--' || boundary || '--' ;

   mail_conn                UTL_SMTP.connection;
   pos                      PLS_INTEGER := 1;
   file_length              PLS_INTEGER;

   diralias                 VARCHAR2 (30);
   bfile_filename           VARCHAR2 (512);
   lines_in_bigbuf          PLS_INTEGER := 0;


   PROCEDURE writedata (str IN VARCHAR2, crlfs IN PLS_INTEGER DEFAULT 1)
   IS
   BEGIN
      UTL_SMTP.write_data (mail_conn, str || RPAD (crlf, 2 * crlfs, crlf));
   END;
BEGIN
   DBMS_LOB.fileopen (att_bfile, DBMS_LOB.lob_readonly);
   file_length := DBMS_LOB.getlength (att_bfile);

   mail_conn := UTL_SMTP.open_connection (mailhost, smtp_tcpip_port);
   UTL_SMTP.helo (mail_conn, mailhost);
   UTL_SMTP.mail (mail_conn, sender);
   UTL_SMTP.rcpt (mail_conn, recipient);

   UTL_SMTP.open_data (mail_conn);
   writedata (
         'Date: '
      || TO_CHAR (SYSTIMESTAMP, 'Dy, dd Mon YYYY HH24:MI:SS TZHTZM')
      || crlf
      || 'MIME-Version: 1.0'
      || crlf
      || 'From: '
      || sender
      || crlf
      || 'Subject: '
      || subject
      || crlf
      || 'To: '
      || recipient
      || crlf
      || 'Content-Type: multipart/mixed; boundary="'
      || boundary
      || '"'
    , 2
   );

   writedata (encapsulation_boundary);
   writedata ('Content-Type: text/plain; charset=ISO-8859-1; format=flowed');
   writedata ('Content-Transfer-Encoding: 7bit', 2);
   writedata (MESSAGE, 2);

   DBMS_LOB.filegetname (att_bfile, diralias, bfile_filename);
   writedata (encapsulation_boundary);
   writedata(   'Content-Type: '
             || att_mime_type
             || '; name="'
             || bfile_filename
             || '"');
   writedata ('Content-Transfer-Encoding: base64');
   writedata (
      'Content-Disposition: attachment; filename="' || bfile_filename || '"'
    , 2
   );

   WHILE pos < file_length
   LOOP
      writedata (
         UTL_RAW.cast_to_varchar2(UTL_ENCODE.base64_encode(DBMS_LOB.SUBSTR (
                                                              att_bfile
                                                            , bytes_per_read
                                                            , pos
                                                           )))
       , 0
      );
      pos := pos + bytes_per_read;
   END LOOP;

   writedata (crlf || crlf || final_boundary);

   UTL_SMTP.close_data (mail_conn);
   UTL_SMTP.quit (mail_conn);
   DBMS_LOB.close (att_bfile);
END;
/