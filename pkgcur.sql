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
   CURSOR byauthor_cur (
      author_in   IN   books.author%TYPE
   )
   IS
      SELECT *
        FROM books
       WHERE author = author_in;

   CURSOR bytitle_cur (
      title_filter_in  IN   books.title%TYPE
   ) RETURN books%ROWTYPE;

   TYPE author_summary_rt IS RECORD (
      author                        books.author%TYPE,
      total_page_count              PLS_INTEGER,
      total_book_count              PLS_INTEGER);

   CURSOR summary_cur (
      author_in   IN   books.author%TYPE
   ) RETURN author_summary_rt;

   PROCEDURE display ( 
      book_rec IN books%ROWTYPE
   );
 
END book_info;
/

CREATE OR REPLACE PACKAGE BODY book_info
IS
   CURSOR bytitle_cur (
      title_filter_in   IN   books.title%TYPE
   ) RETURN books%ROWTYPE
   IS
      SELECT *
        FROM books
       WHERE title LIKE UPPER (title_filter_in);

   CURSOR summary_cur (
      author_in   IN   books.author%TYPE
   ) RETURN author_summary_rt
   IS
      SELECT author, SUM (page_count), COUNT (*)
        FROM books
       WHERE author = author_in;
   
   PROCEDURE display (
      book_rec IN books%ROWTYPE
   )
   IS
   BEGIN
      /* This Implementation is Just a Stub, Presumably to be Replaced by */
      /* Something that Does Something Meaningful Later On */

      /* Null is a No-Op. */
      /* The Statement is Included to Satisfy the Compile-Time Syntax-Checker */
      NULL;
   END;

END book_info;
/
