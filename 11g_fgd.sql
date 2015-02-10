CREATE OR REPLACE PROCEDURE show_proc_status (
   change_in      IN   VARCHAR2
 , owner_in       IN   VARCHAR2
 , NAME_IN        IN   VARCHAR2
 , recompile_in   IN   BOOLEAN DEFAULT TRUE
)
IS
   l_status   all_objects.status%TYPE;
BEGIN
   SELECT status
     INTO l_status
     FROM all_objects
    WHERE owner = owner_in
      AND object_name = NAME_IN
      AND object_type = 'PROCEDURE';

   DBMS_OUTPUT.put_line ('After "' || change_in || '"');
   DBMS_OUTPUT.put_line (   '   Status of '
                         || owner_in
                         || '.'
                         || NAME_IN
                         || ' = '
                         || l_status
                        );

   IF l_status = 'INVALID' AND recompile_in
   THEN
      EXECUTE IMMEDIATE    'alter procedure '
                        || owner_in
                        || '.'
                        || NAME_IN
                        || ' COMPILE REUSE SETTINGS';
   END IF;
END show_proc_status;
/

CREATE OR REPLACE PACKAGE pkg1
IS
   PROCEDURE proc1 (a IN VARCHAR2);

   FUNCTION func1
      RETURN VARCHAR2;
END pkg1;
/

CREATE OR REPLACE PROCEDURE use_pkg1
IS
   l_name   employees.last_name%TYPE;
BEGIN
   SELECT last_name
     INTO l_name
     FROM employees
    WHERE employee_id = 198;

   pkg1.proc1 ('a');
END use_pkg1;
/

BEGIN
   show_proc_status ('Freshly Compiled', USER, 'USE_PKG1');
END;
/

/* Change size of last_name column - status should be INVALID. */

ALTER TABLE employees MODIFY last_name VARCHAR2(2000)
/

BEGIN
   show_proc_status ('Change LAST_NAME Column', USER, 'USE_PKG1');
END;
/

/* Now set column back to original size and recompile procedure
   so that the status is now valid again. */

ALTER TABLE employees MODIFY last_name VARCHAR2(25)
/
ALTER PROCEDURE use_pkg1 COMPILE REUSE SETTINGS
/

BEGIN
   show_proc_status ('After Recompile', USER, 'USE_PKG1');
END;
/

/* Add a new function - should not affect status. */

CREATE OR REPLACE PACKAGE pkg1
IS
   PROCEDURE proc1 (a IN VARCHAR2);

   FUNCTION func1
      RETURN VARCHAR2;

   FUNCTION func2
      RETURN NUMBER;
END pkg1;
/

BEGIN
   show_proc_status ('Add new function', USER, 'USE_PKG1');
END;
/

/* Add column to employees; should not affect status. */

ALTER TABLE employees ADD nickname VARCHAR2(100)
/

BEGIN
   show_proc_status ('Add new column', USER, 'USE_PKG1');
END;
/

ALTER TABLE employees DROP COLUMN nickname
/
/* Add new IN parameter with trailing default */

CREATE OR REPLACE PACKAGE pkg1
IS
   PROCEDURE proc1 (a IN VARCHAR2, b IN PLS_INTEGER DEFAULT NULL);

   FUNCTION func1
      RETURN VARCHAR2;

   FUNCTION func2
      RETURN NUMBER;
END pkg1;
/

BEGIN
   show_proc_status ('Add new parameter', USER, 'USE_PKG1');
END;
/

/* Change datatype of argument that is used; should affect status. */

CREATE OR REPLACE PACKAGE pkg1
IS
   PROCEDURE proc1 (a IN DATE);

   FUNCTION func1
      RETURN VARCHAR2;

   FUNCTION func2
      RETURN NUMBER;
END pkg1;
/

BEGIN
   show_proc_status ('Change parameter type to DATE', USER, 'USE_PKG1');
END;
/