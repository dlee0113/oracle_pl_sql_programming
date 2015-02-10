/*
Oracle PL/SQL Programming 5th Edition

www.stevenfeuerstein.com/books

Objection creation and example scripts for Chapter 25

You will find below all non-trivial code snippets from the above chapter
that are NOT contained in their own files (as specified in the chapter),
plus any DDL object creation scripts required to get a clean compile
on the snippets.

Any references to Oracle's standard HR tables (employees, departments,
locations, regions, etc.) will NOT include the DDL creation scripts
in this file. Instead, run the hr_schema_install.sql script and all
those tables and related elements will be defined.
*/

/* RUN THE g11n.sql SCRIPT FIRST! */

SELECT parameter, VALUE
  FROM nls_database_parameters
 WHERE parameter IN ('NLS_CHARACTERSET', 'NLS_NCHAR_CHARACTERSE')
/

BEGIN
   DBMS_OUTPUT.put_line ('ASCII Character: ' || ASCIISTR ('A'));
   DBMS_OUTPUT.put_line ('Unicode Character: ' || ASCIISTR ('Ä'));
END;
/

DECLARE
   v_precomposed   VARCHAR2 (20) := UNISTR ('\00C4');
   v_decomposed    VARCHAR2 (20) := UNISTR ('A\0308');
BEGIN
   IF v_precomposed = v_decomposed
   THEN
      DBMS_OUTPUT.put_line ('==EQUAL==');
   ELSE
      DBMS_OUTPUT.put_line ('<>NOT EQUAL<>');
   END IF;
END;
/

DECLARE
   v_precomposed   VARCHAR2 (20) := UNISTR ('\00C4');
   v_decomposed    VARCHAR2 (20) := COMPOSE (UNISTR ('A\0308'));
BEGIN
   IF v_precomposed = v_decomposed
   THEN
      DBMS_OUTPUT.put_line ('==EQUAL==');
   ELSE
      DBMS_OUTPUT.put_line ('<>NOT EQUAL<>');
   END IF;
END;
/

DECLARE
   v_precomposed   VARCHAR2 (20) := ASCIISTR (DECOMPOSE ('Ä'));
   v_decomposed    VARCHAR2 (20) := 'A\0308';
BEGIN
   IF v_precomposed = v_decomposed
   THEN
      DBMS_OUTPUT.put_line ('==EQUAL==');
   ELSE
      DBMS_OUTPUT.put_line ('<>NOT EQUAL<>');
   END IF;
END;
/

DECLARE
   v_instr    NUMBER (2);
   v_instrb   NUMBER (2);
   v_instrc   NUMBER (2);
   v_instr2   NUMBER (2);
   v_instr4   NUMBER (2);
BEGIN
   SELECT INSTR (title, '[FIGS/ORACLEP4_IN_2402.GIF]')
        , INSTRB (title, '[FIGS/ORACLEP4_IN_2402.GIF]')
        , instrc (title, '[FIGS/ORACLEP4_IN_2402.GIF]')
        , instr2 (title, '[FIGS/ORACLEP4_IN_2402.GIF]')
        , instr4 (title, '[FIGS/ORACLEP4_IN_2402.GIF]')
     INTO v_instr, v_instrb, v_instrc, v_instr2, v_instr4
     FROM publication
    WHERE publication_id = 2;

   DBMS_OUTPUT.put_line ('INSTR of [FIGS/ORACLEP4_IN_2402.GIF]: ' || v_instr);
   DBMS_OUTPUT.put_line (
      'INSTRB of [FIGS/ORACLEP4_IN_2402.GIF]: ' || v_instrb
   );
   DBMS_OUTPUT.put_line (
      'INSTRC of [FIGS/ORACLEP4_IN_2402.GIF]: ' || v_instrc
   );
   DBMS_OUTPUT.put_line (
      'INSTR2 of [FIGS/ORACLEP4_IN_2402.GIF]: ' || v_instr2
   );
   DBMS_OUTPUT.put_line (
      'INSTR4 of [FIGS/ORACLEP4_IN_2402.GIF]: ' || v_instr4
   );
END;
/

DECLARE
   v_length    NUMBER (2);
   v_lengthb   NUMBER (2);
   v_lengthc   NUMBER (2);
   v_length2   NUMBER (2);
   v_length4   NUMBER (2);
