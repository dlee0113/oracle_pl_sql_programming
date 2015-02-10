/*
Oracle PL/SQL Programming 5th Edition

www.stevenfeuerstein.com/books

Objection creation and example scripts for Chapter 12

You will find below all non-trivial code snippets from the above chapter
that are NOT contained in their own files (as specified in the chapter),
plus any DDL object creation scripts required to get a clean compile
on the snippets.

Any references to Oracle's standard HR tables (employees, departments,
locations, regions, etc.) will NOT include the DDL creation scripts
in this file. Instead, run the hr_schema_install.sql script and all
those tables and related elements will be defined.
*/
DROP TABLE person
/

CREATE TABLE person (first_name VARCHAR2 (100))
/

DECLARE
   TYPE list_of_names_t IS TABLE OF person.first_name%TYPE
                              INDEX BY PLS_INTEGER;

   happyfamily   list_of_names_t;
   l_row         PLS_INTEGER;
BEGIN
   happyfamily (2020202020) := 'Eli';
   happyfamily (-15070) := 'Steven';
   happyfamily (-90900) := 'Chris';
   happyfamily (88) := 'Veva';

   l_row := happyfamily.FIRST;

   WHILE (l_row IS NOT NULL)
   LOOP
      DBMS_OUTPUT.put_line (happyfamily (l_row));
      l_row := happyfamily.NEXT (l_row);
   END LOOP;
END;
/

CREATE OR REPLACE TYPE list_of_names_t IS TABLE OF VARCHAR2 (100);
/

DECLARE
   happyfamily   list_of_names_t := list_of_names_t ();
   children      list_of_names_t := list_of_names_t ();
   parents       list_of_names_t := list_of_names_t ();
BEGIN
   happyfamily.EXTEND (4);
   happyfamily (1) := 'Eli';
   happyfamily (2) := 'Steven';
   happyfamily (3) := 'Chris';
   happyfamily (4) := 'Veva';

   children.EXTEND;
   children (1) := 'Chris';
   children.EXTEND;
   children (2) := 'Eli';

   parents := happyfamily MULTISET EXCEPT children;

   FOR l_row IN parents.FIRST .. parents.LAST
   LOOP
      DBMS_OUTPUT.put_line (parents (l_row));
   END LOOP;
END;
/

DROP TYPE first_names_t FORCE
/

CREATE OR REPLACE TYPE first_names_t IS VARRAY (2) OF VARCHAR2 (100);
/

DROP TYPE child_names_t FORCE
/

CREATE OR REPLACE TYPE child_names_t IS VARRAY (1) OF VARCHAR2 (100);
/

DROP TABLE family
/

CREATE TABLE family
(
   surname          VARCHAR2 (1000)
 , parent_names     first_names_t
 , children_names   child_names_t
)
/

DECLARE
   parents    first_names_t := first_names_t ();
   children   child_names_t := child_names_t ();
BEGIN
   parents.EXTEND (2);
   parents (1) := 'Samuel';
   parents (2) := 'Charina';
   --
   children.EXTEND;
   children (1) := 'Feather';

   --
   INSERT INTO family (surname, parent_names, children_names
                      )
       VALUES ('Assurty', parents, children
              );

   COMMIT;
END;
/

SELECT *
  FROM family
/

DROP TYPE color_tab_t FORCE
/

CREATE OR REPLACE TYPE color_tab_t IS TABLE OF VARCHAR2 (100)
/

DECLARE
   TYPE toy_rec_t IS RECORD (
      manufacturer           INTEGER
    , shipping_weight_kg     NUMBER
    , domestic_colors        color_tab_t
    , international_colors   color_tab_t
   );
BEGIN
   NULL;
END;
/

DECLARE
   TYPE birthdates_aat IS VARRAY (10) OF DATE;

   l_dates   birthdates_aat := birthdates_aat ();
BEGIN
   l_dates.EXTEND (1);
   l_dates (1) := SYSDATE;

   DECLARE
      FUNCTION earliest_birthdate (list_in IN birthdates_aat)
         RETURN DATE
      IS
      BEGIN
         RETURN SYSDATE;
      END earliest_birthdate;
   BEGIN
      DBMS_OUTPUT.put_line (earliest_birthdate (l_dates));
   END;
END;
/

DROP TABLE personality_inventory
/

