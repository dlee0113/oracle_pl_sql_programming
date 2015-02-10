/* Create procedure in parent edition */

CREATE OR REPLACE FUNCTION full_name (first_in IN employees.first_name%TYPE
                                    , last_in IN employees.first_name%TYPE
                                     )
   RETURN VARCHAR2
IS
BEGIN
   RETURN (first_in || ' ' || last_in);
END full_name;
/

/* Invoke procedure in parent edition */

BEGIN
   DBMS_OUTPUT.put_line (full_name ('Steven', 'Feuerstein'));
END;
/

/* Create child edition */

CREATE EDITION HR_PATCH_NAMEFORMAT
/

/* Use child edition: */
ALTER SESSION SET edition = HR_PATCH_NAMEFORMAT
/

/* In child edition, invoke procedure. Child edition inherits procedure from parent edition. 
   So the child edition invokes inherited procedure: */

BEGIN
   DBMS_OUTPUT.put_line (full_name ('Steven', 'Feuerstein'));
END;
/

/* Change procedure in child edition.
   Child changes only its own copy of procedure. Child's copy is an actual object. */


CREATE OR REPLACE FUNCTION full_name (first_in IN employees.first_name%TYPE
                                    , last_in IN employees.first_name%TYPE
                                     )
   RETURN VARCHAR2
IS
BEGIN
   RETURN (last_in || ', ' || first_in);
END full_name;
/

/* Invoke procedure. Child invokes its own copy, the actual procedure: */

BEGIN
   DBMS_OUTPUT.put_line (full_name ('Steven', 'Feuerstein'));
END;
/

/* Go back to parent edition */
ALTER SESSION SET edition = ora$base
/

/* Invoke procedure and see that it has not changed */

BEGIN
   DBMS_OUTPUT.put_line (full_name ('Steven', 'Feuerstein'));
END;
/