CREATE OR REPLACE PROCEDURE send_clob_thru_email (
   sender    IN VARCHAR2
 , recipient IN VARCHAR2
 , subject   IN VARCHAR2 DEFAULT NULL
 , MESSAGE   IN CLOB
 , mailhost  IN VARCHAR2 DEFAULT 'mailhost'
)
IS
   mail_conn         UTL_SMTP.connection;
   crlf              CONSTANT VARCHAR2 (2) := CHR (13) || CHR (10);
   smtp_tcpip_port   CONSTANT PLS_INTEGER := 25;
   pos               PLS_INTEGER := 1;
   bytes_o_data      CONSTANT PLS_INTEGER := 32767;
   offset            PLS_INTEGER := bytes_o_data;
   msg_length        CONSTANT PLS_INTEGER := DBMS_LOB.getlength (MESSAGE);
BEGIN
   mail_conn := UTL_SMTP.open_connection (mailhost, smtp_tcpip_port);
   UTL_SMTP.helo (mail_conn, mailhost);
   UTL_SMTP.mail (mail_conn, sender);
   UTL_SMTP.rcpt (mail_conn, recipient);

   UTL_SMTP.open_data (mail_conn);
   UTL_SMTP.write_data (
      mail_conn
    ,    'Date: '
      || TO_CHAR (SYSTIMESTAMP, 'Dy, dd Mon YYYY HH24:MI:SS TZHTZM')
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
   );

   WHILE pos < msg_length
   LOOP
      UTL_SMTP.write_data (mail_conn, DBMS_LOB.SUBSTR (MESSAGE, offset, pos));
      pos := pos + offset;
      offset := LEAST (bytes_o_data, msg_length - offset);
   END LOOP;

   UTL_SMTP.close_data (mail_conn);

   UTL_SMTP.quit (mail_conn);
END send_clob_thru_email;
/
