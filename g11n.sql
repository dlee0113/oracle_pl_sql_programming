-------------------------------------------------------------
-- File Name: g11n.sql
-- Purpose: Creates the g11n schema for testing
--          Oracle globalization and localization in PL/SQL.
--
-- Setup:
-- Enter valid values below for your environment.
-- If needed, create your own default and temp tablespaces
-------------------------------------------------------------

DEF i_full_conn_string = g11n/oracle
DEF i_system_conn = system/oracle
DEF i_default_tablespace = USERS
DEF i_temp_tablespace = TEMP

CONN &i_system_conn

SET SERVEROUTPUT ON FEEDBACK OFF VERIFY OFF PAUSE ON ESCAPE ~

SPOOL g11n.log


PROMPT
PROMPT    YOU MAY RERUN THIS SCRIPT AT ANY TIME AND THE SCHEMA WILL
PROMPT    BE DROPPED AND RECREATED.
PROMPT
PROMPT
PROMPT    ******** CHARACTER SET VERIFICATION ********
PROMPT
PROMPT    Examine your character set.  The first two characters are
PROMPT    the region your character set supports.  The numbers that
PROMPT    follow are the number of bits per character in your character
PROMPT    set.  If they are 7 or 8, you will have problems running
PROMPT    the examples that depend on this schema.  Find another database
PROMPT    that uses a unicode character set like AL32UTF8.
PROMPT

DECLARE
   v_charset   VARCHAR2 (50);
BEGIN
   BEGIN
      SELECT VALUE
        INTO v_charset
        FROM nls_database_parameters
       WHERE parameter = 'NLS_CHARACTERSET';
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
   END;

   DBMS_OUTPUT.put_line ('Your NLS_CHARACTERSET is: ' || v_charset);

   BEGIN
      SELECT VALUE
        INTO v_charset
        FROM nls_database_parameters
       WHERE parameter = 'NLS_NCHAR_CHARACTERSET';
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
   END;

   DBMS_OUTPUT.put_line ('	');
   DBMS_OUTPUT.put_line ('Your NLS_NCHAR_CHARACTERSET is: ' || v_charset);
END;
/

PROMPT
PROMPT Press enter or spacebar to continue, or CTL-C to exit.
PROMPT
PAUSE

PROMPT
PROMPT ******************************************************
PROMPT  Creating user g11n
PROMPT ******************************************************
PROMPT

DECLARE
   v_record_count         PLS_INTEGER := 0;
   v_string               VARCHAR2 (500);
   v_user_name            VARCHAR2 (30);
   v_default_tablespace   VARCHAR2 (30);
   v_temp_tablespace      VARCHAR2 (30);
BEGIN
   v_user_name := 'G11N';
   v_default_tablespace := UPPER ('&i_default_tablespace');
   v_temp_tablespace := UPPER ('&i_temp_tablespace');

   -- Drop the user if it already exist

   SELECT COUNT (1)
     INTO v_record_count
     FROM dba_users
    WHERE username = v_user_name;

   IF v_record_count <> 0
   THEN
      v_string := 'DROP USER ' || v_user_name || ' cascade';

      EXECUTE IMMEDIATE (v_string);

      DBMS_OUTPUT.put_line ('User ' || v_user_name || ' dropped...');
      DBMS_OUTPUT.put_line ('	');
   END IF;

   -- Verify tablespaces exist

   v_record_count := 0;

   SELECT COUNT (1)
     INTO v_record_count
     FROM dba_tablespaces
    WHERE tablespace_name IN (v_default_tablespace, v_temp_tablespace);

   IF v_record_count = 2
   THEN
      -- Create the user

      v_string :=
            'CREATE USER '
         || v_user_name
         || ' IDENTIFIED BY oracle'
         || ' DEFAULT TABLESPACE '
         || v_default_tablespace
         || ' TEMPORARY TABLESPACE '
         || v_temp_tablespace
         || ' QUOTA UNLIMITED ON '
         || v_default_tablespace
         || ' ACCOUNT UNLOCK';

      EXECUTE IMMEDIATE (v_string);

      v_string := 'GRANT create session TO ' || v_user_name;

      EXECUTE IMMEDIATE (v_string);

      v_string := 'GRANT connect TO ' || v_user_name;

      EXECUTE IMMEDIATE (v_string);

      v_string := 'GRANT execute on ctx_ddl TO ' || v_user_name;

      EXECUTE IMMEDIATE (v_string);

      v_string := 'GRANT create procedure TO ' || v_user_name;

      EXECUTE IMMEDIATE (v_string);

      v_string := 'GRANT create table TO ' || v_user_name;

      EXECUTE IMMEDIATE (v_string);

      DBMS_OUTPUT.put_line (
         'User ' || v_user_name || ' created successfully...'
      );
      DBMS_OUTPUT.put_line ('	');
   ELSE
      DBMS_OUTPUT.put_line (
         'At least one of your specified tablespaces are missing.'
      );
      DBMS_OUTPUT.put_line (
         'Verify the tablespace name you entered or create it and '
      );
      DBMS_OUTPUT.put_line ('rerun this script.');
      DBMS_OUTPUT.put_line ('	');
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (SQLERRM);
      DBMS_OUTPUT.put_line ('	');
