SET LINES 300
SET FEEDBACK OFF

PROMPT NB: Before running this script, please run ch12_waterfalls.sql (see comments in that file)
PROMPT The schema in which this script is run will need the CREATE ANY DIRECTORY privilege
PROMPT Also ensure XDB is installed so that XMLType works (see Oracle documentation)
PROMPT Also ensure the DBMS_OBFUSCATION_TOOLKIT package is present, if not run ?/rdbms/admin/dbmsobtk.sql
PROMPT Press RETURN to continue this script or Ctrl+C to quit
PAUSE

PROMPT Connecting to the user in which the WATERFALLS table resides (please enter details)

CONNECT &&username/&&password@&&database

PROMPT Loading image into WATERFALLS table
PROMPT

DECLARE
   Tannery_Falls_Image BFILE := BFILENAME('BFILE_DATA','TanneryFalls_files\DCP_1546.JPG');
   image BLOB;
   destination_offset INTEGER := 1;
   source_offset INTEGER := 1;
BEGIN
   --Delete row for Tannery Falls, so this example
   --can run multiple times.
   DELETE FROM waterfalls WHERE falls_name='Tannery Falls';

   --Insert a new row using EMPTY_BLOB(  ) to create a LOB locator
   INSERT INTO waterfalls
             (falls_name,falls_photo)
      VALUES ('Tannery Falls',EMPTY_BLOB(  ));

   --Retrieve the LOB locator created by the previous INSERT statement
   SELECT falls_photo
     INTO image
     FROM waterfalls
    WHERE falls_name='Tannery Falls';

   --Open the target BLOB and the source BFILE
   DBMS_LOB.OPEN(image, DBMS_LOB.LOB_READWRITE);
   DBMS_LOB.OPEN(Tannery_Falls_Image);

   --Load the contents of the BFILE into the CLOB column
   DBMS_LOB.LOADBLOBFROMFILE(image, Tannery_Falls_Image,
                             DBMS_LOB.LOBMAXSIZE,
                             destination_offset, source_offset);

   --Close both LOBs
   DBMS_LOB.CLOSE(image);
   DBMS_LOB.CLOSE(Tannery_Falls_Image);
END;
/

PROMPT Granting permission to make HTTP requests to any server
PROMPT This needs to be run as SYSTEM

CONNECT system/&&system_password@&&database


BEGIN
   DBMS_NETWORK_ACL_ADMIN.CREATE_ACL (
       acl          => 'http_flickr.xml'
      ,description  => 'Permission to make HTTP requests'
      ,principal    => UPPER('&&username')
      ,is_grant     => TRUE
      ,privilege    => 'connect'
   );

   DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL (
       acl         => 'http_flickr.xml'
      ,host        => '*'
      ,lower_port  => 80
      ,upper_port  => null
   ); 

END;
/


CONNECT &&username/&&password@&&database


PROMPT
PROMPT Creating Flickr package
SET DEFINE OFF

CREATE OR REPLACE PACKAGE Flickr IS
   FUNCTION Get_Frob RETURN VARCHAR2;
   FUNCTION Construct_Auth_Url(in_frob IN VARCHAR2) RETURN VARCHAR2;
   FUNCTION Get_Token(in_frob IN VARCHAR2) RETURN VARCHAR2;
   FUNCTION Upload_Photo(in_photo IN BLOB, in_title IN VARCHAR2, in_token IN VARCHAR2) RETURN VARCHAR2;
END Flickr;
/

