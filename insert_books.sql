REM Script to insert various sample records for books

REM Note: Must SET DEFINE OFF or else SQL*Plus will intercept the ampersand
REM characters (&)before they get sent to the server.  SQL*Plus usually uses
REM an ampersand to denote a variable that requires the user to supply a
REM value interactively.

SET DEFINE OFF

DECLARE
   PROCEDURE insert_book_no_complaints(isbn_in IN VARCHAR2, title_in IN VARCHAR2,
      summary_in IN VARCHAR2, author_in IN VARCHAR2, date_published_in IN DATE,
      page_count_in IN NUMBER)
   IS
   BEGIN
      INSERT INTO books (isbn, title, summary, author, date_published,
                         page_count)
      VALUES (isbn_in, title_in, summary_in, author_in, date_published_in,
              page_count_in);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX
      THEN
         NULL;
   END;

BEGIN

   insert_book_no_complaints ('0-596-00381-1', 
      'Oracle PL/SQL Programming',
      'Reference for PL/SQL developers, including examples and best practice '
         || 'recommendations.',
      'Feuerstein, Steven, with Bill Pribyl',
      '25-Sep-2002', /* best guess as of 22 Aug 02 */
      NULL); /* don't know page count yet */

   insert_book_no_complaints ('0-596-00180-0',
      'Learning Oracle PL/SQL',
      'Beginner''s guide to Oracle''s PL/SQL Programming Language',
      'Bill Pribyl with Steven Feuerstein',
      '29-Nov-2001',
      401);

   insert_book_no_complaints ('1-56592-578-5',
      'Oracle SQL*Plus: The Definitive Guide',
      'Comprehensive treatment of Oracle''s interactive database tool',
      'Gennick, Jonathan',
      '01-Mar-1999',
      502);

   insert_book_no_complaints ('1-56592-457-6',
      'Oracle PL/SQL Language Pocket Reference',
      'Quick-reference guide for Oracle PL/SQL developers.  Includes Oracle8i '
         || 'coverage.',
      'Feuerstein, Steven, Bill Pribyl, Chip Dawes',
      '01-APR-1999', 94);

   insert_book_no_complaints ('0-14071-483-9',
      'The tragedy of King Richard the Third',
      'Modern publication of popular Shakespeare historical play in which a '
         || 'treacherous royal attempts to steal the crown but dies horseless '
         || 'in battle.',
      'Shakespeare, William',
      '01-AUG-2000',
      158);

   insert_book_no_complaints ('0-14-071415-4',
      'The Tempest',
      'Duke and daughter on enchanted island encounters former enemies in this '
         || 'comic tale of mystery, love, magic, and (ultimately) forgiveness.',
      'Shakespeare, William',
      '01-JAN-1959',
      120);

   insert_book_no_complaints ('0-672-31798-2',
      'Sams Teach Yourself PL/SQL in 21 Days, Second Edition',
      'Tutorial for Oracle''s procedural language organized around presenting '
         || 'language features in a three-week learning schedule.',
      'Gennick, Jonathan, with Tom Luers',
      '01-DEC-1999',
      692);

   insert_book_no_complaints ('0-07-882438-9',
      'Oracle PL/SQL Tips & Techniques',
      'Voluminous tome presenting tips, techniques, and reference material on '
         || 'Oracle''s PL/SQL.',
      'Trezzo, Joseph C.',
      '01-JUL-1999',
      942);

   insert_book_no_complaints ('0-13-794314-8',
      'Building Intelligent Databases with Oracle PL/SQL Triggers and Stored '
         || 'Procedures-2nd ed.',
      'Programmer''s guide to PL/SQL, targeted toward building reusable '
         || 'components for large Oracle applications.',
      'Owens, Kevin T.',
      '01-JUN-1999',
      544);

   insert_book_no_complaints ('1-56592-674-9',
      'Oracle PL/SQL Developer''s Workbook',
      'Beginner, intermediate, and advanced exercises designed to test the '
         || 'reader''s knowledge of Oracle''s PL/SQL programming language.',
      'Feuerstein, Steven, with Andrew Odewahn',
      '01-May-1999',
      588);


END;
/

COMMIT;

SET DEFINE ON



/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