END;
/

CONN &i_full_conn_string

SET FEEDBACK ON

PROMPT
PROMPT ******************************************************
PROMPT  Populating g11n
PROMPT ******************************************************
PROMPT


PROMPT
PROMPT Create table locale
PROMPT

CREATE TABLE locale
(
   locale_id             NUMBER (1) CONSTRAINT pk_locale PRIMARY KEY
 , language              VARCHAR2 (2 CHAR)
 , country_id            CHAR (2 CHAR)
 , locale_desc           VARCHAR2 (500 CHAR)
 , date_format           VARCHAR2 (30 CHAR)
 , currency_id           VARCHAR2 (3 CHAR)
 , currency_desc         VARCHAR2 (50 CHAR)
 , currency_format       VARCHAR2 (15)
 , currency_symbol       VARCHAR2 (10)
 , iso_currency_format   VARCHAR2 (20)
 , iso_currency_name     VARCHAR2 (15)
);


INSERT INTO locale (
                       locale_id
                     , language
                     , country_id
                     , locale_desc
                     , date_format
                     , currency_id
                     , currency_desc
                     , currency_format
                     , currency_symbol
                     , iso_currency_format
                     , iso_currency_name
           )
    VALUES (
               1
             , 'ja'
             , 'JP'
             , 'Japanese'
             , 'yyyy/MM/dd hh:mi:ssxff AM TZR'
             , 'JPY'
             , 'Japanese Yen'
             , 'L999G999'
             , '¥'
             , 'C999G999'
             , 'JAPAN'
           );

INSERT INTO locale (
                       locale_id
                     , language
                     , country_id
                     , locale_desc
                     , date_format
                     , currency_id
                     , currency_desc
                     , currency_format
                     , currency_symbol
                     , iso_currency_format
                     , iso_currency_name
           )
    VALUES (
               2
             , 'de'
             , 'DE'
             , 'German'
             , 'dd Month yy hh:mi:ssxff AM TZR'
             , 'EUR'
             , 'European Euro'
             , 'L9999'
             , '€'
             , 'C9999'
             , 'GERMANY'
           );

INSERT INTO locale (
                       locale_id
                     , language
                     , country_id
                     , locale_desc
                     , date_format
                     , currency_id
                     , currency_desc
                     , currency_format
                     , currency_symbol
                     , iso_currency_format
                     , iso_currency_name
           )
    VALUES (
               3
             , 'en'
             , 'US'
             , 'English'
             , 'dd-MON-yyyy hh:mi:ssxff AM TZR'
             , 'USD'
             , 'United States Dollar'
             , 'L999G999D99'
             , '$'
             , 'C999G999D99'
             , 'AMERICA'
           );


PROMPT
PROMPT Create table users
PROMPT

CREATE TABLE users
(
   user_id             NUMBER (10) CONSTRAINT pk_users PRIMARY KEY
 , locale_id           NUMBER (1)
         CONSTRAINT fk_users_locale_id REFERENCES locale (locale_id)
 , first_name          VARCHAR2 (30 CHAR)
 , last_name           VARCHAR2 (30 CHAR)
 , registration_date   TIMESTAMP WITH TIME ZONE
);