CREATE OR REPLACE PACKAGE BODY Flickr IS
   -- These are provided by Flickr when you apply for an API key. They are
   -- associated with a Flickr account.
   account_api_key CONSTANT VARCHAR2(100) := '15e350c003db6390313e257e959294fb';
   account_secret CONSTANT VARCHAR2(100) := 'c7a59b8f44a8a45e';

   flickr_rest_url_base CONSTANT VARCHAR2(100) := 'http://flickr.com/services/rest/?';
   flickr_auth_url_base CONSTANT VARCHAR2(100) := 'http://flickr.com/services/auth/?';
   flickr_post_url_base CONSTANT VARCHAR2(100) := 'http://api.flickr.com/services/';

   TYPE Api_Parameters IS TABLE OF VARCHAR2(32767) INDEX BY VARCHAR2(64);
   TYPE Table_Of_Strings IS TABLE OF VARCHAR2(32767);

   -- Takes a set of Flickr API parameters, and "signs" them by adding another
   -- parameter api_sig containing a signature in the Flickr required format.
   PROCEDURE Add_Signature(in_parameters IN OUT Api_Parameters) IS
      api_sig VARCHAR2(32767);
      key VARCHAR2(64);
      md5 RAW(16);
   BEGIN
      api_sig := account_secret;

      -- Concatenate the parameter names and values in alphabetical order
      -- (You get alphabetical order for free with associative arrays)
      key := in_parameters.FIRST;
      WHILE key IS NOT NULL LOOP
         IF key <> 'photo' THEN
            api_sig := api_sig || key || in_parameters(key);
         END IF;
         key := in_parameters.NEXT(key);
      END LOOP;

      -- Compute the MD5 hash
      md5 := DBMS_OBFUSCATION_TOOLKIT.MD5(input => UTL_RAW.CAST_TO_RAW(api_sig));
      in_parameters('api_sig') := LOWER(RAWTOHEX(md5));
   END Add_Signature;


   -- Prepares a set of Flickr API parameters for a GET request
   -- Output is param1=value1&param2=value2&...
   FUNCTION Create_Get_Parameters(in_parameters IN Api_Parameters) RETURN VARCHAR2 IS
      concatenated_params VARCHAR2(32767);
      param_string VARCHAR2(32767);
      key VARCHAR2(64);
   BEGIN
      key := in_parameters.FIRST;

      WHILE key IS NOT NULL LOOP
         IF concatenated_params IS NOT NULL THEN
            concatenated_params := concatenated_params || '&';
         END IF;

         param_string := key || '=' || in_parameters(key);
         concatenated_params := concatenated_params || UTL_URL.ESCAPE(param_string);

         key := in_parameters.NEXT(key);
      END LOOP;

      RETURN concatenated_params;
   END Create_Get_Parameters;


   -- Adds a string to the table of strings, and keeps track of the total length
   -- of all the strings.
   PROCEDURE Add_Post_String(tab IN OUT Table_Of_Strings, str IN VARCHAR2,
                             len IN OUT PLS_INTEGER) IS
   BEGIN
      tab.EXTEND;
      tab(tab.LAST) := str;
      -- Add 2 because of the carriage return and linefeed at the end of the line
      len := len + NVL(LENGTH(str),0) + 2;
   END Add_Post_String;


   -- Prepares a set of Flickr API parameters for a POST request. Because
   -- a parameter value may be binary (i.e. the photo), we need to create a
   -- MIME multipart request. The resulting text is in fact the same as if the
   -- photo were uploaded into an HTML form. Because we need to specify the
   -- content length in advance, we return the text as a table of strings with
   -- the total length of the strings.
   PROCEDURE Create_Post_Parameters(in_parameters IN Api_Parameters,
                                    in_boundary IN VARCHAR2,
                                    out_table OUT Table_Of_Strings,
                                    out_length OUT PLS_INTEGER) IS
      key VARCHAR2(64);
   BEGIN
      out_length := 0;
      key := in_parameters.FIRST;
      out_table := Table_Of_Strings();
      WHILE key IS NOT NULL LOOP
         Add_Post_String(out_table, '--' || in_boundary, out_length);
         IF key = 'photo' THEN
            Add_Post_String(out_table, 'Content-Disposition: form-data; name="photo"; filename="dummy.jpg"', out_length);
            Add_Post_String(out_table, 'Content-Type: image/jpeg', out_length);
         ELSE
            Add_Post_String(out_table, 'Content-Disposition: form-data; name="' || key || '"', out_length);
         END IF;
         Add_Post_String(out_table, NULL, out_length);
         Add_Post_String(out_table, in_parameters(key), out_length);

         key := in_parameters.NEXT(key);
      END LOOP;

      Add_Post_String(out_table, '--' || in_boundary || '--', out_length);
   END Create_Post_Parameters;


   -- Writes a BLOB (photo in our case) to an HTTP request
   PROCEDURE Write_Blob_To_Http(req IN OUT UTL_HTTP.req, in_blob IN BLOB) IS
      i PLS_INTEGER;
   BEGIN
      -- Maximum length of a RAW is 32767 bytes, so do it a chunk at a time
      i := 1;
      WHILE i <= LENGTH(in_blob) LOOP
         UTL_HTTP.write_raw(req, DBMS_LOB.SUBSTR(in_blob, 32767, i));
         i := i + 32767;
      END LOOP;
   END Write_Blob_To_Http;


   -- Creates a new HTTP request
   FUNCTION Construct_Request(in_url IN VARCHAR2, in_method IN VARCHAR2) RETURN UTL_HTTP.req IS
      req UTL_HTTP.req;
   BEGIN
      req := UTL_HTTP.begin_request(in_url, in_method, UTL_HTTP.http_version_1_1);
      UTL_HTTP.set_header(req, 'User-Agent', 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)');
      RETURN req;
   END Construct_Request;


   -- Sends an HTTP request and returns its response
   FUNCTION Perform_Request(req IN OUT UTL_HTTP.req) RETURN VARCHAR2 IS
      resp UTL_HTTP.resp;
      buf VARCHAR2(32767);
   BEGIN
      resp := UTL_HTTP.get_response(req);
      UTL_HTTP.read_text(resp, buf);
      UTL_HTTP.end_response(resp);
      RETURN buf;
   END Perform_Request;


   -- Parses the HTTP response from the Flickr API. Typical responses are:
   -- <?xml version="1.0" encoding="utf-8" ?>
   --    <rsp stat="ok">
   --       <photoid>3822924773</photoid>
   --    </rsp>
   -- or
   -- <?xml version="1.0" encoding="utf-8" ?>
   --    <rsp stat="fail">
   --       <err code="5" msg="Filetype was not recognised" />
   --    </rsp>
   -- In the first case it returns the photoid, assuming in_parameter_of_interest
   -- is set to "photoid".
   -- In the second case it throws an exception containing the error message.
   FUNCTION Parse_Response(in_response IN VARCHAR2, in_parameter_of_interest IN VARCHAR2) RETURN VARCHAR2 IS
      xml_response XmlType;
      status VARCHAR(32767);
      message VARCHAR(32767);
   BEGIN
      xml_response := XmlType(in_response);
      status := xml_response.extract('//@stat').getStringVal();
      IF status = 'ok' THEN
         RETURN xml_response.extract('//' || in_parameter_of_interest || '/text()').getStringVal();
      ELSIF status = 'fail' THEN
         message := xml_response.extract('//@msg').getStringVal();
         RAISE_APPLICATION_ERROR(-20000, 'Flickr returned an error: ' || message);
      ELSE
         RAISE_APPLICATION_ERROR(-20000, 'Unrecognised response from Flickr');
      END IF;
   END Parse_Response;


   -- Sends a REST request to the Flickr API. Such requests are HTTP GETs whose
   -- parameters are included in the URL. in_return_param contains the parameter
   -- in the Flickr response that we are interested in (e.g. the frob value).
   FUNCTION Perform_Rest_Request(in_parameters IN Api_Parameters, in_return_param IN VARCHAR2) RETURN VARCHAR2 IS
      url VARCHAR2(32767);
      req UTL_HTTP.req;
      response_string VARCHAR2(32767);
   BEGIN
      url := flickr_rest_url_base || Create_Get_Parameters(in_parameters);
      req := Construct_Request(url, 'GET');
      response_string := Perform_Request(req);
      RETURN Parse_Response(response_string, in_return_param);
   END Perform_Rest_Request;


   -- Sends a photo request to the Flickr API. Such requests are HTTP POSTs whose
   -- parameters are sent in MIME format.
   FUNCTION Perform_Photo_Post_Request(in_type IN VARCHAR2, in_parameters IN OUT Api_Parameters,
                                       in_photo IN BLOB, in_return_param IN VARCHAR2) RETURN VARCHAR2 IS
      url VARCHAR2(32767);
      response_string VARCHAR2(32767);
      req UTL_HTTP.req;
      i PLS_INTEGER;
      boundary CONSTANT VARCHAR2(25) := 'THIS_IS_THE_MIME_BOUNDARY';
      photo_placeholder CONSTANT VARCHAR2(15) := 'PHOTO_GOES_HERE';
      param_table Table_Of_Strings;
      content_length PLS_INTEGER;
   BEGIN
      -- This dummy photo parameter value will later be replaced by the real thing
      in_parameters('photo') := photo_placeholder;
      Create_Post_Parameters(in_parameters, boundary, param_table, content_length);
      content_length := content_length + LENGTH(in_photo) - LENGTH(photo_placeholder);

      -- Create the URL and request and add the headers we need
      url := flickr_post_url_base || in_type || '/';
      req := Construct_Request(url, 'POST');
      UTL_HTTP.set_header(req, 'Content-Type', 'multipart/form-data; boundary=' || boundary);
      UTL_HTTP.set_header(req, 'Content-Length', TO_CHAR(content_length));

      -- Write the POST parameters
      FOR i IN 1..param_table.LAST LOOP
         IF param_table(i) = photo_placeholder THEN
            Write_Blob_To_Http(req, in_photo);
            UTL_HTTP.write_text(req, utl_tcp.CRLF);
         ELSIF param_table(i) IS NULL THEN
            -- Write a blank line
            UTL_HTTP.write_text(req, utl_tcp.CRLF);
         ELSE
            UTL_HTTP.write_line(req, param_table(i));
         END IF;
      END LOOP;

      response_string := Perform_Request(req);
      RETURN Parse_Response(response_string, in_return_param);
   END Perform_Photo_Post_Request;


   -- Calls the getFrob method of the Flickr API. Returns a "frob"
   -- to be used during authentication.
   FUNCTION Get_Frob RETURN VARCHAR2 IS
      v_parameters Api_Parameters;
   BEGIN
      v_parameters('method') := 'flickr.auth.getFrob';
      v_parameters('api_key') := account_api_key;
      Add_Signature(v_parameters);
      RETURN Perform_Rest_Request(v_parameters, 'frob');
   END Get_Frob;


   -- Returns a URL at which you can point your Web browser to do
   -- authentication. Needs a frob.
   FUNCTION Construct_Auth_Url(in_frob IN VARCHAR2) RETURN VARCHAR2 IS
      v_parameters Api_Parameters;
   BEGIN
      v_parameters('api_key') := account_api_key;
      v_parameters('perms') := 'write';
      v_parameters('frob') := in_frob;
      Add_Signature(v_parameters);
      RETURN flickr_auth_url_base || Create_Get_Parameters(v_parameters);
   END Construct_Auth_Url;


   -- Gets a token that can be supplied to various Flickr API methods.
   -- The user must already have authenticated themselves.
   FUNCTION Get_Token(in_frob IN VARCHAR2) RETURN VARCHAR2 IS
      v_parameters Api_Parameters;
   BEGIN
      v_parameters('method') := 'flickr.auth.getToken';
      v_parameters('api_key') := account_api_key;
      v_parameters('frob') := in_frob;
      Add_Signature(v_parameters);
      RETURN Perform_Rest_Request(v_parameters, 'token');
   END Get_Token;


   -- Uploads a photo to Flickr. The photo itself is not included in the signature.
   FUNCTION Upload_Photo(in_photo IN BLOB, in_title IN VARCHAR2, in_token IN VARCHAR2) RETURN VARCHAR2 IS
      v_parameters Api_Parameters;
   BEGIN
      v_parameters('api_key') := account_api_key;
      v_parameters('title') := in_title;
      v_parameters('auth_token') := in_token;
      Add_Signature(v_parameters);
      RETURN Perform_Photo_Post_Request('upload', v_parameters, in_photo, 'photoid');
   END Upload_Photo;

