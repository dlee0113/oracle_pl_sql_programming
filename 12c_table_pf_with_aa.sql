/* file on web: 12c_table_pf_with_aa.sql */

/* Create a package-based type */

CREATE OR REPLACE PACKAGE aa_pkg
IS
   TYPE strings_t IS TABLE OF VARCHAR2 (100)
      INDEX BY PLS_INTEGER;
END;
/

/* Populate the collection, then use a cursor FOR loop
   to select all elements and display them. */

DECLARE
   happyfamily   aa_pkg.strings_t;
BEGIN
   happyfamily (1) := 'Me';
   happyfamily (2) := 'You';

   FOR rec IN (  SELECT COLUMN_VALUE family_name
                   FROM TABLE (happyfamily)
               ORDER BY family_name)
   LOOP
      DBMS_OUTPUT.put_line (rec.family_name);
   END LOOP;
END;
/

/* But not with a local type...unfortunately error message is still "old"....
   
   PL/SQL: ORA-22905: cannot access rows from a non-nested table item   
   
*/

DECLARE
   TYPE strings_t IS TABLE OF VARCHAR2 (100)
      INDEX BY PLS_INTEGER;

   happyfamily   strings_t;
BEGIN
   happyfamily (1) := 'Me';
   happyfamily (2) := 'You';


   FOR rec IN (  SELECT COLUMN_VALUE family_name
                   FROM TABLE (happyfamily)
               ORDER BY family_name)
   LOOP
      DBMS_OUTPUT.put_line (rec.family_name);
   END LOOP;
END;
/