INSERT INTO users (
                      user_id
                    , locale_id
                    , first_name
                    , last_name
                    , registration_date
           )
    VALUES (
               1
             , 3
             , 'RON'
             , 'HARDMAN'
             , TO_TIMESTAMP_TZ ('01-JAN-2004 11:34:21.000000 AM US/Mountain'
                              , 'dd-MON-yyyy hh:mi:ssxff AM TZR'
                               )
           );

INSERT INTO users (
                      user_id
                    , locale_id
                    , first_name
                    , last_name
                    , registration_date
           )
    VALUES (
               2
             , 1
             , 'ROGER'
             , 'WOOTTEN'
             , TO_TIMESTAMP_TZ ('01-JAN-2004 11:34:21.000000 AM Japan'
                              , 'dd-MON-yyyy hh:mi:ssxff AM TZR'
                               )
           );

INSERT INTO users (
                      user_id
                    , locale_id
                    , first_name
                    , last_name
                    , registration_date
           )
    VALUES (
               3
             , 2
             , 'RANDY'
             , 'STAUFFACHER'
             , TO_TIMESTAMP_TZ (
                  '01-JAN-2004 11:34:21.000000 AM Europe/Warsaw'
                , 'dd-MON-yyyy hh:mi:ssxff AM TZR'
               )
           );

INSERT INTO users (
                      user_id
                    , locale_id
                    , first_name
                    , last_name
                    , registration_date
           )
    VALUES (4, 3, 'DARELL', 'SMITH', SYSTIMESTAMP
           );

INSERT INTO users (
                      user_id
                    , locale_id
                    , first_name
                    , last_name
                    , registration_date
           )
    VALUES (5, 3, 'SCOTT', 'ELDRIDGE', SYSTIMESTAMP
           );

INSERT INTO users (
                      user_id
                    , locale_id
                    , first_name
                    , last_name
                    , registration_date
           )
    VALUES (6, 2, 'SCOTT', 'BOUDREAUX', SYSTIMESTAMP
           );

INSERT INTO users (
                      user_id
                    , locale_id
                    , first_name
                    , last_name
                    , registration_date
           )
    VALUES (7, 2, 'CHARLES', 'MOFFETT', SYSTIMESTAMP
           );

INSERT INTO users (
                      user_id
                    , locale_id
                    , first_name
                    , last_name
                    , registration_date
           )
    VALUES (8, 3, 'AARON', 'BLACKMON', SYSTIMESTAMP
           );

INSERT INTO users (
                      user_id
                    , locale_id
                    , first_name
                    , last_name
                    , registration_date
           )
    VALUES (9, 1, 'TOM', 'DOEBLER', SYSTIMESTAMP
           );

PROMPT
PROMPT Create table author
PROMPT

CREATE TABLE author
(
   author_id    NUMBER (10) CONSTRAINT pk_author_id PRIMARY KEY
 , first_name   VARCHAR2 (30 CHAR)
 , last_name    VARCHAR2 (30 CHAR)
);

INSERT INTO author (author_id, first_name, last_name
                   )
    VALUES (1, 'STEVEN', 'FEUERSTEIN'
           );

INSERT INTO author (author_id, first_name, last_name
                   )
    VALUES (2, 'BILL', 'PRIBYL'
           );

INSERT INTO author (author_id, first_name, last_name
                   )
    VALUES (3, 'JONATHAN', 'GENNICK'
           );

INSERT INTO author (author_id, first_name, last_name
                   )
    VALUES (4, 'QUEST SOFTWARE', 'QUEST SOFTWARE'
           );

PROMPT
PROMPT Create table publication
PROMPT

CREATE TABLE publication
(
   publication_id      NUMBER (1) CONSTRAINT pk_publication_id PRIMARY KEY
 , title               VARCHAR2 (100 CHAR)
 , isbn                VARCHAR2 (100 CHAR)
 , pages               NUMBER (4)
 , short_description   VARCHAR2 (4000 CHAR)
 , url                 VARCHAR2 (50 CHAR)
 , price               NUMBER (10, 2)
 , locale_id           NUMBER (1)
         CONSTRAINT fk_locale_id REFERENCES locale (locale_id)
 , language            CHAR (2)
);

-- Oracle PL/SQL in English, Japanese and German

