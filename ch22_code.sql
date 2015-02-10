/*
Oracle PL/SQL Programming 5th Edition

www.stevenfeuerstein.com/books

Objection creation and example scripts for Chapter 22

You will find below all non-trivial code snippets from the above chapter
that are NOT contained in their own files (as specified in the chapter),
plus any DDL object creation scripts required to get a clean compile
on the snippets.

Any references to Oracle's standard HR tables (employees, departments,
locations, regions, etc.) will NOT include the DDL creation scripts
in this file. Instead, run the hr_schema_install.sql script and all
those tables and related elements will be defined.
*/

BEGIN
   DBMS_OUTPUT.put_line ('Steven');
   DBMS_OUTPUT.put_line (100);
   DBMS_OUTPUT.put_line (SYSDATE);
END;
/

CREATE OR REPLACE FUNCTION next_line
   RETURN VARCHAR2
IS
   return_value   VARCHAR2 (32767);
   status         INTEGER;
BEGIN
   DBMS_OUTPUT.get_line (return_value, status);

   IF status = 0
   THEN
      RETURN return_value;
   ELSE
      RETURN NULL;
   END IF;
END;
/

CREATE OR REPLACE PACKAGE accts_pkg
IS
   c_data_location   CONSTANT VARCHAR2 (30) := '/accts/data';
END accts_pkg;
/

DECLARE
   file_id   UTL_FILE.file_type;
BEGIN
   file_id := UTL_FILE.fopen (accts_pkg.c_data_location, 'trans.dat', 'R');
END;
/

CREATE OR REPLACE DIRECTORY development_dir AS '/dev/source';

/

CREATE OR REPLACE DIRECTORY test_dir AS '/test/source';

/

DECLARE
   config_file   UTL_FILE.file_type;
BEGIN
   config_file := UTL_FILE.fopen ('/maint/admin', 'config.txt', 'R');
END;
/

DECLARE
   config_file   UTL_FILE.file_type;
BEGIN
   config_file :=
      UTL_FILE.fopen ('/maint/admin'
                    , 'config.txt'
                    , 'R'
                    , max_linesize => 32767
                     );
END;
/

BEGIN
   NULL;
EXCEPTION
   WHEN OTHERS
   THEN
      UTL_FILE.fclose_all;
--... other clean up activities ...
END;
/

DECLARE
   l_file   UTL_FILE.file_type;
   l_line   VARCHAR2 (32767);
BEGIN
   l_file :=
      UTL_FILE.fopen ('TEMP_DIR', 'numlist.txt', 'R', max_linesize => 32767);
   UTL_FILE.get_line (l_file, l_line);
   DBMS_OUTPUT.put_line (l_line);
END;
/

CREATE OR REPLACE PROCEDURE process_line (line_in IN VARCHAR2)
IS
BEGIN
   NULL;
END;
/

DECLARE
   l_file   UTL_FILE.file_type;
   l_line   VARCHAR2 (32767);
BEGIN
   l_file := UTL_FILE.fopen ('TEMP', 'names.txt', 'R');

   LOOP
      UTL_FILE.get_line (l_file, l_line);
      process_line (l_line);
   END LOOP;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      UTL_FILE.fclose (l_file);
END;
/

DECLARE
   l_file   UTL_FILE.file_type;
   l_line   VARCHAR2 (32767);
   l_eof    BOOLEAN;
BEGIN
   l_file := UTL_FILE.fopen ('TEMP', 'names.txt', 'R');

   LOOP
      get_nextline (l_file, l_line, l_eof);
      EXIT WHEN l_eof;
      process_line (l_line);
   END LOOP;

   UTL_FILE.fclose (l_file);
END;
/

PROCEDURE names_to_file
IS
   fileid   UTL_FILE.file_type;
BEGIN
   fileid := UTL_FILE.fopen ('TEMP', 'names.dat', 'W');

   FOR emprec IN (SELECT *
                    FROM employee)
   LOOP
      UTL_FILE.put_line (fileid
                       , emprec.first_name || ' ' || emprec.last_name
                        );
   END LOOP;

   UTL_FILE.fclose (fileid);
END names_to_file;
/