BEGIN
   SELECT LENGTH (title)
        , LENGTHB (title)
        , lengthc (title)
        , length2 (title)
        , length4 (title)
     INTO v_length, v_lengthb, v_lengthc, v_length2, v_length4
     FROM publication
    WHERE publication_id = 2;

   DBMS_OUTPUT.put_line ('LENGTH of string: ' || v_length);
   DBMS_OUTPUT.put_line ('LENGTHB of string: ' || v_lengthb);
   DBMS_OUTPUT.put_line ('LENGTHC of string: ' || v_lengthc);
   DBMS_OUTPUT.put_line ('LENGTH2 of string: ' || v_length2);
   DBMS_OUTPUT.put_line ('LENGTH4 of string: ' || v_length4);
END;
/

DECLARE
   v_length   NUMBER (2);
BEGIN
   SELECT LENGTH (UNISTR ('A\0308'))
     INTO v_length
     FROM DUAL;

   DBMS_OUTPUT.put_line ('Decomposed string size using LENGTH: ' || v_length);

   SELECT lengthc (UNISTR ('A\0308'))
     INTO v_length
     FROM DUAL;

   DBMS_OUTPUT.put_line ('Decomposed string size using LENGTHC: ' || v_length
                        );
END;
/

DECLARE
   v_substr    VARCHAR2 (20);
   v_substrb   VARCHAR2 (20);
   v_substrc   VARCHAR2 (20);
   v_substr2   VARCHAR2 (20);
   v_substr4   VARCHAR2 (20);
BEGIN
   SELECT SUBSTR (title, 13, 4)
        , SUBSTRB (title, 13, 4)
        , substrc (title, 13, 4)
        , substr2 (title, 13, 4)
        , substr4 (title, 13, 4)
     INTO v_substr, v_substrb, v_substrc, v_substr2, v_substr4
     FROM publication
    WHERE publication_id = 2;

   DBMS_OUTPUT.put_line ('SUBSTR of string: ' || v_substr);
   DBMS_OUTPUT.put_line ('SUBSTRB of string: ' || v_substrb);
   DBMS_OUTPUT.put_line ('SUBSTRC of string: ' || v_substrc);
   DBMS_OUTPUT.put_line ('SUBSTR2 of string: ' || v_substr2);
   DBMS_OUTPUT.put_line ('SUBSTR4 of string: ' || v_substr4);
END;
/

DECLARE
   v_string   VARCHAR2 (20);
BEGIN
   SELECT UNISTR ('\0053\0074\0065\0076\0065\006E')
     INTO v_string
     FROM DUAL;

   DBMS_OUTPUT.put_line (v_string);
END;
/

DECLARE
   v_title   VARCHAR2 (30);
BEGIN
   SELECT title
     INTO v_title
     FROM publication
    WHERE publication_id = 2;

   DBMS_OUTPUT.put_line (v_title);
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (DBMS_UTILITY.format_error_stack);
END;
/

DECLARE
   v_length_in_bytes   NUMBER (2);
BEGIN
   SELECT LENGTHB (title)
     INTO v_length_in_bytes
     FROM publication
    WHERE publication_id = 2;

   DBMS_OUTPUT.put_line ('String size in bytes: ' || v_length_in_bytes);
END;
/

DECLARE
   v_title   VARCHAR2 (90);
BEGIN
   SELECT title
     INTO v_title
     FROM publication
    WHERE publication_id = 2;

   DBMS_OUTPUT.put_line (v_title);
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (DBMS_UTILITY.format_error_stack);
END;
/

DECLARE
   v_title   VARCHAR2 (30 CHAR);
BEGIN
   SELECT title
     INTO v_title
     FROM publication
    WHERE publication_id = 2;

   DBMS_OUTPUT.put_line (v_title);
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (DBMS_UTILITY.format_error_stack);
END;
/

SELECT parameter, VALUE
  FROM nls_session_parameters
 WHERE parameter = 'NLS_LENGTH_SEMANTICS'
/

SELECT name, VALUE
  FROM v$parameter
 WHERE name = 'nls_length_semantics'
/

ALTER SYSTEM SET nls_length_semantics = char
/

ALTER SESSION SET nls_length_semantics = char
/

DECLARE
   v_title   VARCHAR2 (30);
BEGIN
   SELECT title
     INTO v_title
     FROM publication
    WHERE publication_id = 2;

   DBMS_OUTPUT.put_line (v_title);
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (DBMS_UTILITY.format_error_stack);
END;
/

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

SELECT token_text
  FROM dr$g11n_index$i
/

