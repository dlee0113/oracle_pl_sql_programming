/*
Oracle PL/SQL Programming 5th Edition

www.stevenfeuerstein.com/books

Objection creation and example scripts for Chapter 26

You will find below all non-trivial code snippets from the above chapter
that are NOT contained in their own files (as specified in the chapter),
plus any DDL object creation scripts required to get a clean compile
on the snippets.

Any references to Oracle's standard HR tables (employees, departments,
locations, regions, etc.) will NOT include the DDL creation scripts
in this file. Instead, run the hr_schema_install.sql script and all
those tables and related elements will be defined.
*/

/*
| The purpose of this script is to demonstrate the features
| and syntax--not to do anything else particularly useful.
|
| In order to run this, you will need the DBA to grant you the
| following privileges:
|
|    CONNECT, CREATE TABLE, CREATE TYPE, CREATE PROCEDURE
|
| You will also need some unused space quota on your default tablespace.
|
| This version of the script was designed to work with 9i Release 2.
|
| You may want to SET ECHO ON and SPOOL to some convenient output file
| in order to examine the code and its results together.
|
| WARNING: Examine the DROP statements -- be sure you have no "real" 
| objects matching these names.
*/

SET SERVEROUT ON SIZE 1000000
SET LINESIZE 80
SET PAGESIZE 25
SET PAUSE OFF

WHENEVER SQLERROR CONTINUE

COLUMN column_name FORMAT A30
COLUMN data_type FORMAT A30
COLUMN value(c).id FORMAT 99999
COLUMN value(c).print() FORMAT A60 WORD_WRAP
DROP TABLE catalog_history;
DROP TYPE subject_names_t FORCE;
DROP TABLE catalog_items;
DROP TABLE subjects;
DROP TYPE subject_refs_t FORCE;
DROP TYPE subject_t FORCE;
DROP TYPE book_t FORCE;
DROP TYPE serial_t FORCE;
DROP TYPE catalog_item_t FORCE;

/*------------------------------------------------------------*/

/* 
| ........here begins the material in the chapter .....  
|  (with the addition of some SHOW ERR commands)
*/

/*------------------------------------------------------------*/

CREATE OR REPLACE TYPE catalog_item_t AS OBJECT
   (id INTEGER
  , title VARCHAR2 (4000)
  , NOT INSTANTIABLE MEMBER FUNCTION ck_digit_okay
       RETURN BOOLEAN
  , MEMBER FUNCTION PRINT
       RETURN VARCHAR2
   )
   NOT INSTANTIABLE
   NOT FINAL;
/

SHOW ERR

/*------------------------------------------------------------*/

CREATE OR REPLACE TYPE book_t
   UNDER catalog_item_t
   (isbn VARCHAR2 (13)
  , pages INTEGER
  , CONSTRUCTOR FUNCTION book_t (id    IN INTEGER DEFAULT NULL
                               , title IN VARCHAR2 DEFAULT NULL
                               , isbn  IN VARCHAR2 DEFAULT NULL
                               , pages IN INTEGER DEFAULT NULL
                                )
       RETURN SELF AS RESULT
  , OVERRIDING MEMBER FUNCTION ck_digit_okay
       RETURN BOOLEAN
  , OVERRIDING MEMBER FUNCTION PRINT
       RETURN VARCHAR2
   );
/

SHOW ERR

/*------------------------------------------------------------*/

CREATE OR REPLACE TYPE BODY book_t
AS
   CONSTRUCTOR FUNCTION book_t (id    IN INTEGER
                              , title IN VARCHAR2
                              , isbn  IN VARCHAR2
                              , pages IN INTEGER
                               )
      RETURN SELF AS RESULT
   IS
   BEGIN
      self.id := id;
      self.title := title;
      self.isbn := isbn;
      self.pages := pages;

      IF isbn IS NULL OR self.ck_digit_okay
      THEN
         RETURN;
      ELSE
         raise_application_error (-20000
                                , 'ISBN ' || isbn || ' has bad check digit'
                                 );
      END IF;
   END;

   OVERRIDING MEMBER FUNCTION ck_digit_okay
      RETURN BOOLEAN
   IS
      subtotal      PLS_INTEGER := 0;
      isbn_digits   VARCHAR2 (10);
   BEGIN
      /* remove dashes and spaces */
      isbn_digits := REPLACE (REPLACE (self.isbn, '-'), ' ');

      IF LENGTH (isbn_digits) != 10
      THEN
         RETURN FALSE;
      END IF;

      FOR nth_digit IN 1 .. 9
      LOOP
         subtotal :=
            subtotal
            + (11 - nth_digit)
              * TO_NUMBER (SUBSTR (isbn_digits, nth_digit, 1));
      END LOOP;

      /* check digit can be 'X' which has value of 10 */
      IF UPPER (SUBSTR (isbn_digits, 10, 1)) = 'X'
      THEN
         subtotal := subtotal + 10;
      ELSE
         subtotal := subtotal + TO_NUMBER (SUBSTR (isbn_digits, 10, 1));
      END IF;

      RETURN MOD (subtotal, 11) = 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FALSE;
   END;

   OVERRIDING MEMBER FUNCTION PRINT
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN    'id='
             || id
             || '; title='
             || title
             || '; isbn='
             || isbn
             || '; pages='
             || pages;
   END;
END;
/

SHOW ERR

/*------------------------------------------------------------*/

DECLARE
   generic_item   catalog_item_t;
   abook          book_t;
BEGIN
   abook :=
      NEW book_t (title => 'Out of the Silent Planet', isbn => '0-6848-238-02');
   generic_item := abook;
   DBMS_OUTPUT.put_line ('BOOK: ' || abook.PRINT ());
   DBMS_OUTPUT.put_line ('ITEM: ' || generic_item.PRINT ());
END;
/

