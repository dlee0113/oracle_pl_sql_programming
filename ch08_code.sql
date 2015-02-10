/*
Oracle PL/SQL Programming 5th Edition

www.stevenfeuerstein.com/books

Objection creation and example scripts for Chapter 8

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
   small_string      VARCHAR2 (4);
   line_of_text      VARCHAR2 (2000);
   feature_name      VARCHAR2 (100 BYTE);                   -- 100 byte string
   emp_name          VARCHAR2 (30 CHAR);                -- 30 character string
   --
   yes_or_no         CHAR (1) DEFAULT 'Y';
   line_of_text      CHAR (80 CHAR);            --Always a full 80 characters!
   whole_paragraph   CHAR (10000 BYTE);           --Think of all the spaces...
BEGIN
   NULL;
END;
/

BEGIN
   DBMS_OUTPUT.put_line (
      'Aren''t you glad you''re learning PL/SQL with O''Reilly?');
   DBMS_OUTPUT.put_line (
      q'!Aren't you glad you're learning PL/SQL with O'Reilly?!');
   DBMS_OUTPUT.put_line (
      q'{Aren't you glad you're learning PL/SQL with O'Reilly?}');
   DBMS_OUTPUT.put_line (n'Pils vom faﬂ: 1Ä');
   DBMS_OUTPUT.put_line (u' Pils vom fa\00DF: 1\20AC');
END;
/

DECLARE
   jonathans_motto   VARCHAR2 (50);
BEGIN
   jonathans_motto := 'Brighten the corner where you are.';
END;
/

BEGIN
   DBMS_OUTPUT.put_line (LENGTH ('Brighten the corner where you are.'));
END;
/

DROP TABLE company
/

CREATE TABLE company
(
   name       VARCHAR2 (100),
   address1   VARCHAR2 (100),
   address2   VARCHAR2 (100),
   city       VARCHAR2 (100),
   state      VARCHAR2 (100),
   zipcode    VARCHAR2 (100)
)
/

BEGIN
   INSERT INTO company
        VALUES ('Harold Henderson',
                '22 BUNKER COURT',
                NULL,
                'WYANDANCH',
                'MN',
                '66557');

   COMMIT;
END;
/

SELECT    name
       || CHR (10)
       || address1
       || CHR (10)
       || address2
       || CHR (10)
       || city
       || ', '
       || state
       || ' '
       || zipcode
          AS company_address
  FROM company
/

SELECT    name
       || NVL2 (address1, CHR (10) || address1, '')
       || NVL2 (address2, CHR (10) || address2, '')
       || CHR (10)
       || city
       || ', '
       || state
       || ' '
       || zipcode
          AS company_address
  FROM company
/

BEGIN
   DBMS_OUTPUT.put_line (ASCII ('J'));
END;
/

DECLARE
   x   VARCHAR2 (100);
BEGIN
   x := 'abc' || 'def' || 'ghi';
   DBMS_OUTPUT.put_line (x);
   --
   x := CONCAT (CONCAT ('abc', 'def'), 'ghi');
   DBMS_OUTPUT.put_line (x);
END;
/

DECLARE
   name1   VARCHAR2 (30) := 'Andrew Sears';
   name2   VARCHAR2 (30) := 'ANDREW SEARS';
BEGIN
   IF LOWER (name1) = LOWER (name2)
   THEN
      DBMS_OUTPUT.put_line ('The names are the same.');
   END IF;
END;
/

SELECT LEAST ('JONATHON', 'Jonathon', 'jon') FROM DUAL
/

ALTER SESSION SET nls_comp=linguistic
/
ALTER SESSION SET nls_sort=binary_ci
/

SELECT LEAST ('JONATHON', 'Jonathon', 'jon') FROM DUAL
/

BEGIN
   IF 'Jonathon' = 'JONATHON'
   THEN
      DBMS_OUTPUT.put_line ('It is true!');
   END IF;
END;
/

DROP INDEX last_name_ci
/

CREATE INDEX last_name_ci
   ON employees (NLSSORT (last_name, 'NLS_SORT=BINARY_CI'))
/

DECLARE
   name   VARCHAR2 (30) := 'MATT williams';
BEGIN
   DBMS_OUTPUT.put_line (INITCAP (name));
END;
/

DECLARE
   name   VARCHAR2 (30) := 'JOE mcwilliams';
BEGIN
   DBMS_OUTPUT.put_line (INITCAP (name));
END;
/

DECLARE
   names            VARCHAR2 (60) := 'Anna,Matt,Joe,Nathan,Andrew,Aaron,Jeff';
   comma_location   NUMBER := 0;
BEGIN
   LOOP
      comma_location := INSTR (names, ',', comma_location + 1);
      EXIT WHEN comma_location = 0;
      DBMS_OUTPUT.put_line (comma_location);
   END LOOP;
END;
/

DECLARE
   names            VARCHAR2 (60) := 'Anna,Matt,Joe,Nathan,Andrew,Aaron,Jeff';
   names_adjusted   VARCHAR2 (61);
   comma_location   NUMBER := 0;
   prev_location    NUMBER := 0;
BEGIN
   --Stick a comma after the final name
   names_adjusted := names || ',';

   LOOP
      comma_location := INSTR (names_adjusted, ',', comma_location + 1);
      EXIT WHEN comma_location = 0;
      DBMS_OUTPUT.put_line (
         SUBSTR (names_adjusted,
                 prev_location + 1,
                 comma_location - prev_location - 1));
      prev_location := comma_location;
   END LOOP;
END;
/

DECLARE
   names   VARCHAR2 (60) := 'Anna,Matt,Joe,Nathan,Andrew,Aaron,Jeff';
BEGIN
   DBMS_OUTPUT.put_line (REPLACE (names, ',', CHR (10)));
END;
/

DECLARE
   a   VARCHAR2 (30) := 'Jeff';
   b   VARCHAR2 (30) := 'Eric';
   c   VARCHAR2 (30) := 'Andrew';
   d   VARCHAR2 (30) := 'Aaron';
   e   VARCHAR2 (30) := 'Matt';
   f   VARCHAR2 (30) := 'Joe';
BEGIN
   DBMS_OUTPUT.put_line (RPAD (a, 10) || LPAD (b, 10));
   DBMS_OUTPUT.put_line (RPAD (c, 10) || LPAD (d, 10));
   DBMS_OUTPUT.put_line (RPAD (e, 10) || LPAD (f, 10));
   --
   DBMS_OUTPUT.put_line (RPAD (a, 10, '.') || LPAD (b, 10, '.'));
   DBMS_OUTPUT.put_line (RPAD (c, 10, '.') || LPAD (d, 10, '.'));
   DBMS_OUTPUT.put_line (RPAD (e, 10, '.') || LPAD (f, 10, '.'));
   --
   DBMS_OUTPUT.put_line (RPAD (a, 10, '-~-') || LPAD (b, 10, '-~-'));
   DBMS_OUTPUT.put_line (RPAD (c, 10, '-~-') || LPAD (d, 10, '-~-'));
   DBMS_OUTPUT.put_line (RPAD (e, 10, '-~-') || LPAD (f, 10, '-~-'));
   --
   DBMS_OUTPUT.put_line (RPAD (a, 4) || LPAD (b, 4));
   DBMS_OUTPUT.put_line (RPAD (c, 4) || LPAD (d, 4));
   DBMS_OUTPUT.put_line (RPAD (e, 4) || LPAD (f, 4));
END;
/

DECLARE
   a   VARCHAR2 (40) := 'This sentence has too many periods......';
   b   VARCHAR2 (40) := 'The number 1';
BEGIN
   DBMS_OUTPUT.put_line (RTRIM (a, '.'));
   DBMS_OUTPUT.put_line (
      LTRIM (b, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz'));
END;
/

DECLARE
   x   VARCHAR2 (30) := '.....Hi there!.....';
BEGIN
   DBMS_OUTPUT.put_line (TRIM (LEADING '.' FROM x));
   DBMS_OUTPUT.put_line (TRIM (TRAILING '.' FROM x));
   DBMS_OUTPUT.put_line (TRIM (BOTH '.' FROM x));

   --The default is to trim from both sides
   DBMS_OUTPUT.put_line (TRIM ('.' FROM x));

   --The default trim character is the space:
   DBMS_OUTPUT.put_line (TRIM (x));
END;
/

DECLARE
   names             VARCHAR2 (60) := 'Anna,Matt,Joe,Nathan,Andrew,Jeff,Aaron';
   names_adjusted    VARCHAR2 (61);
   comma_delimited   BOOLEAN;
BEGIN
   --Look for the pattern
   comma_delimited := REGEXP_LIKE (names, '^([a-z A-Z]*,)+([a-z A-Z]*){1}$');

   --Display the result
   DBMS_OUTPUT.put_line (
      CASE comma_delimited
         WHEN TRUE THEN 'We have a delimited list!'
         ELSE 'The pattern does not match.'
      END);
END;
/

DECLARE
   names             VARCHAR2 (60) := 'Anna,Matt,Joe,Nathan,Andrew,Jeff,Aaron';
   names_adjusted    VARCHAR2 (61);
   comma_delimited   BOOLEAN;
   j_location        NUMBER;
BEGIN
   --Look for the pattern
   comma_delimited := REGEXP_LIKE (names, '^([a-z ]*,)+([a-z ]*)$', 'i');

   --Only do more if we do, in fact, have a comma-delimited list.
   IF comma_delimited
   THEN
      j_location := REGEXP_INSTR (names, 'A[a-z]*[^aeiou],|A[a-z]*[^aeiou]$');
      DBMS_OUTPUT.put_line (j_location);
   END IF;
END;
/

DECLARE
   contact_info    VARCHAR2 (200) := '
    address:
    1060 W. Addison St.
    Chicago, IL 60613
    home 773-555-5253
  ';
   phone_pattern   VARCHAR2 (90)
      := '\(?\d{3}\)?[[:space:]\.\-]?\d{3}[[:space:]\.\-]?\d{4}';
BEGIN
   DBMS_OUTPUT.put_line (   'The phone number is: '
                         || REGEXP_SUBSTR (contact_info,
                                           phone_pattern,
                                           1,
                                           1));
END;
/

DECLARE
   contact_info         VARCHAR2 (200) := '
        address:
        1060 W. Addison St.
        Chicago, IL 60613
        home 773-555-5253
        work (312) 555-1234
        cell 224.555.2233
        ';
   phone_pattern        VARCHAR2 (90)
      := '\(?(\d{3})\)?[[:space:]\.\-]?\d{3}[[:space:]\.\-]?\d{4}';
   contains_phone_nbr   BOOLEAN;
   phone_number         VARCHAR2 (15);
   phone_counter        NUMBER;
   area_code            VARCHAR2 (3);
BEGIN
   contains_phone_nbr := REGEXP_LIKE (contact_info, phone_pattern);

   IF contains_phone_nbr
   THEN
      phone_counter := 1;
      DBMS_OUTPUT.put_line ('The phone numbers are:');

      LOOP
         phone_number :=
            REGEXP_SUBSTR (contact_info,
                           phone_pattern,
                           1,
                           phone_counter);
         EXIT WHEN phone_number IS NULL;         -- NULL means no more matches
         DBMS_OUTPUT.put_line (phone_number);
         phone_counter := phone_counter + 1;
      END LOOP;

      phone_counter := 1;
      DBMS_OUTPUT.put_line ('The area codes are:');

      LOOP
         area_code :=
            REGEXP_SUBSTR (contact_info,
                           phone_pattern,
                           1,
                           phone_counter,
                           'i',
                           1);
         EXIT WHEN area_code IS NULL;
         DBMS_OUTPUT.put_line (area_code);
         phone_counter := phone_counter + 1;
      END LOOP;
   END IF;
END;
/

DECLARE
   contact_info    VARCHAR2 (200) := '
        address:
        1060 W. Addison St.
        Chicago, IL 60613
        home 773-555-5253
        work (312) 123-4567';
   phone_pattern   VARCHAR2 (90)
      := '\(?(\d{3})\)?[[:space:]\.\-]?(\d{3})[[:space:]\.\-]?\d{4}';
BEGIN
   DBMS_OUTPUT.put_line (
         'There are '
      || REGEXP_COUNT (contact_info, phone_pattern)
      || ' phone numbers');
END;
/

DECLARE
   names             VARCHAR2 (60) := 'Anna,Matt,Joe,Nathan,Andrew,Jeff,Aaron';
   names_adjusted    VARCHAR2 (61);
   comma_delimited   BOOLEAN;
   extracted_name    VARCHAR2 (60);
   name_counter      NUMBER;
BEGIN
   --Look for the pattern
   comma_delimited := REGEXP_LIKE (names, '^([a-z ]*,)+([a-z ]*){1}$', 'i');

   --Only do more if we do, in fact, have a comma-delimited list.
   IF comma_delimited
   THEN
      names :=
         REGEXP_REPLACE (names,
                         '([a-z A-Z]*),([a-z A-Z]*),',
                         '\1,\2' || CHR (10));
   END IF;

   DBMS_OUTPUT.put_line (names);
END;
/

DECLARE
   names             VARCHAR2 (60) := 'Anna,Matt,Joe,Nathan,Andrew,Jeff,Aaron';
   names_adjusted    VARCHAR2 (61);
   comma_delimited   BOOLEAN;
   extracted_name    VARCHAR2 (60);
   name_counter      NUMBER;
BEGIN
   --Look for the pattern
   comma_delimited := REGEXP_LIKE (names, '^([a-z ]*,)+([a-z ]*){1}$', 'i');

   --Only do more if we do, in fact, have a comma-delimited list.
   IF comma_delimited
   THEN
      names :=
         REGEXP_REPLACE (names,
                         '([a-z A-Z]*),([a-z A-Z]*),',
                         '\1,\2' || CHR (10));
   END IF;

   DBMS_OUTPUT.put_line (names);
END;
/

DECLARE
   names   VARCHAR2 (60) := 'Anna,Matt,Joe,Nathan,Andrew,Jeff,Aaron';
BEGIN
   DBMS_OUTPUT.put_line (REGEXP_SUBSTR (names, '(.*?,)'));
END;
/

DROP TABLE company
/

CREATE TABLE company
(
   company_id     INTEGER,
   company_name   VARCHAR2 (100)
)
/

CREATE SEQUENCE company_id_seq
/

DECLARE
   comp_id#    NUMBER;
   comp_name   CHAR (20) := 'ACME SHOWERS';
BEGIN
   SELECT company_id_seq.NEXTVAL INTO comp_id# FROM DUAL;

   INSERT INTO company (company_id, company_name)
        VALUES (comp_id#, comp_name);
END;
/

DECLARE
   company_name                   CHAR (30) := 'Feuerstein and Friends';
   char_parent_company_name       CHAR (35) := 'Feuerstein and Friends';
   varchar2_parent_company_name   VARCHAR2 (35) := 'Feuerstein and Friends';
BEGIN
   --Compare two CHARs, so blank-padding is used
   IF company_name = char_parent_company_name
   THEN
      DBMS_OUTPUT.put_line ('first comparison is TRUE');
   ELSE
      DBMS_OUTPUT.put_line ('first comparison is FALSE');
   END IF;

   --Compare a CHAR and a VARCHAR2, so nonblank-padding is used
   IF company_name = varchar2_parent_company_name
   THEN
      DBMS_OUTPUT.put_line ('second comparison is TRUE');
   ELSE
      DBMS_OUTPUT.put_line ('second comparison is FALSE');
   END IF;
END;
/