/*
Oracle PL/SQL Programming 5th Edition

www.stevenfeuerstein.com/books

Objection creation and example scripts for Chapter 13

You will find below all non-trivial code snippets from the above chapter
that are NOT contained in their own files (as specified in the chapter),
plus any DDL object creation scripts required to get a clean compile
on the snippets.

Any references to Oracle's standard HR tables (employees, departments,
locations, regions, etc.) will NOT include the DDL creation scripts
in this file. Instead, run the hr_schema_install.sql script and all
those tables and related elements will be defined.
*/

DECLARE
   report_requested   BOOLEAN;
BEGIN
   IF report_requested
   THEN
      NULL;                              --Executes if report_requested = TRUE
   ELSE
      NULL;                  --Executes if report_requested = FALSE or IS NULL
   END IF;

   IF NOT report_requested
   THEN
      NULL;                             --Executes if report_requested = FALSE
   ELSE
      NULL;                    --Executes if report_requeste = TRUE or IS NULL
   END IF;

   IF report_requested
   THEN
      NULL;                              --Executes if report_requested = TRUE
   ELSIF NOT report_requested
   THEN
      NULL;                             --Executes if report_requested = FALSE
   ELSE
      NULL;                             --Executes if report_requested IS NULL
   END IF;
END;
/

BEGIN
   DELETE FROM employees
         WHERE employee_id = 99999;

   INSERT INTO employees (
                             employee_id
                           , last_name
                           , first_name
                           , email
                           , hire_date
                           , job_id
              )
       VALUES (99999, 'Grubbs', 'John', 'GRUBBS', SYSDATE, 'AD_VP'
              );

   COMMIT;
END;
/

DECLARE
   employee_rowid    UROWID;
   employee_salary   NUMBER;
BEGIN
   --Retrieve employee information that we might want to modify
   SELECT ROWID, salary
     INTO employee_rowid, employee_salary
     FROM employees
    WHERE last_name = 'Grubbs' AND first_name = 'John';
END;
/

DECLARE
   employee_rowid    UROWID;
   employee_salary   NUMBER;
BEGIN
   --Retrieve employee information that we might want to modify
   SELECT ROWID, salary
     INTO employee_rowid, employee_salary
     FROM employees
    WHERE last_name = 'Grubbs' AND first_name = 'John';

   /* Do a bunch of processing to compute a new salary */

   UPDATE employees
      SET salary = employee_salary
    WHERE last_name = 'Grubbs' AND first_name = 'John';
END;
/

DECLARE
   employee_rowid    UROWID;
   employee_salary   NUMBER;
BEGIN
   --Retrieve employee information that we might want to modify
   SELECT ROWID, salary
     INTO employee_rowid, employee_salary
     FROM employees
    WHERE last_name = 'Grubbs' AND first_name = 'John';

   /* Do a bunch of processing to compute a new salary */

   UPDATE employees
      SET salary = employee_salary
    WHERE ROWID = employee_rowid;
END;
/

DROP TABLE waterfalls
/

CREATE TABLE waterfalls
(
   falls_name          VARCHAR2 (80)
 , falls_photo         BLOB
 , falls_directions    CLOB
 , falls_description   NCLOB
 , falls_web_page      BFILE
)
/

DECLARE
   photo   BLOB;
BEGIN
   SELECT falls_photo
     INTO photo
     FROM waterfalls
    WHERE falls_name = 'Dryer Hose';
END;
/

DECLARE
   directions   CLOB;
BEGIN
   IF directions IS NULL
   THEN
      DBMS_OUTPUT.put_line ('directions is NULL');
   ELSE
      DBMS_OUTPUT.put_line ('directions is not NULL');
   END IF;
END;
/

DECLARE
   directions   CLOB;
BEGIN
   IF directions IS NULL
   THEN
      DBMS_OUTPUT.put_line ('at first directions is NULL');
   ELSE
      DBMS_OUTPUT.put_line ('at first directions is not NULL');
   END IF;

   DBMS_OUTPUT.put_line ('Length = ' || DBMS_LOB.getlength (directions));

   -- initialize the LOB variable
   directions := EMPTY_CLOB ();

   IF directions IS NULL
   THEN
      DBMS_OUTPUT.put_line ('after initializing, directions is NULL');
   ELSE
      DBMS_OUTPUT.put_line ('after initializing, directions is not NULL');
   END IF;

   DBMS_OUTPUT.put_line ('Length = ' || DBMS_LOB.getlength (directions));
END;
/

DECLARE
   some_clob   CLOB;