/*---------BEGIN EXTRA CODE NOT IN BOOK-----------------------*/

/*------------------------------------------------------------*/

CREATE OR REPLACE TYPE serial_t
   UNDER catalog_item_t
   (issn VARCHAR2 (10)
  , open_or_closed VARCHAR2 (1)
  , CONSTRUCTOR FUNCTION serial_t (id             IN INTEGER DEFAULT NULL
                                 , title          IN VARCHAR2 DEFAULT NULL
                                 , issn           IN VARCHAR2 DEFAULT NULL
                                 , open_or_closed IN VARCHAR2 DEFAULT NULL
                                  )
       RETURN SELF AS RESULT
  , OVERRIDING MEMBER FUNCTION ck_digit_okay
       RETURN BOOLEAN
  , OVERRIDING MEMBER FUNCTION PRINT
       RETURN VARCHAR2
   )
   NOT FINAL;
/

SHOW ERR

/*-----------END EXTRA CODE NOT IN BOOK-----------------------*/


/*------------------------------------------------------------*/

CREATE OR REPLACE TYPE BODY serial_t
AS
   CONSTRUCTOR FUNCTION serial_t (id             IN INTEGER
                                , title          IN VARCHAR2
                                , issn           IN VARCHAR2
                                , open_or_closed IN VARCHAR2
                                 )
      RETURN SELF AS RESULT
   IS
   BEGIN
      self.id := id;
      self.title := title;
      self.issn := issn;
      self.open_or_closed := open_or_closed;

      IF issn IS NULL OR self.ck_digit_okay
      THEN
         RETURN;
      ELSE
         raise_application_error (-20000
                                , 'ISSN ' || issn || ' has bad check digit'
                                 );
      END IF;
   END;

   OVERRIDING MEMBER FUNCTION ck_digit_okay
      RETURN BOOLEAN
   IS
      subtotal      PLS_INTEGER := 0;
      issn_digits   VARCHAR2 (8);
   BEGIN
      issn_digits := REPLACE (REPLACE (self.issn, '-'), ' ');

      IF LENGTH (issn_digits) != 8
      THEN
         RETURN FALSE;
      END IF;

      FOR nth_digit IN 1 .. 7
      LOOP
         subtotal :=
            subtotal
            + (9 - nth_digit)
              * TO_NUMBER (SUBSTR (issn_digits, nth_digit, 1));
      END LOOP;

      /* check digit can be 'X' which has value of 10 */
      IF UPPER (SUBSTR (issn_digits, 8, 1)) = 'X'
      THEN
         subtotal := subtotal + 10;
      ELSE
         subtotal := subtotal + TO_NUMBER (SUBSTR (issn_digits, 8, 1));
      END IF;

      RETURN MOD (subtotal, 11) = 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FALSE;
   END;

   OVERRIDING MEMBER FUNCTION PRINT
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN    'id='
             || id
             || '; title='
             || title
             || '; issn='
             || issn
             || '; open_or_closed='
             || CASE open_or_closed
                   WHEN 'O' THEN 'Open'
                   WHEN 'C' THEN 'Closed'
                   ELSE NULL
                END;
   END;
END;
/

SHOW ERR


/*------------------------------------------------------------*/

DECLARE
   generic_item   catalog_item_t;
   abook          book_t;
   ajournal       serial_t;
BEGIN
   abook :=
      NEW book_t (id => 10001
                , title => 'Learning Oracle PL/SQL'
                , isbn => '0-596-00180-0'
                , pages => 450
                 );
   generic_item := abook;

   IF generic_item.ck_digit_okay
   THEN
      DBMS_OUTPUT.put_line ('a-okay, boss');
   ELSE
      DBMS_OUTPUT.put_line ('try again, dude');
   END IF;

   ajournal :=
      NEW serial_t (id => 10002
                  , title => 'Time'
                  , issn => '0040-781X'
                  , open_or_closed => 'O'
                   );
   generic_item := ajournal;

   IF generic_item.ck_digit_okay
   THEN
      DBMS_OUTPUT.put_line ('a-okay, boss');
   ELSE
      DBMS_OUTPUT.put_line ('try again, dude');
   END IF;
END;
/

/*------------------------------------------------------------*/

CREATE TABLE catalog_items OF catalog_item_t
(
   CONSTRAINT catalog_items_pk PRIMARY KEY (id)
)
/* OBJECT IDENTIFIER IS PRIMARY KEY */;

/*------------------------------------------------------------*/

SELECT column_name, data_type, hidden_column, virtual_column
  FROM user_tab_cols
 WHERE table_name = 'CATALOG_ITEMS';

/*------------------------------------------------------------*/

INSERT INTO catalog_items
    VALUES (NEW book_t (10003, 'Perelandra', '0-684-82382-9', 222)
           );

INSERT INTO catalog_items
    VALUES (NEW serial_t (10004, 'Time', '0040-781X', 'O')
           );

COMMIT;

/*------------------------------------------------------------*/

SELECT VALUE (c)
  FROM catalog_items c;

/*------------------------------------------------------------*/

SELECT VALUE (c).id, VALUE (c).PRINT ()
  FROM catalog_items c;

/*------------------------------------------------------------*/

DECLARE
   catalog_item   catalog_item_t;

   CURSOR ccur
   IS
      SELECT VALUE (c)
        FROM catalog_items c;
BEGIN
   OPEN ccur;

   FETCH ccur
   INTO catalog_item;

   DBMS_OUTPUT.put_line ('I fetched item #' || catalog_item.id);

   CLOSE ccur;
END;
/

/*------------------------------------------------------------*/

/* 
| This example modified from first printing of book, which
| is a bit confusing.
*/

UPDATE catalog_items c
   SET c =
          NEW book_t (c.id, c.title, (SELECT TREAT (VALUE (y) AS book_t).isbn
                                        FROM catalog_items y
                                       WHERE id = 10003), 1000)
 WHERE id = 10003;

