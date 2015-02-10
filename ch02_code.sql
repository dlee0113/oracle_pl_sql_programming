/*
Oracle PL/SQL Programming 5th Edition

www.stevenfeuerstein.com/books

Objection creation and example scripts for Chapter 2

You will find below all non-trivial code snippets from the above chapter
that are NOT contained in their own files (as specified in the chapter),
plus any DDL object creation scripts required to get a clean compile
on the snippets.

Any references to Oracle's standard HR tables (employees, departments,
locations, regions, etc.) will NOT include the DDL creation scripts
in this file. Instead, run the hr_schema_install.sql script and all
those tables and related elements will be defined.
*/

BEGIN
   DBMS_OUTPUT.put_line ('Hey look, ma!');
END;
/

CREATE OR REPLACE FUNCTION wordcount (str IN VARCHAR2)
   RETURN PLS_INTEGER
AS
   words           PLS_INTEGER := 0;
   len             PLS_INTEGER := NVL (LENGTH (str), 0);
   inside_a_word   BOOLEAN;
BEGIN
   FOR i IN 1 .. len + 1
   LOOP
      IF ASCII (SUBSTR (str, i, 1)) < 33 OR i > len
      THEN
         IF inside_a_word
         THEN
            words := words + 1;
            inside_a_word := FALSE;
         END IF;
      ELSE
         inside_a_word := TRUE;
      END IF;
   END LOOP;

   RETURN words;
END;
/

BEGIN
   DBMS_OUTPUT.put_line (
      'There are ' || wordcount (CHR (9)) || ' words in a tab'
   );
END;
/

SELECT isbn, wordcount (description)
  FROM books
/

SELECT table_name, grantee, privilege
  FROM user_tab_privs_made
 WHERE table_name = 'WORDCOUNT'
/
