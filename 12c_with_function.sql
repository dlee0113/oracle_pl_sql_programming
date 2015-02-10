WITH FUNCTION full_name (fname_in IN VARCHAR2, lname_in IN VARCHAR2)
        RETURN VARCHAR2
     IS
     BEGIN
        RETURN fname_in || ' ' || lname_in;
     END;

SELECT full_name (first_name, last_name)
  FROM employees;

/* Sadly, does not work inside PL/SQL! 

 ORA-00905: missing keyword
 
*/

DECLARE
   c   NUMBER;

BEGIN
   WITH FUNCTION full_name (fname_in IN VARCHAR2, lname_in IN VARCHAR2)
           RETURN VARCHAR2
        IS
        BEGIN
           RETURN fname_in || ' ' || lname_in;
        END;

   SELECT LENGTH (full_name (first_name, last_name))
     INTO c
     FROM employees;


   DBMS_OUTPUT.put_line ('count = ' || c);
END;
/

/* How about in a view, and query that in PL/SQL? 

PLS-103: Encountered the symbol "end-of-file" when expecting one of the following:

*/

CREATE OR REPLACE VIEW full_names_v
AS
   WITH FUNCTION full_name (fname_in IN VARCHAR2, lname_in IN VARCHAR2)
           RETURN VARCHAR2
        IS
        BEGIN
           RETURN fname_in || ' ' || lname_in;
     END;

SELECT full_name (first_name, last_name) the_full_name FROM employees
/