CREATE TABLE personality_inventory
(
   person_id         NUMBER
 , favorite_colors   color_tab_t
 , date_tested       DATE
 , test_results      BLOB
)
NESTED TABLE favorite_colors
   STORE AS favorite_colors_st
/

CREATE OR REPLACE FUNCTION true_colors (whose_id IN NUMBER)
   RETURN color_tab_t
AS
   l_colors   color_tab_t;
BEGIN
   SELECT favorite_colors
     INTO l_colors
     FROM personality_inventory
    WHERE person_id = whose_id;

   RETURN l_colors;
END;
/

DECLARE
   color_array   color_tab_t;
BEGIN
   color_array := true_colors (8041);
END;
/

DECLARE
   one_of_my_favorite_colors   VARCHAR2 (30);
BEGIN
   one_of_my_favorite_colors := true_colors (8041) (1);
END;
/

DROP TYPE auto_spec_t FORCE
/

CREATE OR REPLACE TYPE auto_spec_t AS OBJECT
   (make VARCHAR2 (30), model VARCHAR2 (30), available_colors color_tab_t);
/

DROP TABLE auto_specs
/

CREATE TABLE auto_specs OF auto_spec_t
NESTED TABLE available_colors
   STORE AS available_colors_st
/

CREATE OR REPLACE TYPE volunteer_list_ar IS TABLE OF VARCHAR2 (100)
/

DECLARE
   volunteer_list   volunteer_list_ar := volunteer_list_ar ('Steven');

   PROCEDURE assign_tasks (list_in IN volunteer_list_ar)
   IS
   BEGIN
      NULL;
   END;
BEGIN
   IF volunteer_list.COUNT > 0
   THEN
      assign_tasks (volunteer_list);
   END IF;
END;
/

DROP TYPE list_t
/

CREATE OR REPLACE TYPE list_t IS TABLE OF VARCHAR2 (100)
/

CREATE OR REPLACE PROCEDURE keep_last (the_list IN OUT list_t)
AS
   first_elt          PLS_INTEGER := the_list.FIRST;
   next_to_last_elt   PLS_INTEGER := the_list.PRIOR (the_list.LAST);
BEGIN
   the_list.delete (first_elt, next_to_last_elt);
END;
/

DECLARE
   my_list   color_tab_t := color_tab_t ();
   element   PLS_INTEGER := 1;
BEGIN
   IF my_list.EXISTS (element)
   THEN
      my_list (element) := NULL;
   END IF;
END;
/

CREATE OR REPLACE PROCEDURE push (the_list  IN OUT list_t
                                , new_value IN     VARCHAR2
                                 )
AS
BEGIN
   the_list.EXTEND;
   the_list (the_list.LAST) := new_value;
END;
/

CREATE OR REPLACE PROCEDURE push_ten (the_list  IN OUT list_t
                                    , new_value IN     VARCHAR2
                                     )
AS
   l_copyfrom   PLS_INTEGER;
BEGIN
   the_list.EXTEND;
   l_copyfrom := the_list.LAST;
   the_list (l_copyfrom) := new_value;
   the_list.EXTEND (9, l_copyfrom);
END;
/

CREATE OR REPLACE FUNCTION compute_sum (the_list IN list_t)
   RETURN NUMBER
AS
   row_index   PLS_INTEGER := the_list.FIRST;
   total       NUMBER := 0;
BEGIN
   LOOP
      EXIT WHEN row_index IS NULL;
      total := total + the_list (row_index);
      row_index := the_list.NEXT (row_index);
   END LOOP;

   RETURN total;
END compute_sum;
/

CREATE OR REPLACE FUNCTION compute_sum (the_list IN list_t)
   RETURN NUMBER
AS
   row_index   PLS_INTEGER := the_list.LAST;
   total       NUMBER := 0;
BEGIN
   LOOP
      EXIT WHEN row_index IS NULL;
      total := total + the_list (row_index);
      row_index := the_list.PRIOR (row_index);
   END LOOP;

   RETURN total;
END compute_sum;
/

CREATE OR REPLACE FUNCTION pop (the_list IN OUT list_t)
   RETURN VARCHAR2
AS
   l_value   VARCHAR2 (30);
BEGIN
   IF the_list.COUNT >= 1
   THEN
      /* Save the value of the last element in the collection
      || so it can be returned
      */
      l_value := the_list (the_list.LAST);
      the_list.TRIM;
   END IF;

   RETURN l_value;
END;
/

DROP TABLE company
/