INSERT INTO publication (
                            publication_id
                          , title
                          , isbn
                          , pages
                          , short_description
                          , url
                          , price
                          , locale_id
                          , language
           )
    VALUES (
               1
             , 'Oracle PL/SQL Programming, 3rd Edition'
             , '0-596-00381-1'
             , 1018
             , 'Nearly a quarter-million PL/SQL programmers, novices and experienced developers alike, have found the first and second editions of Oracle PL/SQL Programming to be indispensable references to this powerful language. Packed with examples and recommendations, this book has helped everyone, from Oracle Forms developers to database administrators, make the most of PL/SQL.'
             , 'http://www.oreilly.com/catalog/oraclep3/'
             , 54.95
             , 3
             , 'EN'
           );

INSERT INTO publication (
                            publication_id
                          , title
                          , isbn
                          , pages
                          , short_description
                          , url
                          , price
                          , locale_id
                          , language
           )
    VALUES (
               2
             , 'Oracle PL/SQL??????? ??? ?3?'
             , '4-87311-056-4'
             , 672
             , 'Oracle??PL/SQL????????????????????????????PL/SQL??????? ?????????????????PL/SQL??????????????????????????????????????????????????????????????????????????????PL/SQL??????? ??? ?2?????????????????????????????????????????????'
             , 'http://www.oreilly.co.jp/BOOK/oraclep2_1/'
             , 5800
             , 1
             , 'JA'
           );

INSERT INTO publication (
                            publication_id
                          , title
                          , isbn
                          , pages
                          , short_description
                          , url
                          , price
                          , locale_id
                          , language
           )
    VALUES (
               3
             , 'Oracle PL/SQL Programmierung, 2. Auflage'
             , '3-89721-184-X'
             , 1084
             , 'Diese Übersetzung der 3. Auflage von Oracle PL/SQL Programming ist eine vollständige Neubearbeitung und Aktualisierung des Bestsellers von Steven Feuerstein und Bill Pribyl, die wir jetzt in einem Band herausbringen. Das Buch deckt nun auch die für das Internet optimierten PL/SQL-Versionen Oracle8i und Oracle9i (Release 2) ab, mit denen leistungsfähige Webdatenbanken entwickelt werden können und die mit Technologien wie Java, XML und objektorientierter Programmierung kombinierbar sind.'
             , 'http://www.oreilly.de/catalog/oraclep3ger/'
             , 64
             , 2
             , 'DE'
           );

-- Oracle SQL*Plus

INSERT INTO publication (
                            publication_id
                          , title
                          , isbn
                          , pages
                          , short_description
                          , url
                          , price
                          , locale_id
                          , language
           )
    VALUES (
               4
             , 'Oracle SQL*Plus Pocket Reference'
             , '0-596-00441-9'
             , 120
             , 'SQL*Plus is available at every Oracle site, from the largest data warehouse to the smallest single-user system, and it''s a critical tool for virtually every Oracle user. The Oracle SQL*Plus Pocket Reference boils down the most vital information from Gennick''s best-selling book, Oracle SQL*Plus: The Definitive Guide, into an accessible summary and works as a vital companion to the larger book. It summarizes all of the SQL*Plus syntax, including the syntax for the Oracle9i release.'
             , 'http://www.oreilly.com/catalog/orsqlpluspr2/'
             , 9.95
             , 3
             , 'EN'
           );

INSERT INTO publication (
                            publication_id
                          , title
                          , isbn
                          , pages
                          , short_description
                          , url
                          , price
                          , locale_id
                          , language
           )
    VALUES (
               5
             , 'Oracle SQL*Plus ????????????'
             , '4-87311-036-X'
             , 92
             , 'SQL*Plus??Oracle?????????????????????????????????????SQL*Plus ???????????????????????????????????SQL*Plus?????????????????????????????????????????????????????????????????'
             , 'http://www.oreilly.co.jp/BOOK/osqlpdkr/'
             , 1000
             , 1
             , 'JA'
           );

INSERT INTO publication (
                            publication_id
                          , title
                          , isbn
                          , pages
                          , short_description
                          , url
                          , price
                          , locale_id
                          , language
           )
    VALUES (
               6
             , 'Oracle SQL*Plus - kurz ~& gut, 2. Auflage'
             , '3-89721-252-8'
             , '126'
             , 'Oracle SQL*Plus - kurz ~& gut, 2. Auflage ist für jeden Oracle-Administrator und -Entwickler eine nützliche Informationsquelle für die Arbeit mit Oracles interaktivem Abfrage-Tool SQL*Plus. Das Buch bietet eine kompakte Zusammenfassung der Syntax von SQL*Plus sowie eine Referenz zu den SQL*Plus-Befehlen und -Formatelementen.'
             , 'http://www.oreilly.de/catalog/orsqlpluspr2ger/'
             , 8
             , 2
             , 'DE'
           );


