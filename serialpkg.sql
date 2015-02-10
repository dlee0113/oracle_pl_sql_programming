DROP TABLE books
/

CREATE TABLE books
(
   author       VARCHAR2 (100) NOT NULL
 , title        VARCHAR2 (250) NOT NULL
 , page_count   NUMBER (5)
 , CONSTRAINT pk_books PRIMARY KEY (author, title)
)
/

CREATE OR REPLACE PACKAGE book_info
IS
   PRAGMA SERIALLY_REUSABLE;

   PROCEDURE fill_list;

   PROCEDURE show_list;
END;
/

CREATE OR REPLACE PACKAGE BODY book_info
IS
   PRAGMA SERIALLY_REUSABLE;

   TYPE book_list_t
   IS
      TABLE OF books%ROWTYPE
         INDEX BY PLS_INTEGER;

   my_books   book_list_t;

   PROCEDURE fill_list
   IS
   BEGIN
      FOR rec IN (SELECT *
                    FROM books
                   WHERE author LIKE '%FEUERSTEIN%')
      LOOP
         my_books (my_books.COUNT + 1) := rec;
      END LOOP;
   END fill_list;

   PROCEDURE show_list
   IS
   BEGIN
      IF my_books.COUNT = 0
      THEN
         DBMS_OUTPUT.put_line ('** No books to show you...');
      ELSE
         FOR indx IN 1 .. my_books.COUNT
         LOOP
            DBMS_OUTPUT.put_line (my_books (indx).title);
         END LOOP;
      END IF;
   END show_list;
END;
/



/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/