CREATE TABLE company
(
   company_id     NUMBER (38)
 , order_amount   NUMBER
 , name           VARCHAR2 (100 BYTE)
)
/

DROP TABLE books CASCADE CONSTRAINTS
/

CREATE TABLE books
(
   book_id          NUMBER (38)
 , isbn             VARCHAR2 (13 BYTE)
 , title            VARCHAR2 (200 BYTE)
 , summary          VARCHAR2 (2000 BYTE)
 , author           VARCHAR2 (200 BYTE)
 , date_published   DATE
 , page_count       NUMBER
)
/

DECLARE
   -- A list of dates
   TYPE birthdays_tt IS TABLE OF DATE
                           INDEX BY PLS_INTEGER;

   -- A list of company IDs
   TYPE company_keys_tt IS TABLE OF company.company_id%TYPE NOT NULL
                              INDEX BY PLS_INTEGER;

   -- A list of book records; this structure allows you to make a "local"
   -- copy of the book table in your PL/SQL program.
   TYPE booklist_tt IS TABLE OF books%ROWTYPE
                          INDEX BY NATURAL;

   -- Each collection is organized by the author name.
   TYPE books_by_author_tt IS TABLE OF books%ROWTYPE
                                 INDEX BY books.author%TYPE;

   -- A collection of collections
   TYPE private_collection_tt IS TABLE OF books_by_author_tt
                                    INDEX BY VARCHAR2 (100);
BEGIN
   NULL;
END;
/

DROP TYPE list_vat FORCE
/

CREATE TYPE list_vat AS VARRAY (10) OF VARCHAR2 (80);
/

ALTER TYPE list_vat MODIFY LIMIT 100 ;

/

ALTER TYPE list_vat MODIFY ELEMENT TYPE varchar2(100) CASCADE;

/

DECLARE
   TYPE company_aat IS TABLE OF company%ROWTYPE
                          INDEX BY PLS_INTEGER;

   premier_sponsor_list   company_aat;
   select_sponsor_list    company_aat;
BEGIN
   NULL;
END;
/

DECLARE
   TYPE company_aat IS TABLE OF company%ROWTYPE;

   premier_sponsor_list   company_aat := company_aat ();
BEGIN
   NULL;
END;
/

DECLARE
   TYPE company_aat IS TABLE OF company%ROWTYPE;

   premier_sponsor_list   company_aat;
BEGIN
   premier_sponsor_list := company_aat ();
END;
/

DECLARE
   my_favorite_colors    color_tab_t := color_tab_t ();
   his_favorite_colors   color_tab_t := color_tab_t ('PURPLE');
   her_favorite_colors   color_tab_t := color_tab_t ('PURPLE', 'GREEN');
BEGIN
   NULL;
END;
/

DECLARE
   earth_colors     color_tab_t := color_tab_t ('BRICK', 'RUST', 'DIRT');
   wedding_colors   color_tab_t;
BEGIN
   wedding_colors := earth_colors;
   wedding_colors (3) := 'CANVAS';
END;
/

DROP TABLE color_models
/

CREATE TABLE color_models (model_type VARCHAR2 (12), colors color_tab_t)
NESTED TABLE colors
   STORE AS color_model_colors_tab
/

BEGIN
   INSERT INTO color_models
       VALUES ('RGB', color_tab_t ('RED', 'GREEN', 'BLUE')
              );
END;
/

DECLARE
   l_colors   color_tab_t;
BEGIN
   /* Retrieve all the nested values in a single fetch.
   || This is the cool part.
   */
   SELECT colors
     INTO l_colors
     FROM color_models
    WHERE model_type = 'RGB';
END;
/

DECLARE
   color_tab   color_tab_t;
BEGIN
   SELECT colors
     INTO color_tab
     FROM color_models
    WHERE model_type = 'RGB';

   FOR element IN 1 .. color_tab.COUNT
   LOOP
      IF color_tab (element) = 'RED'
      THEN
         color_tab (element) := 'FUSCHIA';
      END IF;
   END LOOP;

   /* Here is the cool part of this example. Only one insert
   || statement is needed -- it sends the entire nested table
   || back into the color_models table in the database. */

   INSERT INTO color_models
       VALUES ('FGB', color_tab
              );
END;
/

DECLARE
   TYPE emp_copy_t IS TABLE OF employees%ROWTYPE;

   l_emps     emp_copy_t := emp_copy_t ();
   l_emprec   employees%ROWTYPE;