-- DBA Checklist

INSERT INTO publication (
                            publication_id
                          , title
                          , isbn
                          , pages
                          , short_description
                          , url
                          , price
                          , locale_id
                          , language
           )
    VALUES (
               7
             , 'Oracle DBA Checklists Pocket Reference'
             , '0-596-00122-3'
             , 80
             , 'In a series of easy-to-use checklists, the Oracle DBA Checklists Pocket Reference summarizes the enormous number of tasks an Oracle DBA must perform. Each section takes the stress out of DBA problem solving with a step-by-step "cookbook" approach to presenting DBA quick-reference material, making it easy to find the information you need--and find it fast.'
             , 'http://www.oreilly.com/catalog/ordbacheck/'
             , 9.95
             , 3
             , 'JA'
           );

INSERT INTO publication (
                            publication_id
                          , title
                          , isbn
                          , pages
                          , short_description
                          , url
                          , price
                          , locale_id
                          , language
           )
    VALUES (
               8
             , 'Oracle DBA???????????????????'
             , '4-87311-087-4'
             , 84
             , 'Oracle??????DBMS???????????????????????????????????????????????????????????????·?????????????????????Oracle????????????????????????????????????????????????'
             , 'http://www.oreilly.co.jp/BOOK/oracheckdkr/'
             , 1100
             , 1
             , 'JA'
           );

INSERT INTO publication (
                            publication_id
                          , title
                          , isbn
                          , pages
                          , short_description
                          , url
                          , price
                          , locale_id
                          , language
           )
    VALUES (
               9
             , 'Oracle DBA Checklisten - kurz ~& gut'
             , '3-89721-236-6'
             , 88
             , 'Oracle DBA Checklisten - kurz ~& gut ist eine Kurzreferenz, die die große Aufgabenvielfalt von Oracle-Datenbankadministratoren in einfach zu nutzenden Checklisten zusammenfaßt und damit ein unverzichtbares Hilfsmittel für die tägliche Arbeit des DBAs darstellt. Immer wieder auftretende administrative Abläufe und Routineprozeduren können in dem handlichen Bändchen schnell nachgeschlagen und Schritt für Schritt durchgeführt werden. Das Buch deckt die drei wichtigsten Verantwortungsbereiche von Oracle-DBAs ab: Datenbankmanagement, Installation und Konfiguration und Netzwerkmanagement.'
             , 'http://www.oreilly.de/catalog/ordbacheckger/'
             , 8
             , 2
             , 'DE'
           );

PROMPT
PROMPT Create table store_location
PROMPT

CREATE TABLE store_location (city VARCHAR2 (50), country VARCHAR2 (50));

INSERT INTO store_location
    VALUES ('Asselfingen', 'DE'
           );

INSERT INTO store_location
    VALUES ('Aßlar', 'DE'
           );

INSERT INTO store_location
    VALUES ('Astert', 'DE'
           );

INSERT INTO store_location
    VALUES ('Außernzell', 'DE'
           );

INSERT INTO store_location
    VALUES ('Auufer', 'DE'
           );

INSERT INTO store_location
    VALUES ('Bösleben', 'DE'
           );

INSERT INTO store_location
    VALUES ('Boßdorf', 'DE'
           );

INSERT INTO store_location
    VALUES ('Bötersen', 'DE'
           );

INSERT INTO store_location
    VALUES ('Cremlingen', 'DE'
           );

INSERT INTO store_location
    VALUES ('Creußen', 'DE'
           );

INSERT INTO store_location
    VALUES ('Creuzburg', 'DE'
           );

INSERT INTO store_location
    VALUES ('Oberahr', 'DE'
           );

INSERT INTO store_location
    VALUES ('Ölsen', 'DE'
           );

INSERT INTO store_location
    VALUES ('Zudar', 'DE'
           );

INSERT INTO store_location
    VALUES ('Zühlen', 'DE'
           );

INSERT INTO store_location
    VALUES ('Ängelholm', 'SW'
           );

