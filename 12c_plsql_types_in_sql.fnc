CREATE OR REPLACE FUNCTION uc_last_name (
   employee_id_in   IN employees.employee_id%TYPE,
   upper_in         IN BOOLEAN)
   RETURN employees.last_name%TYPE
IS
   l_return   employees.last_name%TYPE;
BEGIN
   SELECT last_name
     INTO l_return
     FROM employees
    WHERE employee_id = employee_id_in;

   RETURN CASE WHEN upper_in THEN UPPER (l_return) ELSE l_return END;
END;
/

/* Note: this does NOT work in 12c beta */

BEGIN
   FOR rec IN (SELECT uc_last_name (employee_id, TRUE) lname
                 FROM employees
                WHERE department_id = 10)
   LOOP
      DBMS_OUTPUT.put_line (rec.lname);
   END LOOP;
END;
/

/* This does */

DECLARE
   l_uc   BOOLEAN := TRUE;
BEGIN
   EXECUTE IMMEDIATE
      'BEGIN DBMS_OUTPUT.PUT_LINE (uc_last_name (138, :b)); END;'
      USING l_uc;
END;
/

CREATE OR REPLACE FUNCTION is_it_null (value_in IN VARCHAR2)
   RETURN BOOLEAN
IS
BEGIN
   RETURN value_in IS NULL;
END;
/

/* But you cannot RETURN a Boolean */

DECLARE
   l_uc   BOOLEAN := TRUE;
BEGIN
   EXECUTE IMMEDIATE 'BEGIN :is_it_null := is_it_null (''abc''); END;'
      USING l_uc;
END;
/

/* Straight from the doc, but does not work - yet? 

ORA-06550: line 8, column 28:
PLS-00382: expression is of wrong type
ORA-06550: line 8, column 25:
PLS-00306: wrong number or types of arguments in call to 'F'
ORA-06550: line 8, column 25:
PL/SQL: ORA-00904: "F": invalid identifier
ORA-06550: line 5, column 4:
PL/SQL: SQL Statement ignored
ORA-06550: line 16, column 28:
PLS-00382: expression is of wrong type
ORA-06550: line 16, column 25:
PLS-00306: wrong number or types of arguments in call to 'F'
ORA-06550: line 16, column 25:
PL/SQL: ORA-00904: "F": invalid identifier
ORA-06550: line 13, column 4:
PL/SQL: SQL Statement ignored

*/

CREATE OR REPLACE FUNCTION f (x BOOLEAN, y PLS_INTEGER)
   RETURN employees.employee_id%TYPE
   AUTHID CURRENT_USER
AS
BEGIN
   IF x
   THEN
      RETURN y;
   ELSE
      RETURN 2 * y;
   END IF;
END;
/

DECLARE
   name   employees.last_name%TYPE;
   b      BOOLEAN := TRUE;
BEGIN
   SELECT last_name
     INTO name
     FROM employees
    WHERE employee_id = f (b, 100);

   DBMS_OUTPUT.put_line (name);
   b := FALSE;

   SELECT last_name
     INTO name
     FROM employees
    WHERE employee_id = f (b, 100);

   DBMS_OUTPUT.put_line (name);
END;
/

/* Query from a package-based associative array! */

CREATE OR REPLACE PACKAGE pkg
   AUTHID DEFINER
AS
   TYPE rec IS RECORD
   (
      f1   NUMBER,
      f2   VARCHAR2 (30)
   );

   TYPE mytab IS TABLE OF rec
      INDEX BY PLS_INTEGER;
END;
/

DECLARE
   v1   pkg.mytab;  
   v2   pkg.rec;
   c1   SYS_REFCURSOR;
BEGIN
   OPEN c1 FOR SELECT * FROM TABLE (v1);

   FETCH c1 INTO v2;

   CLOSE c1;
END;
/

/* Using TABLE with associative arrays */

CREATE OR REPLACE TYPE list_of_names_t IS TABLE OF VARCHAR2 (100);
/

/* Works in 10 and 11, but not with associative arrays */

DECLARE
   happyfamily   list_of_names_t
                    := list_of_names_t ('Sally', 'Sam', 'Agatha');
BEGIN
   FOR rec IN (  SELECT COLUMN_VALUE family_name
                   FROM TABLE (happyfamily)
               ORDER BY family_name)
   LOOP
      DBMS_OUTPUT.put_line (rec.family_name);
   END LOOP;