BEGIN
   l_emprec.first_name := 'Steven';
   l_emprec.salary := 10000;
   l_emps.EXTEND;
   l_emps (l_emps.LAST) := l_emprec;
END;
/

DECLARE
   TYPE name_t IS TABLE OF VARCHAR2 (100)
                     INDEX BY PLS_INTEGER;

   old_names   name_t;
   new_names   name_t;
BEGIN
   /* Assign values to old_names table */
   old_names (1) := 'Smith';
   old_names (2) := 'Harrison';

   /* Assign values to new_names table */
   new_names (111) := 'Hanrahan';
   new_names (342) := 'Blimey';

   /* Transfer values from new to old */
   old_names := new_names;

   /* This statement will display 'Hanrahan' */
   DBMS_OUTPUT.put_line (
      old_names.FIRST || ': ' || old_names (old_names.FIRST)
   );
END;
/

DECLARE
   TYPE emp_copy_t IS TABLE OF employees%ROWTYPE;

   l_emps   emp_copy_t := emp_copy_t ();
BEGIN
   l_emps.EXTEND;

   SELECT *
     INTO l_emps (1)
     FROM employees
    WHERE employee_id = 7521;
END;
/

DECLARE
   TYPE emp_copy_t IS TABLE OF employees%ROWTYPE;

   l_emps   emp_copy_t := emp_copy_t ();
BEGIN
   FOR emp_rec IN (SELECT *
                     FROM employees)
   LOOP
      l_emps.EXTEND;
      l_emps (l_emps.LAST) := emp_rec;
   END LOOP;
END;
/

DECLARE
   TYPE emp_copy_t IS TABLE OF employees%ROWTYPE
                         INDEX BY PLS_INTEGER;

   l_emps   emp_copy_t;
BEGIN
   FOR emp_rec IN (SELECT *
                     FROM employees)
   LOOP
      l_emps (emp_rec.employee_id) := emp_rec;
   END LOOP;
END;
/

DECLARE
   TYPE emp_copy_nt IS TABLE OF employees%ROWTYPE;

   l_emps   emp_copy_nt;
BEGIN
   SELECT *
     BULK COLLECT
     INTO l_emps
     FROM employees;
END;
/

CREATE OR REPLACE PROCEDURE make_adjustment (NAME_IN IN VARCHAR2)
IS
BEGIN
   NULL;
END;
/

DECLARE
   c_delimiter   CONSTANT CHAR (1) := '^';

   TYPE strings_t IS TABLE OF employees%ROWTYPE
                        INDEX BY employees.email%TYPE;

   TYPE ids_t IS TABLE OF employees%ROWTYPE
                    INDEX BY PLS_INTEGER;

   by_name       strings_t;
   by_email      strings_t;
   by_id         ids_t;

   ceo_name employees.last_name%TYPE
         := 'ELLISON' || c_delimiter || 'LARRY';

   PROCEDURE load_arrays
   IS
   BEGIN
      /* Load up all three arrays from rows in table. */
      FOR rec IN (SELECT *
                    FROM employees)
      LOOP
         by_name (rec.last_name || c_delimiter || rec.first_name) := rec;
         by_email (rec.email) := rec;
         by_id (rec.employee_id) := rec;
      END LOOP;
   END;
BEGIN
   load_arrays;

   /* Now I can retrieve information by name or by ID. */

   IF by_name (ceo_name).salary > by_id (7645).salary
   THEN
      make_adjustment (ceo_name);
   END IF;
END;
/

CREATE OR REPLACE PACKAGE compensation_pkg
IS
   TYPE reward_rt IS RECORD (nm VARCHAR2 (2000), sal NUMBER, comm NUMBER);

   TYPE reward_tt IS TABLE OF reward_rt
                        INDEX BY PLS_INTEGER;
END compensation_pkg;
/

DECLARE
   holiday_bonuses   compensation_pkg.reward_tt;
BEGIN
   NULL;
END;
/

DROP TYPE pet_
/
DROP TYPE vet_visits_t
/
DROP TYPE vet_visit_t
/

CREATE OR REPLACE TYPE vet_visit_t IS OBJECT
   (visit_date DATE, reason VARCHAR2 (100))
/

CREATE TYPE vet_visits_t IS TABLE OF vet_visit_t
/