ROLLBACK;


/*------------------------------------------------------------*/

DECLARE
   book           book_t;
   catalog_item   catalog_item_t := NEW book_t ();
BEGIN
   book := TREAT (catalog_item AS book_t);
END;
/


DECLARE
   abook   book_t;

   CURSOR ccur
   IS
      SELECT TREAT (VALUE (c) AS book_t)
        FROM catalog_items c
       WHERE VALUE (c) IS OF (book_t);
BEGIN
   OPEN ccur;

   FETCH ccur
   INTO abook;

   DBMS_OUTPUT.put_line ('I fetched a book with ISBN ' || abook.isbn);

   CLOSE ccur;
END;
/


DECLARE
   CURSOR ccur
   IS
      SELECT VALUE (c) item
        FROM catalog_items c;

   arec   ccur%ROWTYPE;
BEGIN
   FOR arec IN ccur
   LOOP
      CASE
         WHEN arec.item IS OF (book_t)
         THEN
            DBMS_OUTPUT.put_line (
               'Found a book with ISBN ' || TREAT (arec.item AS book_t).isbn
            );
         WHEN arec.item IS OF (serial_t)
         THEN
            DBMS_OUTPUT.put_line('Found a serial with ISSN '
                                 || TREAT (arec.item AS serial_t).issn);
         ELSE
            DBMS_OUTPUT.put_line ('Found unknown catalog item');
      END CASE;
   END LOOP;
END;
/

/*------------------------------------------------------------*/
ALTER TYPE catalog_item_t
   ADD ATTRIBUTE publication_date varchar2(400)
   CASCADE INCLUDING TABLE DATA;

/* Note:
|| You may need to disconnect and reconnect in order to see
|| the next describe
*/

DESC catalog_item_t

DESC catalog_items
ALTER TYPE book_t
   DROP CONSTRUCTOR FUNCTION book_t (id integer DEFAULT NULL,
      title varchar2 DEFAULT NULL,
      isbn varchar2 DEFAULT NULL,
      pages integer DEFAULT NULL)
      RETURN SELF AS RESULT
   CASCADE;
ALTER TYPE book_t
   ADD CONSTRUCTOR FUNCTION book_t (id integer DEFAULT NULL,
      title varchar2 DEFAULT NULL,
      publication_date varchar2 DEFAULT NULL,
      isbn varchar2 DEFAULT NULL,
      pages integer DEFAULT NULL)
      RETURN SELF AS RESULT
   CASCADE;

/*---------BEGIN EXTRA CODE NOT IN BOOK-----------------------*/

CREATE OR REPLACE TYPE BODY book_t
AS
   CONSTRUCTOR FUNCTION book_t (id               IN INTEGER
                              , title            IN VARCHAR2
                              , publication_date IN VARCHAR2
                              , isbn             IN VARCHAR2
                              , pages            IN INTEGER
                               )
      RETURN SELF AS RESULT
   IS
   BEGIN
      self.id := id;
      self.title := title;
      self.publication_date := publication_date;
      self.isbn := isbn;
      self.pages := pages;

      IF isbn IS NULL OR self.ck_digit_okay
      THEN
         RETURN;
      ELSE
         raise_application_error (-20000
                                , 'ISBN ' || isbn || ' has bad check digit'
                                 );
      END IF;
   END;

   OVERRIDING MEMBER FUNCTION ck_digit_okay
      RETURN BOOLEAN
   IS
      subtotal      PLS_INTEGER := 0;
      isbn_digits   VARCHAR2 (10);
   BEGIN
      /* remove dashes and spaces */
      isbn_digits := REPLACE (REPLACE (self.isbn, '-'), ' ');

      IF LENGTH (isbn_digits) != 10
      THEN
         RETURN FALSE;
      END IF;

      FOR nth_digit IN 1 .. 9
      LOOP
         subtotal :=
            subtotal
            + (11 - nth_digit)
              * TO_NUMBER (SUBSTR (isbn_digits, nth_digit, 1));
      END LOOP;

      /* check digit can be 'X' which has value of 10 */
      IF UPPER (SUBSTR (isbn_digits, 10, 1)) = 'X'
      THEN
         subtotal := subtotal + 10;
      ELSE
         subtotal := subtotal + TO_NUMBER (SUBSTR (isbn_digits, 10, 1));
      END IF;

      RETURN MOD (subtotal, 11) = 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FALSE;
   END;

   OVERRIDING MEMBER FUNCTION PRINT
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN    'id='
             || id
             || '; title='
             || title
             || '; publication_date='
             || publication_date
             || '; isbn='
             || isbn
             || '; pages='
             || pages;
   END;
END;
/

ALTER TYPE serial_t
   DROP CONSTRUCTOR FUNCTION serial_t (id integer DEFAULT NULL,
      title varchar2 DEFAULT NULL,
      issn varchar2 DEFAULT NULL,
      open_or_closed varchar2 DEFAULT NULL)
      RETURN SELF AS RESULT
   CASCADE;
ALTER TYPE serial_t
   ADD CONSTRUCTOR FUNCTION serial_t (id integer DEFAULT NULL,
      title varchar2 DEFAULT NULL,
      publication_date varchar2 DEFAULT NULL,
      issn varchar2 DEFAULT NULL,
      open_or_closed varchar2 DEFAULT NULL)
      RETURN SELF AS RESULT
   CASCADE;