INSERT INTO store_location
    VALUES ('Abdêra', 'GR'
           );

INSERT INTO store_location
    VALUES ('???', 'JP'
           );

INSERT INTO store_location
    VALUES ('???', 'JP'
           );

INSERT INTO store_location
    VALUES ('???', 'JP'
           );

INSERT INTO store_location
    VALUES ('???', 'JP'
           );

COMMIT;

PROMPT
PROMPT Create Oracle Text indexes
PROMPT

-- ENGLISH LEXER

BEGIN
   ctx_ddl.create_preference ('english_lexer', 'basic_lexer');
   ctx_ddl.set_attribute ('english_lexer', 'printjoins', '_-');
   ctx_ddl.set_attribute ('english_lexer', 'index_themes', 'yes');
   ctx_ddl.set_attribute ('english_lexer', 'theme_language', 'english');
END;
/

-- GERMAN LEXER

BEGIN
   ctx_ddl.create_preference ('german_lexer', 'basic_lexer');
   ctx_ddl.set_attribute ('german_lexer', 'composite', 'german');
   ctx_ddl.set_attribute ('german_lexer', 'alternate_spelling', 'german');
END;
/

-- JAPANESE LEXER

BEGIN
   ctx_ddl.create_preference ('japan_lexer', 'japanese_lexer');
END;
/

-- MULTI_LEXER

BEGIN
   ctx_ddl.create_preference ('global_lexer', 'multi_lexer');
END;
/

-- ADD DEFAULT LEXER

BEGIN
   ctx_ddl.add_sub_lexer ('global_lexer', 'default', 'english_lexer');
END;
/

-- ADD SUB_LEXERS TO MULTI_LEXER

BEGIN
   ctx_ddl.add_sub_lexer ('global_lexer', 'german', 'german_lexer', 'de');
   ctx_ddl.add_sub_lexer ('global_lexer', 'ja', 'japan_lexer');
END;
/

-- CREATE THE INDEX

CREATE INDEX g11n_index
   ON publication (short_description)
   INDEXTYPE IS ctxsys.context
   PARAMETERS ( 'lexer global_lexer language column language' );

PROMPT
PROMPT Create functions
PROMPT


CREATE OR REPLACE FUNCTION city_order_by_func (v_order_by IN VARCHAR2)
   RETURN sys_refcursor
IS
   v_city   sys_refcursor;
BEGIN
   OPEN v_city FOR
        SELECT city
          FROM store_location
      ORDER BY NLSSORT (city, 'NLS_SORT=' || v_order_by);

   RETURN v_city;
END city_order_by_func;
/

show errors

CREATE OR REPLACE FUNCTION text_search_func (v_keyword IN VARCHAR2)
   RETURN sys_refcursor
IS
   v_title   sys_refcursor;
BEGIN
   OPEN v_title FOR
        SELECT title, language, score (1)
          FROM publication
         WHERE contains (short_description, v_keyword, 1) > 0
      ORDER BY score (1) DESC;

   RETURN v_title;
END text_search_func;
/

show errors

