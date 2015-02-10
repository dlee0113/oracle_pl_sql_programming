/*

Which choices show:

Carrera
Corvette

*/

CREATE TABLE plch_autos
(
   auto_name   VARCHAR2 (100),
   auto_type   VARCHAR2 (100)
)
/

BEGIN
   INSERT INTO plch_autos
        VALUES ('Corvette', 'Sports');

   INSERT INTO plch_autos
        VALUES ('Yugo', 'Not Really');

   INSERT INTO plch_autos
        VALUES ('Carrera', 'Sports');

   COMMIT;
END;
/

/* Pre 12c, had to write code to display results. */

CREATE OR REPLACE PROCEDURE plch_show_autos (
   auto_type_in   IN plch_autos.auto_type%TYPE)
IS
BEGIN
   FOR rec IN (  SELECT auto_name
                   FROM plch_autos
                  WHERE auto_type = auto_type_in
               ORDER BY auto_name)
   LOOP
      DBMS_OUTPUT.put_line (rec.auto_name);
   END LOOP;
END;
/

BEGIN
   plch_show_autos ('Sports');
END;
/

/* New RETURN_RESULT procedure in 12c -
   SQL*Plus handles the output automatically. */

CREATE OR REPLACE PROCEDURE plch_show_autos (
   auto_type_in   IN plch_autos.auto_type%TYPE)
IS
   l_cursor   SYS_REFCURSOR;
BEGIN
   OPEN l_cursor FOR
        SELECT auto_name
          FROM plch_autos
         WHERE auto_type = auto_type_in
      ORDER BY auto_name;

   DBMS_SQL.return_result (l_cursor);
END;
/

BEGIN
   plch_show_autos ('Sports');
END;
/

/* Straight SQL */

  SELECT auto_name
    FROM plch_autos
   WHERE auto_type = 'Sports'
ORDER BY auto_name
/

/* Clean up */

DROP PROCEDURE plch_show_autos
/

DROP TABLE plch_autos
/