CREATE OR REPLACE TYPE BODY serial_t
AS
   CONSTRUCTOR FUNCTION serial_t (id                  INTEGER
                                , title            IN VARCHAR2
                                , publication_date IN VARCHAR2
                                , issn             IN VARCHAR2
                                , open_or_closed   IN VARCHAR2
                                 )
      RETURN SELF AS RESULT
   IS
   BEGIN
      self.id := id;
      self.title := title;
      self.publication_date := publication_date;
      self.issn := issn;
      self.open_or_closed := open_or_closed;

      IF issn IS NULL OR self.ck_digit_okay
      THEN
         RETURN;
      ELSE
         raise_application_error (-20000
                                , 'ISSN ' || issn || ' has bad check digit'
                                 );
      END IF;
   END;

   OVERRIDING MEMBER FUNCTION ck_digit_okay
      RETURN BOOLEAN
   IS
      subtotal      PLS_INTEGER := 0;
      issn_digits   VARCHAR2 (8);
   BEGIN
      issn_digits := REPLACE (REPLACE (self.issn, '-'), ' ');

      IF LENGTH (issn_digits) != 8
      THEN
         RETURN FALSE;
      END IF;

      FOR nth_digit IN 1 .. 7
      LOOP
         subtotal :=
            subtotal
            + (9 - nth_digit)
              * TO_NUMBER (SUBSTR (issn_digits, nth_digit, 1));
      END LOOP;

      /* check digit can be 'X' which has value of 10 */
      IF UPPER (SUBSTR (issn_digits, 8, 1)) = 'X'
      THEN
         subtotal := subtotal + 10;
      ELSE
         subtotal := subtotal + TO_NUMBER (SUBSTR (issn_digits, 8, 1));
      END IF;

      RETURN MOD (subtotal, 11) = 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FALSE;
   END;

   OVERRIDING MEMBER FUNCTION PRINT
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN    'id='
             || id
             || '; title='
             || title
             || '; publication_date='
             || publication_date
             || '; issn='
             || issn
             || '; open_or_closed='
             || CASE open_or_closed
                   WHEN 'O' THEN 'Open'
                   WHEN 'C' THEN 'Closed'
                   ELSE NULL
                END;
   END;
END;
/

SHOW ERR

/*---------END EXTRA CODE NOT IN BOOK-------------------------*/

CREATE TYPE subject_t AS OBJECT
   (name VARCHAR2 (2000), broader_term_ref REF subject_t);
/

SHOW ERR

CREATE TYPE subject_refs_t AS TABLE OF REF subject_t;
/

SHOW ERR

CREATE TABLE subjects OF subject_t
(
   CONSTRAINT subject_pk PRIMARY KEY (name) , CONSTRAINT subject_self_ref FOREIGN KEY
                                                 (broader_term_ref)
                                                  REFERENCES subjects
);

ALTER TYPE catalog_item_t
   ADD ATTRIBUTE subject_refs subject_refs_t
   CASCADE INCLUDING TABLE DATA;

/*---------BEGIN EXTRA CODE NOT IN BOOK------------------------*/
ALTER TYPE book_t
   DROP CONSTRUCTOR FUNCTION book_t (id integer DEFAULT NULL,
      title varchar2 DEFAULT NULL,
      publication_date varchar2 DEFAULT NULL,
      isbn varchar2 DEFAULT NULL,
      pages integer DEFAULT NULL)
      RETURN SELF AS RESULT
   CASCADE;
ALTER TYPE book_t
   ADD CONSTRUCTOR FUNCTION book_t (id integer DEFAULT NULL,
      title varchar2 DEFAULT NULL,
      publication_date varchar2 DEFAULT NULL,
      subject_refs subject_refs_t DEFAULT NULL,
      isbn varchar2 DEFAULT NULL,
      pages integer DEFAULT NULL)
      RETURN SELF AS RESULT
   CASCADE;

CREATE OR REPLACE TYPE BODY book_t
AS
   CONSTRUCTOR FUNCTION book_t (id                  INTEGER
                              , title            IN VARCHAR2
                              , publication_date IN VARCHAR2
                              , subject_refs        subject_refs_t
                              , isbn             IN VARCHAR2
                              , pages            IN INTEGER
                               )
      RETURN SELF AS RESULT
   IS
   BEGIN
      self.id := id;
      self.title := title;
      self.publication_date := publication_date;
      self.subject_refs := subject_refs;
      self.isbn := isbn;
      self.pages := pages;

      IF isbn IS NULL OR self.ck_digit_okay
      THEN
         RETURN;
      ELSE
         raise_application_error (-20000
                                , 'ISBN ' || isbn || ' has bad check digit'
                                 );
      END IF;
   END;

   OVERRIDING MEMBER FUNCTION ck_digit_okay
      RETURN BOOLEAN
   IS
      subtotal      PLS_INTEGER := 0;
      isbn_digits   VARCHAR2 (10);
   BEGIN
      /* remove dashes and spaces */
      isbn_digits := REPLACE (REPLACE (self.isbn, '-'), ' ');

      IF LENGTH (isbn_digits) != 10
      THEN
         RETURN FALSE;
      END IF;

      FOR nth_digit IN 1 .. 9
      LOOP
         subtotal :=
            subtotal
            + (11 - nth_digit)
              * TO_NUMBER (SUBSTR (isbn_digits, nth_digit, 1));
      END LOOP;

      /* check digit can be 'X' which has value of 10 */
      IF UPPER (SUBSTR (isbn_digits, 10, 1)) = 'X'
      THEN
         subtotal := subtotal + 10;
      ELSE
         subtotal := subtotal + TO_NUMBER (SUBSTR (isbn_digits, 10, 1));
      END IF;

      RETURN MOD (subtotal, 11) = 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FALSE;
   END;

   OVERRIDING MEMBER FUNCTION PRINT
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN    'id='
             || id
             || '; title='
             || title
             || '; publication_date='
             || publication_date
             || '; isbn='
             || isbn
             || '; pages='
             || pages;
   END;
END;
/

