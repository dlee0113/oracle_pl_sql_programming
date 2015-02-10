DROP TABLE books
/

CREATE TABLE books (title VARCHAR2 (100), isbn VARCHAR2 (100))
/

CREATE OR REPLACE FUNCTION booktitle (isbn_in IN VARCHAR2)
   RETURN VARCHAR2
IS
   l_title   books.title%TYPE;

   CURSOR icur
   IS
      SELECT title
        FROM books
       WHERE isbn = isbn_in;
BEGIN
   OPEN icur;

   FETCH icur
   INTO l_title;

   CLOSE icur;

   RETURN l_title;
END;
/