CREATE TYPE pet_t IS OBJECT
   (tag_no INTEGER
  , name VARCHAR2 (60)
  , petcare vet_visits_t
  , MEMBER FUNCTION set_tag_no (new_tag_no IN INTEGER)
       RETURN pet_t
   )
/

DECLARE
   SUBTYPE temperature IS NUMBER;

   SUBTYPE coordinate_axis IS PLS_INTEGER;

   TYPE temperature_x IS TABLE OF temperature
                            INDEX BY coordinate_axis;

   TYPE temperature_xy IS TABLE OF temperature_x
                             INDEX BY coordinate_axis;

   TYPE temperature_xyz IS TABLE OF temperature_xy
                              INDEX BY coordinate_axis;

   temperature_3d   temperature_xyz;
BEGIN
   temperature_3d (1) (2) (3) := 45;
END;
/

DROP TABLE color_models
/

CREATE OR REPLACE TYPE color_nt AS TABLE OF VARCHAR2 (30);
/

CREATE OR REPLACE TYPE color_vat AS VARRAY (16) OF VARCHAR2 (30)
/

CREATE TABLE color_models (model_type VARCHAR2 (12), colors color_vat)
/

BEGIN
   INSERT INTO color_models
       VALUES ('RGB', color_vat ('RED', 'GREEN', 'BLUE')
              );

   COMMIT;
END;
/

SELECT COLUMN_VALUE my_colors
  FROM table (SELECT CAST (colors AS color_nt)
                FROM color_models
               WHERE model_type = 'RGB')
/

DROP TYPE color_tab_t FORCE
/

CREATE TYPE color_tab_t IS VARRAY (100) OF VARCHAR2 (100)
/

DROP TABLE birds
/
DROP TABLE bird_habitats
/

CREATE TABLE birds
(
   genus     VARCHAR2 (128)
 , species   VARCHAR2 (128)
 , colors    color_tab_t
 , PRIMARY KEY (genus, species)
)
/

CREATE TABLE bird_habitats
(
   genus     VARCHAR2 (128)
 , species   VARCHAR2 (128)
 , country   VARCHAR2 (60)
 , FOREIGN KEY (genus, species) REFERENCES birds (genus, species)
)
/

CREATE TYPE country_tab_t AS TABLE OF VARCHAR2 (60)
/

DECLARE
   CURSOR bird_curs
   IS
      SELECT b.genus
           , b.species
           , CAST (
                MULTISET (
                   SELECT bh.country
                     FROM bird_habitats bh
                    WHERE bh.genus = b.genus AND bh.species = b.species
                ) AS country_tab_t
             )
        FROM birds b;

   bird_row   bird_curs%ROWTYPE;
BEGIN
   OPEN bird_curs;

   FETCH bird_curs
   INTO bird_row;

   CLOSE bird_curs;
END;
/

SELECT *
  FROM color_models c
 WHERE 'RED' IN (SELECT *
                   FROM table (c.colors))
/

CREATE TYPE names_t AS TABLE OF VARCHAR2 (100)
/

CREATE TYPE authors_t AS TABLE OF VARCHAR2 (100);

CREATE TABLE favorite_authors (name VARCHAR2 (200))
/

BEGIN
   INSERT INTO favorite_authors
       VALUES ('Robert Harris'
              );

   INSERT INTO favorite_authors
       VALUES ('Tom Segev'
              );

   INSERT INTO favorite_authors
       VALUES ('Toni Morrison'
              );
END;
/

DECLARE
   scifi_favorites authors_t
         := authors_t ('Sheri S. Tepper', 'Orson Scott Card', 'Gene Wolfe');
BEGIN
   DBMS_OUTPUT.put_line ('I recommend that you read books by:');

   FOR rec IN (SELECT COLUMN_VALUE favs
                 FROM table (CAST (scifi_favorites AS names_t))
               UNION
               SELECT name
                 FROM favorite_authors)
   LOOP
      DBMS_OUTPUT.put_line (rec.favs);
   END LOOP;
END;
/

DECLARE
   scifi_favorites authors_t
         := authors_t ('Sheri S. Tepper', 'Orson Scott Card', 'Gene Wolfe');
BEGIN
   DBMS_OUTPUT.put_line ('I recommend that you read books by:');

   FOR rec IN (  SELECT COLUMN_VALUE favs
                   FROM table (CAST (scifi_favorites AS names_t))
               ORDER BY COLUMN_VALUE)
   LOOP
      DBMS_OUTPUT.put_line (rec.favs);
   END LOOP;
END;
/