ALTER TYPE serial_t
   DROP CONSTRUCTOR FUNCTION serial_t (id integer DEFAULT NULL,
      title varchar2 DEFAULT NULL,
      publication_date varchar2 DEFAULT NULL,
      issn varchar2 DEFAULT NULL,
      open_or_closed varchar2 DEFAULT NULL)
      RETURN SELF AS RESULT
   CASCADE;
ALTER TYPE serial_t
   ADD CONSTRUCTOR FUNCTION serial_t (id integer DEFAULT NULL,
      title varchar2 DEFAULT NULL,
      publication_date varchar2 DEFAULT NULL,
      subject_refs IN subject_refs_t DEFAULT NULL,
      issn varchar2 DEFAULT NULL,
      open_or_closed varchar2 DEFAULT NULL)
      RETURN SELF AS RESULT
   CASCADE;

CREATE OR REPLACE TYPE BODY serial_t
AS
   CONSTRUCTOR FUNCTION serial_t (id                  INTEGER
                                , title            IN VARCHAR2
                                , publication_date IN VARCHAR2
                                , subject_refs     IN subject_refs_t
                                , issn             IN VARCHAR2
                                , open_or_closed   IN VARCHAR2
                                 )
      RETURN SELF AS RESULT
   IS
   BEGIN
      self.id := id;
      self.title := title;
      self.publication_date := publication_date;
      self.subject_refs := subject_refs;
      self.issn := issn;
      self.open_or_closed := open_or_closed;

      IF issn IS NULL OR self.ck_digit_okay
      THEN
         RETURN;
      ELSE
         raise_application_error (-20000
                                , 'ISSN ' || issn || ' has bad check digit'
                                 );
      END IF;
   END;

   OVERRIDING MEMBER FUNCTION ck_digit_okay
      RETURN BOOLEAN
   IS
      subtotal      PLS_INTEGER := 0;
      issn_digits   VARCHAR2 (8);
   BEGIN
      issn_digits := REPLACE (REPLACE (self.issn, '-'), ' ');

      IF LENGTH (issn_digits) != 8
      THEN
         RETURN FALSE;
      END IF;

      FOR nth_digit IN 1 .. 7
      LOOP
         subtotal :=
            subtotal
            + (9 - nth_digit)
              * TO_NUMBER (SUBSTR (issn_digits, nth_digit, 1));
      END LOOP;

      /* check digit can be 'X' which has value of 10 */
      IF UPPER (SUBSTR (issn_digits, 8, 1)) = 'X'
      THEN
         subtotal := subtotal + 10;
      ELSE
         subtotal := subtotal + TO_NUMBER (SUBSTR (issn_digits, 8, 1));
      END IF;

      RETURN MOD (subtotal, 11) = 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FALSE;
   END;

   OVERRIDING MEMBER FUNCTION PRINT
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN    'id='
             || id
             || '; title='
             || title
             || '; publication_date='
             || publication_date
             || '; issn='
             || issn
             || '; open_or_closed='
             || CASE open_or_closed
                   WHEN 'O' THEN 'Open'
                   WHEN 'C' THEN 'Closed'
                   ELSE NULL
                END;
   END;
END;
/

SHOW ERR

/*---------END EXTRA CODE NOT IN BOOK-------------------------*/

INSERT INTO subjects
    VALUES (subject_t ('Computer file', NULL)
           );

INSERT INTO subjects
    VALUES (subject_t ('Computer program language', NULL)
           );

INSERT INTO subjects
    VALUES (subject_t ('Oracle', (SELECT REF (s)
                                    FROM subjects s
                                   WHERE name = 'Computer file'))
           );

INSERT INTO subjects
    VALUES (subject_t ('PL/SQL', (SELECT REF (s)
                                    FROM subjects s
                                   WHERE name = 'Computer program language'))
           );

INSERT INTO subjects
    VALUES (subject_t ('Relational databases', NULL)
           );

COMMIT;

COLUMN name FORMAT a25
COLUMN bt FORMAT a25

SELECT VALUE (s)
  FROM subjects s;

SELECT s.name, DEREF (s.broader_term_ref).name bt
  FROM subjects s;

SELECT s.name, s.broader_term_ref.name
  FROM subjects s;

INSERT INTO catalog_items
    VALUES (
               NEW book_t (
                      10007
                    , 'Oracle PL/SQL Programming'
                    , 'Sept 1997'
                    , (SELECT CAST (
                                 MULTISET(SELECT REF (s)
                                            FROM subjects s
                                           WHERE name IN
                                                       ('Oracle'
                                                      , 'PL/SQL'
                                                      , 'Relational databases')) AS subject_refs_t
                              )
                         FROM DUAL)
                    , '1-56592-335-9'
                    , 987
                   )
           );

ROLLBACK;

DECLARE
   subrefs   subject_refs_t;
BEGIN
   SELECT REF (s)
     BULK COLLECT
     INTO subrefs
     FROM subjects s
    WHERE name IN ('Oracle', 'PL/SQL', 'Relational databases');

   INSERT INTO catalog_items
       VALUES (
                  NEW book_t (10007
                            , 'Oracle PL/SQL Programming'
                            , 'Sept 1997'
                            , subrefs
                            , '1-56592-335-9'
                            , 987
                             )
              );
END;
/

DECLARE
   subject        subject_t;
   subrefs        subject_refs_t;
   broader_term   subject_t;
BEGIN
   SELECT TREAT (VALUE (c) AS book_t).subject_refs
     INTO subrefs
     FROM catalog_items c
    WHERE id = 10007;

   FOR i IN 1 .. subrefs.COUNT
   LOOP
      UTL_REF.select_object (subrefs (i), subject);
      DBMS_OUTPUT.put (subject.name);

      IF subject.broader_term_ref IS NOT NULL
      THEN
         UTL_REF.select_object (subject.broader_term_ref, broader_term);
         DBMS_OUTPUT.put_line (' (' || broader_term.name || ')');
      ELSE
         DBMS_OUTPUT.put_line ('');
      END IF;
   END LOOP;
