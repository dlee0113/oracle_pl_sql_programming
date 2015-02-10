CREATE TABLE property_master
(
   site_type   VARCHAR2 (100)
 , address     VARCHAR2 (100)
)
/

CREATE TABLE home_properties (address VARCHAR2 (100))
/

CREATE TABLE commercial_properties (address VARCHAR2 (100))
/

CREATE OR REPLACE PROCEDURE open_site_list (
   address_in     IN     VARCHAR2
 , site_cur_inout IN OUT sys_refcursor
)
IS
   home_type         CONSTANT PLS_INTEGER := 1;
   commercial_type   CONSTANT PLS_INTEGER := 2;

   /* A static cursor to get building type. */
   CURSOR site_type_cur
   IS
      SELECT site_type
        FROM property_master
       WHERE address = address_in;

   site_type_rec     site_type_cur%ROWTYPE;
BEGIN
   /* Get the building type for this address. */
   OPEN site_type_cur;

   FETCH site_type_cur
   INTO site_type_rec;

   CLOSE site_type_cur;

   /* Now use the site type to select from the right table.*/
   IF site_type_rec.site_type = home_type
   THEN
      /* Use the home properties table. */
      OPEN site_cur_inout FOR
         SELECT *
           FROM home_properties
          WHERE address LIKE '%' || address_in || '%';
   ELSIF site_type_rec.site_type = commercial_type
   THEN
      /* Use the commercial properties table. */
      OPEN site_cur_inout FOR
         SELECT *
           FROM commercial_properties
          WHERE address LIKE '%' || address_in || '%';
   END IF;
END open_site_list;
/

DECLARE
   /* Declare a cursor variable. */
   building_curvar   sys_refcursor;

   address_string    property_master.address%TYPE;

   /* Define record structures for two different tables. */
   home_rec          home_properties%ROWTYPE;
   commercial_rec    commercial_properties%ROWTYPE;

   FUNCTION current_address
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN NULL;
   END;

   PROCEDURE open_site_list (address_in IN     property_master.address%TYPE
                           , cv_out        OUT sys_refcursor
                            )
   IS
   BEGIN
      OPEN cv_out FOR
         SELECT *
           FROM home_properties;
   END;

   PROCEDURE show_home_site (home_in IN home_properties%ROWTYPE)
   IS
   BEGIN
      NULL;
   END;

   PROCEDURE show_commercial_site (home_in IN commercial_properties%ROWTYPE)
   IS
   BEGIN
      NULL;
   END;
BEGIN
   /* Retrieve the address from cookie or other source. */
   address_string := current_address ();

   /* Assign a query to the cursor variable based on the address. */
   open_site_list (address_string, building_curvar);

   /* Give it a try! Fetch a row into the home record. */
   FETCH building_curvar
   INTO home_rec;

   /* If I got here, the site was a home, so display it. */
   show_home_site (home_rec);
EXCEPTION
   /* If the first record was not a home... */
   WHEN ROWTYPE_MISMATCH
   THEN
      /* Fetch that same 1st row into the commercial record. */
      FETCH building_curvar
      INTO commercial_rec;

      /* Show the commercial site info. */
      show_commercial_site (commercial_rec);
END;
/