END;
/

/* This works in 12.1 */

CREATE OR REPLACE PACKAGE names_pkg
IS
   TYPE list_of_names_t IS TABLE OF VARCHAR2 (100)
      INDEX BY PLS_INTEGER;
END;
/

DECLARE
   happyfamily   names_pkg.list_of_names_t;
BEGIN
   happyfamily (1) := 'Sally';
   happyfamily (2) := 'Sam';
   happyfamily (3) := 'Agatha';

   FOR rec IN (  SELECT COLUMN_VALUE family_name
                   FROM TABLE (happyfamily)
               ORDER BY family_name)
   LOOP
      DBMS_OUTPUT.put_line (rec.family_name);
   END LOOP;
END;
/

/* Read consistency? Yes! */


CREATE OR REPLACE PACKAGE names_pkg
IS
   TYPE list_of_names_t IS TABLE OF VARCHAR2 (100)
      INDEX BY PLS_INTEGER;
END;
/

DECLARE
   happyfamily   names_pkg.list_of_names_t;
BEGIN
   happyfamily (1) := 'Sally';
   happyfamily (2) := 'Sam';
   happyfamily (3) := 'Agatha';

   FOR rec IN (  SELECT COLUMN_VALUE family_name
                   FROM TABLE (happyfamily)
               ORDER BY family_name)
   LOOP
      happyfamily.delete;
      DBMS_OUTPUT.put_line (rec.family_name);
      DBMS_OUTPUT.put_line (happyfamily.COUNT);
   END LOOP;

   DBMS_OUTPUT.put_line (happyfamily.COUNT);
END;
/

/* How about performance? Compare NTs and AAs. 

Seem comparable for over 300,000 rows...

"AA" completed in: 1.01 seconds
"PKG-NT" completed in: 1 seconds
"SL-NT" completed in: 1.09 seconds

*/

CREATE OR REPLACE PACKAGE names_pkg
IS
   TYPE list_of_names_aa IS TABLE OF VARCHAR2 (100)
      INDEX BY PLS_INTEGER;

   TYPE list_of_names_nt IS TABLE OF VARCHAR2 (100);
END;
/

DECLARE
   happyfamily_aa     names_pkg.list_of_names_aa;
   happyfamily_nt     names_pkg.list_of_names_nt;
   /* Schema level type */
   happyfamily_slnt   list_of_names_t;
BEGIN
   SELECT substr (text, 1, 100)
     BULK COLLECT INTO happyfamily_aa
     FROM all_source;

   DBMS_OUTPUT.put_line (happyfamily_aa.COUNT);

   sf_timer.start_timer;

   FOR rec IN (  SELECT COLUMN_VALUE family_name
                   FROM TABLE (happyfamily_aa)
               ORDER BY family_name)
   LOOP
      NULL;
   END LOOP;

   sf_timer.show_elapsed_time('AA');

   happyfamily_aa.delete;

   DBMS_SESSION.free_unused_user_memory;
   
   /* Now packaged NT */
   
   SELECT substr (text, 1, 100)
     BULK COLLECT INTO happyfamily_nt
     FROM all_source;

   DBMS_OUTPUT.put_line (happyfamily_nt.COUNT);

   sf_timer.start_timer;

   FOR rec IN (  SELECT COLUMN_VALUE family_name
                   FROM TABLE (happyfamily_nt)
               ORDER BY family_name)
   LOOP
      NULL;
   END LOOP;

   sf_timer.show_elapsed_time('PKG-NT');

   happyfamily_nt.delete;

   DBMS_SESSION.free_unused_user_memory;   
   
   /* Now schema-level NT */
   
   SELECT substr (text, 1, 100)
     BULK COLLECT INTO happyfamily_slnt
     FROM all_source;

   DBMS_OUTPUT.put_line (happyfamily_slnt.COUNT);

   sf_timer.start_timer;

   FOR rec IN (  SELECT COLUMN_VALUE family_name
                   FROM TABLE (happyfamily_slnt)
               ORDER BY family_name)
   LOOP
      NULL;
   END LOOP;

   sf_timer.show_elapsed_time('SL-NT');

   happyfamily_slnt.delete;

   DBMS_SESSION.free_unused_user_memory;      
END;
/