END;
/

SELECT VALUE (s).name || ' (' || VALUE (s).broader_term_ref.name || ')'
          plsql_subjects
  FROM table (SELECT subject_refs
                FROM catalog_items
               WHERE id = 10007) s
/


CREATE OR REPLACE TYPE subject_names_t AS TABLE OF VARCHAR2 (400);
/

SELECT ci.title
     , CAST (MULTISET (SELECT s.COLUMN_VALUE.name
                         FROM table (SELECT c.subject_refs
                                       FROM catalog_items c
                                      WHERE id = ci.id) s) AS subject_names_t
            )
          subjects
  FROM catalog_items ci
 WHERE ci.id = 10007
/

ALTER TYPE subject_t
   ADD MEMBER FUNCTION print_bt (str IN varchar2 DEFAULT NULL)
      RETURN varchar2
   CASCADE INCLUDING TABLE DATA;

CREATE OR REPLACE TYPE BODY subject_t
AS
   MEMBER FUNCTION print_bt (str IN VARCHAR2)
      RETURN VARCHAR2
   IS
      bt   subject_t;
   BEGIN
      IF self.broader_term_ref IS NULL
      THEN
         RETURN str;
      ELSE
         UTL_REF.select_object (self.broader_term_ref, bt);
         RETURN bt.print_bt (NVL (str, self.name)) || ' (' || bt.name || ')';
      END IF;
   END;
END;
/

SHOW ERR

DECLARE
   book      book_t;
   item      catalog_item_t;
   itemref   REF catalog_item_t;
   bookref   REF book_t;
BEGIN
   /* Of course a REF that exactly matches variable's type works fine */
   SELECT REF (c)
     INTO itemref
     FROM catalog_items c
    WHERE id = 10007;

   /* Similarly, you can dereference into the exact type */
   UTL_REF.select_object (itemref, item);

   SELECT DEREF (itemref)
     INTO item
     FROM DUAL;

   /* However, you cannot narrow a REF:
   SELECT REF(c) INTO bookref FROM catalog_items c WHERE id = 10007;
   ...
   BUT you can downcast it explicitly:
   */
   SELECT TREAT (REF (c) AS REF book_t)
     INTO bookref
     FROM catalog_items c
    WHERE id = 10007;

   /* You can widen or upcast while derefencing: */
   UTL_REF.select_object (TREAT (bookref AS REF catalog_item_t), item);

   SELECT DEREF (bookref)
     INTO item
     FROM DUAL;

   /* And, although you cannot narrow or downcast while DEREFing:
   | SELECT DEREF(itemref) INTO book FROM DUAL;
   | you can do the expected downcast with TREAT:
   */
   SELECT DEREF (TREAT (itemref AS REF book_t))
     INTO book
     FROM catalog_items c
    WHERE id = 10007;

   /* Or, amazingly enough, you CAN do it with UTL_REF: */
   UTL_REF.select_object (itemref, book);
END;
/


CREATE OR REPLACE FUNCTION printany (adata IN ANYDATA)
   RETURN VARCHAR2
AS
   atype         ANYTYPE;
   retval        VARCHAR2 (32767);
   result_code   PLS_INTEGER;
BEGIN
   CASE adata.gettype (atype)
      WHEN DBMS_TYPES.typecode_number
      THEN
         RETURN 'NUMBER: ' || TO_CHAR (adata.accessnumber);
      WHEN DBMS_TYPES.typecode_varchar2
      THEN
         RETURN 'VARCHAR2: ' || adata.accessvarchar2;
      WHEN DBMS_TYPES.typecode_char
      THEN
         RETURN 'CHAR: ' || RTRIM (adata.accesschar);
      WHEN DBMS_TYPES.typecode_date
      THEN
         RETURN 'DATE: '
                || TO_CHAR (adata.accessdate, 'YYYY-MM-DD hh24:mi:ss');
      WHEN DBMS_TYPES.typecode_object
      THEN
         EXECUTE IMMEDIATE   'DECLARE '
                          || '   myobj '
                          || adata.gettypename
                          || '; '
                          || '   myad sys.ANYDATA := :ad; '
                          || 'BEGIN '
                          || '   :res := myad.GetObject(myobj); '
                          || '   :ret := myobj.print(); '
                          || 'END;'
            USING IN adata, OUT result_code, OUT retval;

         retval := adata.gettypename || ': ' || retval;
      WHEN DBMS_TYPES.typecode_ref
      THEN
         EXECUTE IMMEDIATE   'DECLARE '
                          || '   myref '
                          || adata.gettypename
                          || '; '
                          || '   myobj '
                          || SUBSTR (adata.gettypename
                                   , INSTR (adata.gettypename, ' ')
                                    )
                          || '; '
                          || '   myad sys.ANYDATA := :ad; '
                          || 'BEGIN '
                          || '   :res := myad.GetREF(myref); '
                          || '   UTL_REF.SELECT_OBJECT(myref, myobj);'
                          || '   :ret := myobj.print(); '
                          || 'END;'
            USING IN adata, OUT result_code, OUT retval;

         retval := adata.gettypename || ': ' || retval;
      ELSE
         retval := '<data of type ' || adata.gettypename || '>';
   END CASE;

   RETURN retval;
EXCEPTION
   WHEN OTHERS
   THEN
      IF INSTR (SQLERRM, 'component ''PRINT'' must be declared') > 0
      THEN
         RETURN adata.gettypename || ': <no print() function>';
      ELSE
         RETURN 'Error: ' || SQLERRM;
      END IF;
END;
/

show err

DECLARE
   achar   CHAR (20) := 'fixed-length string';
   abook   book_t := NEW book_t (id => 12345, title => 'my book', pages => 100);
   sref    REF serial_t;
   asub    subject_t := subject_t ('The World', NULL);