DECLARE
   file_suffix   VARCHAR2 (100) := TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS');
BEGIN
   -- Copy the entire file...
   UTL_FILE.fcopy (src_location => 'DEVELOPMENT_DIR'
                 , src_filename => 'archive.zip'
                 , dest_location => 'ARCHIVE_DIR'
                 , dest_filename => 'archive' || file_suffix || '.zip'
                  );
END;
/

DECLARE
   c_start_year         CONSTANT PLS_INTEGER := 2008;
   c_year_of_interest   CONSTANT PLS_INTEGER := 2009;
   l_start              PLS_INTEGER;
   l_end                PLS_INTEGER;
BEGIN
   l_start := (c_year_of_interest - c_start_year) * 12 + 1;
   l_end := l_start + 11;

   UTL_FILE.fcopy (src_location => 'WINNERS_DIR'
                 , src_filename => 'names.txt'
                 , dest_location => 'WINNERS_DIR'
                 , dest_filename => 'names2008.txt'
                 , start_line => l_start
                 , end_line => l_end
                  );
END;
/

BEGIN
   UTL_FILE.fremove ('DEVELOPMENT_DIR', 'archive.zip');
END;
/

DECLARE
   l_fexists       BOOLEAN;
   l_file_length   PLS_INTEGER;
   l_block_size    PLS_INTEGER;
BEGIN
   UTL_FILE.fgetattr (location => 'DEVELOPMENT_DIR'
                    , filename => 'bigpkg.pkg'
                    , fexists => l_fexists
                    , file_length => l_file_length
                    , block_size => l_block_size
                     );
END;
/

/* Requires Oracle Database 10g or later */

BEGIN
   UTL_MAIL.send (sender => 'me@mydomain.com'
                , recipients => 'you@yourdomain.com'
                , subject => 'API for sending email'
                , MESSAGE => 'Dear Friend:
 
This is not spam. It is a mail test.
 
Mailfully Yours,
Bill'
                 );
END;
/

BEGIN
   DBMS_NETWORK_ACL_ADMIN.create_acl (
      acl => 'mail-server.xml'
    , description => 'Permission to make network connections to mail server'
    , principal => 'SCOTT'                              /* username or role */
    , is_grant => TRUE
    , privilege => 'connect'
   );

   DBMS_NETWORK_ACL_ADMIN.assign_acl (acl => 'mail-server.xml'
                                    , HOST => 'my-STMP-servername'
                                    , lower_port => 25 /* The default SMTP network port */
                                    , upper_port => NULL /* Null here means open only port 25 */
                                     );
END;
/

BEGIN
   send_mail_via_utl_smtp ('myname@mydomain.com'
                         , 'yourname@yourdomain.com'
                         , 'mail demo'
                         , NULL
                          );
END;
/

BEGIN
   UTL_MAIL.send ('Bob Swordfish <myname@mydomain.com>'
                , '"Scott Tiger, Esq." <yourname@yourdomain.com>'
                , subject => 'mail demo'
                 );
END;
/

DECLARE
   b64   VARCHAR2 (512) := 'H4sICDh/TUICA2xlc21...';         -- etc., as above
   txt   VARCHAR2 (512) := 'Dear Scott: ...';                -- etc., as above
BEGIN
   UTL_MAIL.send_attach_varchar2 (sender => 'my@myname.com'
                                , recipients => 'you@yourname.com'
                                , MESSAGE => txt
                                , subject => 'Attachment demo'
                                , att_mime_type => 'application/x-gzip'
                                , attachment => b64
                                , att_inline => TRUE
                                , att_filename => 'hugo.txt.gz'
                                 );
END;
/

DECLARE
   page_pieces   UTL_HTTP.html_pieces;              -- array of VARCHAR2(2000)
BEGIN
   page_pieces := UTL_HTTP.request_pieces (url => 'http://www.oreilly.com/');
END;
/

DECLARE
   req    UTL_HTTP.req;       -- a "request object" (actually a PL/SQL record)
   resp   UTL_HTTP.resp;         -- a "response object" (also a PL/SQL record)
   buf    VARCHAR2 (32767);               -- buffer to hold data from web page