BEGIN
   IF some_clob IS NULL
   THEN
      --There is no data
      NULL;
   ELSIF DBMS_LOB.getlength (some_clob) = 0
   THEN
      --There is no data
      NULL;
   ELSE
      --Only now is there data
      NULL;
   END IF;

   IF NVL (DBMS_LOB.getlength (some_clob), 0) = 0
   THEN
      -- There is no data
      NULL;
   ELSE
      -- There is data
      NULL;
   END IF;
END;
/

CREATE DIRECTORY bfile_data AS 'c:\PLSQL Book\Ch13_Misc_Datatypes\'
/

DECLARE
   web_page   BFILE;
BEGIN
   --Delete row for Tannery Falls so this example can
   --be executed multiple times
   DELETE FROM waterfalls
         WHERE falls_name = 'Tannery Falls';

   --Invoke BFILENAME to create a BFILE locator
   web_page := BFILENAME ('BFILE_DATA', 'Tannery_Falls.htm');

   --Save our new locator in the waterfalls table
   INSERT INTO waterfalls (falls_name, falls_web_page
                          )
       VALUES ('Tannery Falls', web_page
              );
END;
/

DECLARE
   web_page   BFILE;
   html       RAW (60);
   amount     BINARY_INTEGER := 60;
   offset     INTEGER := 1;
BEGIN
   --Retrieve the LOB locator for the web page
   SELECT falls_web_page
     INTO web_page
     FROM waterfalls
    WHERE falls_name = 'Tannery Falls';

   --Open the locator, read 60 bytes, and close the locator
   DBMS_LOB.open (web_page);
   DBMS_LOB.read (web_page, amount, offset, html);
   DBMS_LOB.close (web_page);

   --Uncomment following line to display results in hex
   --DBMS_OUTPUT.PUT_LINE(RAWTOHEX(html));

   --Cast RAW results to a character string we can read
   DBMS_OUTPUT.put_line (UTL_RAW.cast_to_varchar2 (html));
END;
/

CREATE TABLE waterfalls
(
   falls_name          VARCHAR2 (80)
 , falls_photo         BLOB
 , falls_directions    CLOB
 , falls_description   NCLOB
 , falls_web_page      BFILE
)
LOB (falls_photo) STORE AS SECUREFILE (COMPRESS DEDUPLICATE)
LOB (falls_directions) STORE AS SECUREFILE (COMPRESS DEDUPLICATE)
LOB (falls_description) STORE AS SECUREFILE (COMPRESS DEDUPLICATE)
/

CREATE TABLE waterfalls
(
   falls_name          VARCHAR2 (80)
 , falls_photo         BLOB
 , falls_directions    CLOB
 , falls_description   NCLOB
 , falls_web_page      BFILE
)
LOB (falls_photo) STORE AS SECUREFILE (COMPRESS DEDUPLICATE)
LOB (falls_directions) STORE AS SECUREFILE (ENCRYPT USING 'AES256')
LOB (falls_description) STORE AS SECUREFILE
   (ENCRYPT DEDUPLICATE COMPRESS HIGH
   )
/

ALTER SYSTEM SET ENCRYPTION KEY AUTHENTICATED BY "My-secret!passc0de"
/

/*
    ENCRYPTION_WALLET_LOCATION=(SOURCE=(METHOD=file)
      (METHOD_DATA=(DIRECTORY=/oracle/wallet))) 
*/
    ALTER SYSTEM SET ENCRYPTION WALLET OPEN AUTHENTICATED BY "My-secret!passc0de"
/

/* now close the wallet */
ALTER SYSTEM SET ENCRYPTION WALLET CLOSE
/

DECLARE
   temp_clob   CLOB;
   temp_blob   BLOB;
BEGIN
   --Assigning a value to a null CLOB or BLOB variable causes
   --PL/SQL to implicitly create a session-duration temporary
   --LOB for you.
   temp_clob := ' http://www.nps.gov/piro/';
   temp_blob := HEXTORAW ('7A');
END;
/

DECLARE
   temp_clob   CLOB;
   temp_blob   BLOB;
BEGIN
   --Assigning a value to a null CLOB or BLOB variable causes
   --PL/SQL to implicitly create a session-duration temporary
   --LOB for you.
   temp_clob := 'http://www.exploringthenorth.com/alger/alger.html';
   temp_blob := HEXTORAW ('7A');

   DBMS_LOB.freetemporary (temp_clob);
   DBMS_LOB.freetemporary (temp_blob);
END;
/

DECLARE
   name          CLOB;
   name_upper    CLOB;
   directions    CLOB;
   blank_space   VARCHAR2 (1) := ' ';