BEGIN
   DBMS_OUTPUT.put_line (printany (anydata.convertnumber (3.141592654)));
   DBMS_OUTPUT.put_line (printany (anydata.convertchar (achar)));
   DBMS_OUTPUT.put_line (printany (anydata.convertobject (abook)));
   DBMS_OUTPUT.put_line (printany (anydata.convertobject (asub)));

   SELECT TREAT (REF (c) AS REF serial_t)
     INTO sref
     FROM catalog_items c
    WHERE title = 'Time';

   DBMS_OUTPUT.put_line (printany (anydata.convertref (sref)));
END;
/

ALTER TYPE catalog_item_t
   ADD MEMBER PROCEDURE save,
   ADD MEMBER FUNCTION retrieve_matching
      RETURN sys_refcursor,
   ADD MEMBER PROCEDURE remove
   CASCADE;

CREATE OR REPLACE TYPE BODY catalog_item_t
AS
   MEMBER PROCEDURE save
   IS
   BEGIN
      UPDATE catalog_items c
         SET c = self
       WHERE id = self.id;

      IF sql%ROWCOUNT = 0
      THEN
         INSERT INTO catalog_items
             VALUES (self
                    );
      END IF;
   END;

   MEMBER FUNCTION retrieve_matching
      RETURN sys_refcursor
   IS
      l_refcur   sys_refcursor;
   BEGIN
      IF self IS OF (book_t)
      THEN
         OPEN l_refcur FOR
            SELECT VALUE (c)
              FROM catalog_items c
             WHERE (self.id IS NULL OR id = self.id)
                   AND (self.title IS NULL OR title LIKE self.title || '%')
                   AND (self.publication_date IS NULL
                        OR publication_date = self.publication_date)
                   AND (TREAT (self AS book_t).isbn IS NULL
                        OR TREAT (VALUE (c) AS book_t).isbn =
                             TREAT (self AS book_t).isbn)
                   AND (TREAT (self AS book_t).pages IS NULL
                        OR TREAT (VALUE (c) AS book_t).pages =
                             TREAT (self AS book_t).pages);
      ELSIF self IS OF (serial_t)
      THEN
         OPEN l_refcur FOR
            SELECT VALUE (c)
              FROM catalog_items c
             WHERE (self.id IS NULL OR id = self.id)
                   AND (self.title IS NULL OR title LIKE self.title || '%')
                   AND (self.publication_date IS NULL
                        OR publication_date = self.publication_date)
                   AND (TREAT (self AS serial_t).issn IS NULL
                        OR TREAT (VALUE (c) AS serial_t).issn =
                             TREAT (self AS serial_t).issn)
                   AND (TREAT (self AS serial_t).open_or_closed IS NULL
                        OR TREAT (VALUE (c) AS serial_t).open_or_closed =
                             TREAT (self AS serial_t).open_or_closed);
      END IF;

      RETURN l_refcur;
   END;

   MEMBER PROCEDURE remove
   IS
   BEGIN
      DELETE catalog_items
       WHERE id = self.id;

      self := NULL;
   END;

   MEMBER FUNCTION PRINT
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN 'stub for not-yet-implemented print method';
   END;
END;
/

SHOW ERR

DECLARE
   catalog_item      catalog_item_t;
   l_refcur          sys_refcursor;
   l_sample_object   book_t := NEW book_t (title => '%');
   new_book book_t
         := NEW book_t (id => 12345, title => 'Test book', pages => 77);
   new_serial serial_t
         := NEW serial_t (id => 54321, open_or_closed => 'C');
BEGIN
   new_book.save;
   l_refcur := l_sample_object.retrieve_matching ();

   LOOP
      FETCH l_refcur
      INTO catalog_item;

      EXIT WHEN l_refcur%NOTFOUND;
      DBMS_OUTPUT.put_line ('Matching item:' || catalog_item.PRINT);
   END LOOP;

   CLOSE l_refcur;

   new_book.remove;
END;
/



CREATE TABLE catalog_history
(
   id            INTEGER NOT NULL PRIMARY KEY
 , action        CHAR (1) NOT NULL
 , action_time   timestamp DEFAULT (SYSTIMESTAMP) NOT NULL
 , old_item      catalog_item_t
 , new_item      catalog_item_t
)
NESTED TABLE old_item.subject_refs
   STORE AS catalog_history_old_subrefs
NESTED TABLE new_item.subject_refs
   STORE AS catalog_history_new_subrefs
/


  SELECT *
    FROM catalog_history c
   WHERE c.old_item.id > 10000
ORDER BY NVL (TREAT (c.old_item AS book_t).isbn
            , TREAT (c.old_item AS serial_t).issn
             )
/

CREATE INDEX catalog_history_old_id_idx
   ON catalog_history c (c.old_item.id)
/

ALTER TYPE catalog_item_t
   ADD MAP MEMBER FUNCTION mapit RETURN number
   CASCADE;