END Flickr;
/

SET DEFINE ON
SET SERVEROUTPUT ON SIZE UNLIMITED

PROMPT
PROMPT Good to go!
PROMPT
PROMPT
PROMPT ------------------------------------------------------------
PROMPT
PROMPT

PROMPT Step 1: Obtain "frob" from Flickr
PROMPT

REM Example request: http://flickr.com/services/rest/?method=flickr.auth.getFrob&api_key=987654321&api_sig=5f3870be274f6c49b3e31a0c6728957f
REM Example response: <frob>746563215463214621</frob>

VARIABLE frob VARCHAR2(4000)
begin
    :frob := Flickr.Get_Frob;
    dbms_output.put_line('Frob is ' || :frob);
end;
/

PROMPT
PROMPT
PROMPT Step 2: Authorize this application to upload photos
PROMPT
PROMPT This must be done manually by going to the following URL (you'll need all of it!):

REM Example URL: http://flickr.com/services/auth/?api_key=987654321&perms=write&frob=746563215463214621&api_sig=2f3870be274f6c49b3e31a0c6728957f

begin
    dbms_output.put_line(Flickr.Construct_Auth_Url(:frob));
end;
/

PROMPT
PROMPT Yahoo username is opp5test@yahoo.com, password is oracle
PROMPT
PROMPT Please visit this URL now and press RETURN when authorized...
PAUSE


PROMPT
PROMPT Step 3: Obtain token
PROMPT

REM Example request: http://flickr.com/services/rest/?method=flickr.auth.getToken&api_key=987654321&frob=746563215463214621&api_sig=7f3870be274f6c49b3e31a0c6728957f
REM Example response:
REM <auth>
REM   <token>976598454353455</token>
REM   <perms>write</perms>
REM   <user nsid="12037949754@N01" username="Bees" fullname="Cal H" />
REM </auth>

VARIABLE token VARCHAR2(4000)
begin
    :token := Flickr.Get_Token(:frob);
    dbms_output.put_line('Token is ' || :token);
end;
/

PROMPT
PROMPT
PROMPT Step 4: Upload photo
PROMPT

REM This is a POST request to the URL http://api.flickr.com/services/upload/
REM It is sent in the MIME multipart/form-data format, and includes parameters
REM api_key, api_sig, auth_token, title, and photo in binary format

declare
    photo blob;
begin
    select falls_photo into photo from waterfalls;
    dbms_output.put_line('Photo ID: ' || flickr.Upload_Photo(photo, 'Tannery Falls', :token));
end;
/

PROMPT
PROMPT PHOTO UPLOADED! You should now be able to see the photo at www.flickr.com (login as before)
PROMPT NB: Please delete the photo when you have viewed it, for the benefit of other users - thanks!
PROMPT