BEGIN
   --Retrieve a VARCHAR2 into a CLOB, apply a function to a CLOB
   SELECT falls_name, SUBSTR (falls_directions, 1, 500)
     INTO name, directions
     FROM waterfalls
    WHERE falls_name = 'Munising Falls';

   --Uppercase a CLOB
   name_upper := UPPER (name);

   -- Compare two CLOBs
   IF name = name_upper
   THEN
      DBMS_OUTPUT.put_line ('We did not need to uppercase the name.');
   END IF;

   --Concatenate a CLOB with some VARCHAR2 strings
   IF INSTR (directions, 'Mackinac Bridge') <> 0
   THEN
      DBMS_OUTPUT.put_line(   'To get to '
                           || name_upper
                           || blank_space
                           || 'you must cross the Mackinac Bridge.');
   END IF;
END;
/

DECLARE
   directions   CLOB;
BEGIN
   SELECT UPPER (falls_directions)
     INTO directions
     FROM waterfalls
    WHERE falls_name = 'Munising Falls';
END;
/

DECLARE
   directions_upper        CLOB;
   directions_persistent   CLOB;
BEGIN
   SELECT UPPER (falls_directions), falls_directions
     INTO directions_upper, directions_persistent
     FROM waterfalls
    WHERE falls_name = 'Munising Falls';
END;
/

CREATE TABLE fallsxml (fall_id NUMBER, fall XMLTYPE)
/

BEGIN
   INSERT INTO fallsxml
       VALUES (
                  1
                , xmltype.createxml('<?xml version="1.0"?>
        <fall>
           <name>Munising Falls</name>
           <county>Alger</county>
           <state>MI</state>
           <url>
              http://michiganwaterfalls.com/munising_falls/munising_falls.html
           </url>
        </fall>')
              );

   INSERT INTO fallsxml
       VALUES (
                  2
                , xmltype.createxml('<?xml version="1.0"?>
        <fall>
           <name>Au Train Falls</name>
           <county>Alger</county>
           <state>MI</state>
           <url>
              http://michiganwaterfalls.com/autrain_falls/autrain_falls.html
           </url>
        </fall>')
              );

   INSERT INTO fallsxml
       VALUES (
                  3
                , xmltype.createxml('<?xml version="1.0"?>
        <fall>
           <name>Laughing Whitefish Falls</name>
           <county>Alger</county>
           <state>MI</state>
           <url>
             http://michiganwaterfalls.com/whitefish_falls/whitefish_falls.html
           </url>
        </fall>')
              );
END;
/

SELECT fall_id
  FROM fallsxml f
 WHERE f.fall.EXISTSNODE ('/fall/url') > 0
/

SELECT fall_id
  FROM fallsxml
 WHERE EXISTSNODE (fall, '/fall/url') > 0
/

<<demo_block>>
DECLARE
   fall   XMLTYPE;
   url    VARCHAR2 (100);
BEGIN
   --Retrieve XML for Munising Falls
   SELECT fall
     INTO demo_block.fall
     FROM fallsxml f
    WHERE f.fall_id = 1;

   --Extract and display the URL for Munising Falls
   url := fall.EXTRACT ('/fall/url/text()').getstringval;
   DBMS_OUTPUT.put_line (url);
END;
/

BEGIN
   -- create the ACL
   DBMS_NETWORK_ACL_ADMIN.create_acl (
      acl => 'oreillynet-permissions.xml'
    , description => 'Network permissions for www.oreillynet.com'
    , principal => 'WEBROLE'
    , is_grant => TRUE
    , privilege => 'connect'
    , start_date => SYSTIMESTAMP
    , end_date => NULL
   );
   -- assign privileges to the ACL
   DBMS_NETWORK_ACL_ADMIN.add_privilege (acl => 'oreillynet-permissions.xml'
                                       , principal => 'WEBROLE'
                                       , is_grant => TRUE
                                       , privilege => 'connect'
                                       , start_date => SYSTIMESTAMP
                                       , end_date => NULL
                                        );
   -- define the allowable destintions
   DBMS_NETWORK_ACL_ADMIN.assign_acl (acl => 'oreillynet-permissions.xml'
                                    , HOST => 'www.orillynet.com'
                                    , lower_port => 80
                                    , upper_port => 80
                                     );
   COMMIT;                                     -- You must commit the changes.
END;
/

DECLARE
   webpageurl   HTTPURITYPE;
   webpage      CLOB;
BEGIN
   --Create an instance of the type pointing
   --to Steven's Author Bio page at OReilly
   webpageurl :=
      httpuritype.createuri ('http:// www.oreillynet.com/pub/au/344');

   --Retrieve the page via HTTP
   webpage := webpageurl.getclob ();

   --Display the page title
   DBMS_OUTPUT.put_line (REGEXP_SUBSTR (webpage, '<title>.*</title>'));
END;
/

