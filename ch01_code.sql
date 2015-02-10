/*
Oracle PL/SQL Programming 5th Edition

www.stevenfeuerstein.com/books

Objection creation and example scripts for Chapter 1

You will find below all non-trivial code snippets from the above chapter
that are NOT contained in their own files (as specified in the chapter),
plus any DDL object creation scripts required to get a clean compile
on the snippets.

Any references to Oracle's standard HR tables (employees, departments,
locations, regions, etc.) will NOT include the DDL creation scripts
in this file. Instead, run the hr_schema_install.sql script and all
those tables and related elements will be defined.
*/

CREATE TABLE books (author VARCHAR2 (100))
/

DECLARE
   l_book_count   INTEGER;
BEGIN
   SELECT COUNT ( * )
     INTO l_book_count
     FROM books
    WHERE author LIKE '%FEUERSTEIN, STEVEN%';

   DBMS_OUTPUT.put_line (
      'Steven has written (or co-written) ' || l_book_count || ' books.'
   );

   -- Oh, and I changed my name, so...
   UPDATE books
      SET author = REPLACE (author, 'STEVEN', 'STEPHEN')
    WHERE author LIKE '%FEUERSTEIN, STEVEN%';
END;
/

CREATE TABLE accounts (id INTEGER, name VARCHAR2 (100))
/

CREATE OR REPLACE FUNCTION account_balance (account_id_in IN accounts.id%TYPE
                                           )
   RETURN NUMBER
IS
BEGIN
   RETURN 0;
END;
/

CREATE OR REPLACE PROCEDURE apply_balance (account_id_in IN accounts.id%TYPE
                                         , balance_in    IN NUMBER
                                          )
IS
BEGIN
   NULL;
END;
/

CREATE OR REPLACE PROCEDURE pay_out_balance (
   account_id_in IN accounts.id%TYPE
)
IS
   l_balance_remaining   NUMBER;
BEGIN
   LOOP
      l_balance_remaining := account_balance (account_id_in);

      IF l_balance_remaining < 1000
      THEN
         EXIT;
      ELSE
         apply_balance (account_id_in, l_balance_remaining);
      END IF;
   END LOOP;
END pay_out_balance;
/

CREATE OR REPLACE PROCEDURE log_error
IS
BEGIN
   NULL;
END;
/

CREATE OR REPLACE PROCEDURE check_account (account_id_in IN accounts.id%TYPE)
IS
   l_balance_remaining   NUMBER;
   l_balance_below_minimum exception;
   l_account_name        accounts.name%TYPE;
BEGIN
   SELECT name
     INTO l_account_name
     FROM accounts
    WHERE id = account_id_in;

   l_balance_remaining := account_balance (account_id_in);

   DBMS_OUTPUT.put_line (
      'Balance for ' || l_account_name || ' = ' || l_balance_remaining
   );

   IF l_balance_remaining < 1000
   THEN
      RAISE l_balance_below_minimum;
   END IF;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      -- No account found for this ID
      log_error ();
   WHEN l_balance_below_minimum
   THEN
      log_error ();
      RAISE;
END;
/

BEGIN
   FOR l_index IN 1 .. 10
   LOOP
      CONTINUE WHEN MOD (l_index, 2) = 0;
      DBMS_OUTPUT.PUT_LINE ('Loop index = ' || TO_CHAR (l_index));
   END LOOP;
END;
/