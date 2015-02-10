DROP TABLE favorites
/

CREATE TABLE favorites (name VARCHAR2 (100), code INTEGER)
/

CREATE OR REPLACE PACKAGE favorites_pkg
   AUTHID CURRENT_USER
IS
   -- Two constants; notice that I give understandable
   -- names to otherwise obscure values.

   c_chocolate    CONSTANT PLS_INTEGER := 16;
   c_strawberry   CONSTANT PLS_INTEGER := 29;

   -- A nested table TYPE declaration
   TYPE codes_nt IS TABLE OF INTEGER;

   -- A nested table declared from the generic type.
   my_favorites   codes_nt;

   -- A REF CURSOR returning favorites information.
   TYPE fav_info_rct IS REF CURSOR
      RETURN favorites%ROWTYPE;

   -- A procedure that accepts a list of favorites
   -- (using a type defined above) and displays the
   -- favorite information from that list.
   PROCEDURE show_favorites (list_in IN codes_nt);

   -- A function that returns all the information in
   -- the favorites table about the most popular item.
   FUNCTION most_popular
      RETURN fav_info_rct;
END favorites_pkg;
/

CREATE OR REPLACE PACKAGE BODY favorites_pkg
IS
   -- A private variable
   g_most_popular   PLS_INTEGER;

   -- Implementation of procedure
   PROCEDURE show_favorites (list_in IN codes_nt)
   IS
   BEGIN
      FOR indx IN list_in.FIRST .. list_in.LAST
      LOOP
         DBMS_OUTPUT.put_line (list_in (indx));
      END LOOP;
   END show_favorites;

   -- Implement the function
   FUNCTION most_popular
      RETURN fav_info_rct
   IS
      retval    fav_info_rct;
      null_cv   fav_info_rct;
   BEGIN
      OPEN retval FOR
         SELECT *
           FROM favorites
          WHERE code = g_most_popular;

      RETURN retval;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN null_cv;
   END most_popular;

   PROCEDURE analyze_favorites (year_in IN INTEGER)
   IS
   BEGIN
      -- dummy code.
      NULL;
   END analyze_favorites;
BEGIN
   g_most_popular := c_chocolate;

   analyze_favorites (EXTRACT (YEAR FROM SYSDATE));
END favorites_pkg;
/