DECLARE
   v_date_timestamp       TIMESTAMP (3) := SYSDATE;
   v_date_timestamp_tz    TIMESTAMP (3) WITH TIME ZONE := SYSDATE;
   v_date_timestamp_ltz   TIMESTAMP (3) WITH LOCAL TIME ZONE := SYSDATE;
BEGIN
   DBMS_OUTPUT.put_line ('TIMESTAMP:  ' || v_date_timestamp);
   DBMS_OUTPUT.put_line ('TIMESTAMP WITH TIME ZONE:  ' || v_date_timestamp_tz
                        );
   DBMS_OUTPUT.put_line (
      'TIMESTAMP WITH LOCAL TIME ZONE:  ' || v_date_timestamp_ltz
   );
END;
/

CREATE TABLE user_admin
(
   id           NUMBER (10) PRIMARY KEY
 , first_name   VARCHAR2 (10 CHAR)
 , last_name    VARCHAR2 (20 CHAR)
 , territory    VARCHAR2 (30 CHAR)
 , language     VARCHAR2 (30 CHAR)
)
/

BEGIN
   INSERT INTO user_admin
       VALUES (1, 'Stan', 'Smith', 'AMERICA', 'AMERICAN'
              );

   INSERT INTO user_admin
       VALUES (2, 'Robert', 'Hammon', NULL, 'SPANISH'
              );

   INSERT INTO user_admin
       VALUES (3, 'Anil', 'Venkat', 'INDIA', NULL
              );

   COMMIT;
END;
/

DECLARE
   -- Create array for the territory result set
   v_array   UTL_I18N.string_array;
   -- Create the variable to hold the user record
   v_user    user_admin%ROWTYPE;
BEGIN
   -- Populate the variable with the record for Anil
   SELECT *
     INTO v_user
     FROM user_admin
    WHERE id = 3;

   -- Retrieve a list of languages valid for the territory
   v_array := UTL_I18N.get_local_languages (v_user.territory);
   DBMS_OUTPUT.put (CHR (10));
   DBMS_OUTPUT.put_line ('=======================');
   DBMS_OUTPUT.put_line (
      'User: ' || v_user.first_name || ' ' || v_user.last_name
   );
   DBMS_OUTPUT.put_line ('Territory: ' || v_user.territory);
   DBMS_OUTPUT.put_line ('=======================');

   -- Loop through the array
   FOR y IN v_array.FIRST .. v_array.LAST
   LOOP
      DBMS_OUTPUT.put_line (v_array (y));
   END LOOP;
END;
/

DECLARE
   -- Create array for the territory result set
   v_array   UTL_I18N.string_array;
   -- Create the variable to hold the user record
   v_user    user_admin%ROWTYPE;
BEGIN
   -- Populate the variable with the record for Robert
   SELECT *
     INTO v_user
     FROM user_admin
    WHERE id = 2;

   -- Retrieve a list of territories valid for the language
   v_array := UTL_I18N.get_local_territories (v_user.language);
   DBMS_OUTPUT.put (CHR (10));
   DBMS_OUTPUT.put_line ('=======================');
   DBMS_OUTPUT.put_line (
      'User: ' || v_user.first_name || ' ' || v_user.last_name
   );
   DBMS_OUTPUT.put_line ('Language: ' || v_user.language);
   DBMS_OUTPUT.put_line ('=======================');

   -- Loop through the array
   FOR y IN v_array.FIRST .. v_array.LAST
   LOOP
      DBMS_OUTPUT.put_line (v_array (y));
   END LOOP;
END;
/

DECLARE
   v_bad_bad_variable   PLS_INTEGER;
   v_function_out       PLS_INTEGER;
   v_message            VARCHAR2 (500);
BEGIN
   v_bad_bad_variable := 'x';
EXCEPTION
   WHEN OTHERS
   THEN
      v_function_out :=
         UTL_LMS.GET_MESSAGE (06502, 'rdbms', 'ora', NULL, v_message);
      -- Output unformatted and formatted messages
      DBMS_OUTPUT.put (CHR (10));
      DBMS_OUTPUT.put_line ('Message - Not Formatted');
      DBMS_OUTPUT.put_line ('=======================');
      DBMS_OUTPUT.put_line (v_message);
      DBMS_OUTPUT.put (CHR (10));
      DBMS_OUTPUT.put_line ('Message - Formatted');
      DBMS_OUTPUT.put_line ('===================');
      DBMS_OUTPUT.put_line (
         UTL_LMS.format_message (v_message, ': The quick brown fox')
      );
END;
/