CREATE OR REPLACE TYPE BODY catalog_item_t
AS
   MEMBER PROCEDURE save
   IS
   BEGIN
      UPDATE catalog_items c
         SET c = self
       WHERE id = self.id;

      IF sql%ROWCOUNT = 0
      THEN
         INSERT INTO catalog_items
             VALUES (self
                    );
      END IF;
   END;

   MEMBER FUNCTION retrieve_matching
      RETURN sys_refcursor
   IS
      l_refcur   sys_refcursor;
   BEGIN
      IF self IS OF (book_t)
      THEN
         OPEN l_refcur FOR
            SELECT VALUE (c)
              FROM catalog_items c
             WHERE (self.id IS NULL OR id = self.id)
                   AND (self.title IS NULL OR title LIKE self.title || '%')
                   AND (self.publication_date IS NULL
                        OR publication_date = self.publication_date)
                   AND (TREAT (self AS book_t).isbn IS NULL
                        OR TREAT (VALUE (c) AS book_t).isbn =
                             TREAT (self AS book_t).isbn)
                   AND (TREAT (self AS book_t).pages IS NULL
                        OR TREAT (VALUE (c) AS book_t).pages =
                             TREAT (self AS book_t).pages);
      ELSIF self IS OF (serial_t)
      THEN
         OPEN l_refcur FOR
            SELECT VALUE (c)
              FROM catalog_items c
             WHERE (self.id IS NULL OR id = self.id)
                   AND (self.title IS NULL OR title LIKE self.title || '%')
                   AND (self.publication_date IS NULL
                        OR publication_date = self.publication_date)
                   AND (TREAT (self AS serial_t).issn IS NULL
                        OR TREAT (VALUE (c) AS serial_t).issn =
                             TREAT (self AS serial_t).issn)
                   AND (TREAT (self AS serial_t).open_or_closed IS NULL
                        OR TREAT (VALUE (c) AS serial_t).open_or_closed =
                             TREAT (self AS serial_t).open_or_closed);
      END IF;

      RETURN l_refcur;
   END;

   MEMBER PROCEDURE remove
   IS
   BEGIN
      DELETE catalog_items
       WHERE id = self.id;

      self := NULL;
   END;

   MEMBER FUNCTION PRINT
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN 'stub for not-yet-implemented print method';
   END;

   MAP MEMBER FUNCTION mapit
      RETURN NUMBER
   IS
   BEGIN
      RETURN id;
   END;
END;
/

SHOW ERR
ALTER TYPE catalog_item_t
   DROP MAP MEMBER FUNCTION mapit RETURN number
   CASCADE;
ALTER TYPE catalog_item_t
   ADD ORDER MEMBER FUNCTION orderit (obj2 IN catalog_item_t)
      RETURN integer
   CASCADE;

CREATE OR REPLACE TYPE BODY catalog_item_t
AS
   MEMBER PROCEDURE save
   IS
   BEGIN
      UPDATE catalog_items c
         SET c = self
       WHERE id = self.id;

      IF sql%ROWCOUNT = 0
      THEN
         INSERT INTO catalog_items
             VALUES (self
                    );
      END IF;
   END;

   MEMBER FUNCTION retrieve_matching
      RETURN sys_refcursor
   IS
      l_refcur   sys_refcursor;
   BEGIN
      IF self IS OF (book_t)
      THEN
         OPEN l_refcur FOR
            SELECT VALUE (c)
              FROM catalog_items c
             WHERE (self.id IS NULL OR id = self.id)
                   AND (self.title IS NULL OR title LIKE self.title || '%')
                   AND (self.publication_date IS NULL
                        OR publication_date = self.publication_date)
                   AND (TREAT (self AS book_t).isbn IS NULL
                        OR TREAT (VALUE (c) AS book_t).isbn =
                             TREAT (self AS book_t).isbn)
                   AND (TREAT (self AS book_t).pages IS NULL
                        OR TREAT (VALUE (c) AS book_t).pages =
                             TREAT (self AS book_t).pages);
      ELSIF self IS OF (serial_t)
      THEN
         OPEN l_refcur FOR
            SELECT VALUE (c)
              FROM catalog_items c
             WHERE (self.id IS NULL OR id = self.id)
                   AND (self.title IS NULL OR title LIKE self.title || '%')
                   AND (self.publication_date IS NULL
                        OR publication_date = self.publication_date)
                   AND (TREAT (self AS serial_t).issn IS NULL
                        OR TREAT (VALUE (c) AS serial_t).issn =
                             TREAT (self AS serial_t).issn)
                   AND (TREAT (self AS serial_t).open_or_closed IS NULL
                        OR TREAT (VALUE (c) AS serial_t).open_or_closed =
                             TREAT (self AS serial_t).open_or_closed);
      END IF;

      RETURN l_refcur;
   END;

   MEMBER PROCEDURE remove
   IS
   BEGIN
      DELETE catalog_items
       WHERE id = self.id;

      self := NULL;
   END;

   MEMBER FUNCTION PRINT
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN NULL;             /* never gets invoked; non-instantiable type */
   END;

   ORDER MEMBER FUNCTION orderit (obj2 IN catalog_item_t)
      RETURN INTEGER
   IS
      self_gt_o2         CONSTANT PLS_INTEGER := 1;
      eq                 CONSTANT PLS_INTEGER := 0;
      o2_gt_self         CONSTANT PLS_INTEGER := -1;
      l_matching_count   NUMBER;
   BEGIN
      CASE
         WHEN obj2 IS OF (book_t) AND self IS OF (serial_t)
         THEN
            RETURN o2_gt_self;
         WHEN obj2 IS OF (serial_t) AND self IS OF (book_t)
         THEN
            RETURN self_gt_o2;
         ELSE
            IF obj2.title = self.title
               AND obj2.publication_date = self.publication_date
            THEN
               IF     obj2.subject_refs IS NOT NULL
                  AND self.subject_refs IS NOT NULL
                  AND obj2.subject_refs.COUNT = self.subject_refs.COUNT
               THEN
                  SELECT COUNT ( * )
                    INTO l_matching_count
                    FROM (SELECT *
                            FROM table(SELECT CAST (
                                                 self.subject_refs AS subject_refs_t
                                              )
                                         FROM DUAL)
                          INTERSECT
                          SELECT *
                            FROM table(SELECT CAST (
                                                 obj2.subject_refs AS subject_refs_t
                                              )
                                         FROM DUAL));

                  IF l_matching_count = self.subject_refs.COUNT
                  THEN
                     RETURN eq;
                  END IF;
               END IF;
            END IF;

            RETURN NULL;
      END CASE;
   END;
END;
/

SHOW ERR

-- vim: noet ts=3 sw=3 syntax=plsql


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/