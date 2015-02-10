/* Inspired by work of Michael Rosenblum of Dulcian */

CREATE TABLE test_udf_table
AS
   SELECT *
     FROM all_objects
    WHERE ROWNUM <= 50000
/

CREATE OR REPLACE PACKAGE counter_pkg
IS
   g_number   NUMBER;
END;
/

CREATE OR REPLACE FUNCTION increment_no_udf (number_in NUMBER)
   RETURN NUMBER
IS
BEGIN
   counter_pkg.g_number := counter_pkg.g_number + 1;
   RETURN number_in + 1;
END;
/

CREATE OR REPLACE FUNCTION increment_with_udf (number_in NUMBER)
   RETURN NUMBER
IS
   PRAGMA UDF;
BEGIN
   counter_pkg.g_number := counter_pkg.g_number + 1;
   RETURN number_in + 1;
END;
/

DECLARE
   l_number   NUMBER;
BEGIN
   sf_timer.start_timer;

   SELECT MAX (increment_no_udf (object_id))
     INTO l_number
     FROM test_udf_table;

   sf_timer.show_elapsed_time ('Call function in SQL - NO UDF');

   SELECT MAX (increment_with_udf (object_id))
     INTO l_number
     FROM test_udf_table;

   sf_timer.show_elapsed_time (
      'Call function in SQL - WITH UDF');

   FOR i IN 1 .. 1000000
   LOOP
      l_number := increment_no_udf (i) + increment_no_udf (i + 1);
   END LOOP;

   sf_timer.show_elapsed_time ('Use in PL/SQL - NO UDF');

   FOR i IN 1 .. 1000000
   LOOP
      l_number :=
         increment_with_udf (i) + increment_with_udf (i + 1);
   END LOOP;

   sf_timer.show_elapsed_time ('Use in PL/SQL - WITH UDF');
END;
/

/* Clean up */

DROP TABLE test_udf_table
/