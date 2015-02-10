/* file on web: 12c_table_pf_with_aa.sql */

/* Create a package-based type */

CREATE OR REPLACE PACKAGE aa_pkg
IS
   TYPE strings_t IS TABLE OF VARCHAR2 (100)
      INDEX BY PLS_INTEGER;

   FUNCTION strings
      RETURN strings_t;
END;
/

CREATE OR REPLACE PACKAGE BODY aa_pkg
IS
   FUNCTION strings
      RETURN strings_t
   IS
      l_return   strings_t;
   BEGIN
      l_return (1) := 'Me';
      l_return (2) := 'You';

      RETURN l_return;
   END;
END;
/

/* Cannot call table function directly inside SQL */

DECLARE
   happyfamily   aa_pkg.strings_t;
BEGIN
   FOR rec IN (  SELECT COLUMN_VALUE family_name
                   FROM TABLE (aa_pkg.strings)
               ORDER BY family_name)
   LOOP
      DBMS_OUTPUT.put_line (rec.family_name);
   END LOOP;
END;
/

/* But I can call the function first and pass it to the query, OK */

DECLARE
   happyfamily   aa_pkg.strings_t;
BEGIN
   happyfamily := aa_pkg.strings;

   FOR rec IN (  SELECT COLUMN_VALUE family_name
                   FROM TABLE (happyfamily)
               ORDER BY family_name)
   LOOP
      DBMS_OUTPUT.put_line (rec.family_name);
   END LOOP;
END;
/