CREATE OR REPLACE FUNCTION `
   RETURN sys_refcursor
IS
   v_date   sys_refcursor;
BEGIN
   OPEN v_date FOR
      SELECT locale.locale_desc "Locale Description"
           , TO_CHAR (users.registration_date, locale.date_format)
                "Registration Date"
        FROM users, locale
       WHERE users.locale_id = locale.locale_id;

   RETURN v_date;
END date_format_func;
/

show errors

CREATE OR REPLACE FUNCTION date_format_lang_func
   RETURN sys_refcursor
IS
   v_date   sys_refcursor;
BEGIN
   OPEN v_date FOR
      SELECT locale.locale_desc "Locale Description"
           , TO_CHAR (users.registration_date
                    , locale.date_format
                    , 'NLS_DATE_LANGUAGE= ' || locale_desc
                     )
                "Registration Date"
        FROM users, locale
       WHERE users.locale_id = locale.locale_id;

   RETURN v_date;
END date_format_lang_func;
/

show errors

CREATE OR REPLACE FUNCTION date_ltz_lang_func
   RETURN sys_refcursor
IS
   v_date   sys_refcursor;
BEGIN
   OPEN v_date FOR
      SELECT locale.locale_desc
           , TO_CHAR (
                CAST (
                   users.registration_date AS TIMESTAMP WITH LOCAL TIME ZONE
                )
              , locale.date_format
              , 'NLS_DATE_LANGUAGE= ' || locale_desc
             )
                "Registration Date"
        FROM users, locale
       WHERE users.locale_id = locale.locale_id;

   RETURN v_date;
END date_ltz_lang_func;
/

show errors

CREATE OR REPLACE FUNCTION currency_conv_func
   RETURN sys_refcursor
IS
   v_currency   sys_refcursor;
BEGIN
   OPEN v_currency FOR
      SELECT pub.title "Title"
           , TO_CHAR (pub.price
                    , locale.currency_format
                    , 'NLS_CURRENCY=' || locale.currency_symbol
                     )
                "Price"
        FROM publication pub, locale
       WHERE pub.locale_id = locale.locale_id;

   RETURN v_currency;
END currency_conv_func;
/

show errors

CREATE OR REPLACE FUNCTION iso_currency_func
   RETURN sys_refcursor
IS
   v_currency   sys_refcursor;
BEGIN
   OPEN v_currency FOR
        SELECT title "Title"
             , TO_CHAR (pub.price
                      , locale.iso_currency_format
                      , 'NLS_ISO_CURRENCY=' || locale.iso_currency_name
                       )
                  "Price - ISO Format"
          FROM publication pub, locale
         WHERE pub.locale_id = locale.locale_id
      ORDER BY publication_id;

   RETURN v_currency;
END iso_currency_func;
/

show errors

CREATE OR REPLACE FUNCTION format_string (p_search IN VARCHAR2)
   RETURN VARCHAR2
AS
   -- Define an associative array
   TYPE token_table IS TABLE OF VARCHAR2 (500 CHAR)
                          INDEX BY PLS_INTEGER;

   -- Define an associative array variable
   v_token_array           token_table;

   v_temp_search_string    VARCHAR2 (500 CHAR);
   v_final_search_string   VARCHAR2 (500 CHAR);
   v_count                 PLS_INTEGER := 0;
   v_token_count           PLS_INTEGER := 0;
BEGIN
   v_temp_search_string := TRIM (UPPER (p_search));

   -- Find the max number of tokens
   v_token_count :=
        lengthc (v_temp_search_string)
      - lengthc (REPLACE (v_temp_search_string, ' ', ''))
      + 1;

   -- Populate the associative array
   FOR y IN 1 .. v_token_count
   LOOP
      v_count := v_count + 1;
      v_token_array (y) :=
         REGEXP_SUBSTR (v_temp_search_string, '[^[:space:]]+', 1, v_count);

      -- Handle reserved words
      v_token_array (y) := TRIM (v_token_array (y));

      IF v_token_array (y) IN ('ABOUT', 'WITHIN')
      THEN
         v_token_array (y) := '{' || v_token_array (y) || '}';
      END IF;
   END LOOP;

   v_count := 0;

   FOR y IN v_token_array.FIRST .. v_token_array.LAST
   LOOP
      v_count := v_count + 1;

      -- First token processed
      IF ( (v_token_array.LAST = v_count OR v_count = 1)
          AND v_token_array (y) IN ('AND', '&', 'OR', '|'))
      THEN
         v_final_search_string := v_final_search_string;
      ELSIF (v_count <> 1)
      THEN
         -- Separate by AND unless already present
         IF v_token_array (y) IN ('AND', '&', 'OR', '|')
            OR v_token_array (y - 1) IN ('AND', '&', 'OR', '|')
         THEN
            v_final_search_string :=
               v_final_search_string || ' ' || v_token_array (y);
         ELSE
            v_final_search_string :=
               v_final_search_string || ', ' || v_token_array (y);
         END IF;
      ELSE
         v_final_search_string := v_token_array (y);
      END IF;
   END LOOP;

   -- Escape special characters in the final string
   v_final_search_string :=
      TRIM(REPLACE (
              REPLACE (
                 REPLACE (REPLACE (v_final_search_string, ']', '\]')
                        , '['
                        , '\['
                         )
               , '&'
               , ' & '
              )
            , ';'
            , ' ; '
           ));

   RETURN (v_final_search_string);
END format_string;
/

SHOW ERRORS

SET PAUSE OFF

SPOOL OFF



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/