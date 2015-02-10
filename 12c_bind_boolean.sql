CREATE OR REPLACE PACKAGE restaurant_pkg
AS
   TYPE item_list_t
      IS TABLE OF VARCHAR2 (30);

   PROCEDURE eat_that (
      items_in              IN item_list_t,
      make_it_spicy_in_in   IN BOOLEAN);
END;
/

CREATE OR REPLACE PACKAGE BODY restaurant_pkg
AS
   PROCEDURE eat_that (
      items_in              IN item_list_t,
      make_it_spicy_in_in   IN BOOLEAN)
   IS
   BEGIN
      FOR indx IN 1 .. items_in.COUNT
      LOOP
         DBMS_OUTPUT.put_line (
               CASE
                  WHEN make_it_spicy_in_in
                  THEN
                     'Spicy '
               END
            || items_in (indx));
      END LOOP;
   END;
END;
/

DECLARE
   things   restaurant_pkg.item_list_t
      := restaurant_pkg.item_list_t (
            'steak',
            'quiche',
            'eggplant');
BEGIN
   /* Requires Oracle Database 12c or later */
   EXECUTE IMMEDIATE
      'BEGIN restaurant_pkg.eat_that(:l, :s); END;'
      USING things, TRUE;
END;
/