BEGIN
   req :=
      UTL_HTTP.begin_request ('http://www.oreilly.com/'
                            , http_version => UTL_HTTP.http_version_1_1
                             );
   UTL_HTTP.set_header (req
                      , 'User-Agent'
                      , 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)'
                       );
   resp := UTL_HTTP.get_response (req);

   BEGIN
      LOOP
         UTL_HTTP.read_text (resp, buf);
      -- process buf here; e.g., store in array
      END LOOP;
   EXCEPTION
      WHEN UTL_HTTP.end_of_body
      THEN
         NULL;
   END;

   UTL_HTTP.end_response (resp);
END;
/

DECLARE
   text   CLOB;
BEGIN
   text := httpuritype ('http://www.oreilly.com').getclob;
END;
/

DECLARE
   image   BLOB;
BEGIN
   image :=
      httpuritype ('www.oreilly.com/catalog/covers/oraclep4.s.gif').getblob;
END;
/

DECLARE
   webtext     CLOB;
   user_pass   VARCHAR2 (64) := 'bob:swordfish';      -- replace with your own
   url         VARCHAR2 (128) := 'www.encryptedsite.com/cgi-bin/login';
BEGIN
   webtext := httpuritype (user_pass || '@' || url).getclob;
END;
/

DECLARE
   req    UTL_HTTP.req;
   resp   UTL_HTTP.resp;
BEGIN
   UTL_HTTP.set_wallet ('file:/oracle/wallets', 'password1');
   req := UTL_HTTP.begin_request ('https://www.entrust.com/');
   UTL_HTTP.set_header (req, 'User-Agent', 'Mozilla/4.0');
   resp := UTL_HTTP.get_response (req);
   UTL_HTTP.end_response (resp);
END;
/

DECLARE
   url      VARCHAR2 (64) := 'http://www.google.com/search?q=';
   qry VARCHAR2 (128)
         := utl_url.escape ('"oracle pl/sql programming"', TRUE);
   result   CLOB;
BEGIN
   result := httpuritype (url || qry).getclob;
END;
/

DECLARE
   req    UTL_HTTP.req;
   resp   UTL_HTTP.resp;
   qry    VARCHAR2 (512) := utl_url.escape ('query=oracle pl/sql');
BEGIN
   req :=
      UTL_HTTP.begin_request ('http://search.apache.org/'
                            , 'POST'
                            , 'HTTP  /1.0'
                             );
   UTL_HTTP.set_header (req, 'User-Agent', 'Mozilla/4.0');
   UTL_HTTP.set_header (req, 'Host', 'search.apache.org');
   UTL_HTTP.set_header (req
                      , 'Content-Type'
                      , 'application/x-www-form-urlencoded'
                       );
   UTL_HTTP.set_header (req, 'Content-Length', TO_CHAR (LENGTH (qry)));
   UTL_HTTP.write_text (req, qry);
   resp := UTL_HTTP.get_response (req);

   -- ...now we can retrieve the results as before (e.g., line by line)

   UTL_HTTP.end_response (resp);
END;
/

DECLARE
   enabled        BOOLEAN;
   max_total      PLS_INTEGER;
   max_per_site   PLS_INTEGER;
BEGIN
   UTL_HTTP.get_cookie_support (enabled, max_total, max_per_site);

   IF enabled
   THEN
      DBMS_OUTPUT.put ('Allowing ' || max_per_site || ' per site');
      DBMS_OUTPUT.put_line (' for total of ' || max_total || ' cookies. ');
   ELSE
      DBMS_OUTPUT.put_line ('Cookie support currently disabled.');
   END IF;
END;
/

DECLARE
   req    UTL_HTTP.req;
   resp   UTL_HTTP.resp;
BEGIN
   UTL_HTTP.set_proxy (proxy => '10.2.1.250:8888'
                     , no_proxy_domains => 'mycompany.com, hr.mycompany.com'
                      );

   req := UTL_HTTP.begin_request ('http://some-remote-site.com');

   /* If your proxy requires authentication, use this: */
   UTL_HTTP.set_authentication (r => req
                              , username => 'username'
                              , password => 'password'
                              , for_proxy => TRUE
                               );

   resp := UTL_HTTP.get_response (req);
-- ...etc.
END;
/

