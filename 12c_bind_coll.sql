/* File on web: 12c_bind_coll.sql */

CREATE OR REPLACE PACKAGE names_pkg
   AUTHID CURRENT_USER
AS
   TYPE names_t IS TABLE OF VARCHAR2 (100)
      INDEX BY PLS_INTEGER;

   PROCEDURE display_names (
      names_in   IN names_t);
END names_pkg;
/

SHO ERR

CREATE OR REPLACE PACKAGE BODY names_pkg
AS
   PROCEDURE display_names (
      names_in   IN names_t)
   IS
   BEGIN
      FOR indx IN 1 .. names_in.COUNT
      LOOP
         DBMS_OUTPUT.put_line (
            names_in (indx));
      END LOOP;
   END;
END names_pkg;
/

SHO ERR

DECLARE
   l_names   names_pkg.names_t;
BEGIN
   l_names (1) := 'Loey';
   l_names (2) := 'Dylan';
   l_names (3) := 'Indigo';
   l_names (4) := 'Saul';
   l_names (5) := 'Sally';

   EXECUTE IMMEDIATE
      'BEGIN names_pkg.display_names (:names); END;'
      USING l_names;

   FOR rec
      IN (SELECT * FROM TABLE (l_names))
   LOOP
      DBMS_OUTPUT.put_line (
         rec.COLUMN_VALUE);
   END LOOP;
END;
/