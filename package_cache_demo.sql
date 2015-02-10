DROP TABLE products
/

CREATE TABLE products
(
   product_number   INTEGER PRIMARY KEY
 , description      VARCHAR2 (1000)
)
/

DECLARE
   TYPE products_t IS TABLE OF products%ROWTYPE
                         INDEX BY PLS_INTEGER;

   l_rows   products_t;
BEGIN
   FOR indx IN 1 .. 10000
   LOOP
      l_rows (indx).product_number := indx;
      l_rows (indx).description := 'Product ' || TO_CHAR (indx);
   END LOOP;

   FORALL indx IN 1 .. 10000
      INSERT INTO products
          VALUES l_rows (indx);

   COMMIT;
END;
/

CREATE OR REPLACE PACKAGE products_cache
IS
   FUNCTION with_sql (product_number_in IN products.product_number%TYPE)
      RETURN products%ROWTYPE;

   FUNCTION from_cache (product_number_in IN products.product_number%TYPE)
      RETURN products%ROWTYPE;

   FUNCTION jit_from_cache (product_number_in IN products.product_number%TYPE
                           )
      RETURN products%ROWTYPE;
END products_cache;
/

CREATE OR REPLACE PACKAGE BODY products_cache
IS
   TYPE cache_t IS TABLE OF products%ROWTYPE
                      INDEX BY PLS_INTEGER;

   g_cache   cache_t;

   FUNCTION with_sql (product_number_in IN products.product_number%TYPE)
      RETURN products%ROWTYPE
   IS
      l_row   products%ROWTYPE;
   BEGIN
      SELECT *
        INTO l_row
        FROM products
       WHERE product_number = product_number_in;

      RETURN l_row;
   END with_sql;

   FUNCTION from_cache (product_number_in IN products.product_number%TYPE)
      RETURN products%ROWTYPE
   IS
   BEGIN
      RETURN g_cache (product_number_in);
   END from_cache;

   FUNCTION jit_from_cache (product_number_in IN products.product_number%TYPE
                           )
      RETURN products%ROWTYPE
   IS
      l_row   products%ROWTYPE;
   BEGIN
      IF g_cache.EXISTS (product_number_in)
      THEN
         l_row := g_cache (product_number_in);
      ELSE
         l_row := with_sql (product_number_in);
         g_cache (product_number_in) := l_row;
      END IF;

      RETURN l_row;
   END jit_from_cache;
BEGIN
   SELECT *
     BULK COLLECT
     INTO g_cache
     FROM products;
END products_cache;
/

DECLARE
   l_row   products%ROWTYPE;
BEGIN
   sf_timer.start_timer;

   FOR indx IN 1 .. 100000
   LOOP
      l_row := products_cache.from_cache (5000);
   END LOOP;

   sf_timer.show_elapsed_time ('Package cache');
   --
   sf_timer.start_timer;

   FOR indx IN 1 .. 100000
   LOOP
      l_row := products_cache.with_sql (5000);
   END LOOP;

   sf_timer.show_elapsed_time ('Run query every time');
   --
   sf_timer.start_timer;

   FOR indx IN 1 .. 100000
   LOOP
      l_row := products_cache.jit_from_cache (5000);
   END LOOP;

   sf_timer.show_elapsed_time ('Just in time cache');
/*
Cache table Elapsed: .14 seconds.
Run query every time Elapsed: 4.7 seconds.
*/
END;
/