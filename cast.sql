/* Formatted on 2002/02/11 08:20 (Formatter Plus v4.6.0) */
DROP TYPE authors_t force;
DROP TYPE names_t force;
DROP table favorite_authors;

CREATE TYPE names_t AS TABLE OF VARCHAR2 (100);
/

CREATE TYPE authors_t AS TABLE OF VARCHAR2 (100);
/

CREATE TABLE favorite_authors (name varchar2(200))
/

BEGIN
   INSERT INTO favorite_authors
        VALUES ('Robert Harris');

   INSERT INTO favorite_authors
        VALUES ('Tom Segev');

   INSERT INTO favorite_authors
        VALUES ('Toni Morrison');

   COMMIT;
END;
/

DECLARE
   scifi_favorites   authors_t
      := authors_t ('Sheri S. Tepper', 'Orson Scott Card', 'Gene Wolfe');
BEGIN
   DBMS_OUTPUT.put_line ('I recommend that you read books by:');

   FOR rec IN  (SELECT column_value favs
                  FROM TABLE (CAST (scifi_favorites AS  names_t))
                UNION
                SELECT NAME
                  FROM favorite_authors)
   LOOP
      DBMS_OUTPUT.put_line (rec.favs);
   END LOOP;
END;

/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
