ALTER SESSION SET plscope_settings='identifiers:all'
/

CREATE OR REPLACE PACKAGE plscope_demo
IS
   PROCEDURE my_procedure (param1_in   IN INTEGER
                         , param2      IN employees.last_name%TYPE);
END plscope_demo;
/

CREATE OR REPLACE PACKAGE BODY plscope_demo
IS
   PROCEDURE my_procedure (param1_in   IN INTEGER
                         , param2      IN employees.last_name%TYPE)
   IS
      c_no_such   CONSTANT NUMBER := 100;
      l_local_variable     NUMBER;
   BEGIN
      IF param1_in > l_local_variable
      THEN
         DBMS_OUTPUT.put_line (param2);
      ELSE
         DBMS_OUTPUT.put_line (c_no_such);
      END IF;
   END my_procedure;

   FUNCTION my_priv_function
      RETURN NUMBER
   IS
   BEGIN
      RETURN 0;
   END;
END plscope_demo;
/

WITH plscope_hierarchy
     AS (SELECT line
              , col
              , name
              , TYPE
              , usage
              , usage_id
              , usage_context_id
           FROM all_identifiers
          WHERE     owner = USER
                AND object_name = 'PLSCOPE_DEMO'
                AND object_type = 'PACKAGE BODY')
           SELECT    LPAD (' ', 3 * (LEVEL - 1))
                  || TYPE
                  || ' '
                  || name
                  || ' ('
                  || usage
                  || ')'
                     identifier_hierarchy
             FROM plscope_hierarchy
       START WITH usage_context_id = 0
       CONNECT BY PRIOR usage_id = usage_context_id
ORDER SIBLINGS BY line, col
/

CREATE OR REPLACE PACKAGE plscope_demo
IS
   PROCEDURE my_procedure (param1_in IN INTEGER, param2 IN DATE);

   FUNCTION my_function (param1      IN INTEGER
                       , in_param2   IN DATE
                       , param3_in   IN employees.last_name%TYPE)
      RETURN VARCHAR2;
END plscope_demo;
/

  SELECT prog.name subprogram, parm.name parameter
    FROM all_identifiers parm, all_identifiers prog
   WHERE     parm.owner = USER
         AND parm.object_name = 'PLSCOPE_DEMO'
         AND parm.object_type = 'PACKAGE'
         AND prog.owner = parm.owner
         AND prog.object_name = parm.object_name
         AND prog.object_type = parm.object_type
         AND parm.usage_context_id = prog.usage_id
         AND parm.TYPE IN ('FORMAL IN', 'FORMAL IN OUT', 'FORMAL OUT')
         AND parm.usage = 'DECLARATION'
         AND ( (parm.TYPE = 'FORMAL IN'
                AND LOWER (parm.name) NOT LIKE '%\_in' ESCAPE '\')
              OR (parm.TYPE = 'FORMAL OUT'
                  AND LOWER (parm.name) NOT LIKE '%\_out' ESCAPE '\')
              OR (parm.TYPE = 'FORMAL IN OUT'
                  AND LOWER (parm.name) NOT LIKE '%\_io' ESCAPE '\'))
ORDER BY prog.name, parm.name
/

CREATE OR REPLACE PROCEDURE plscope_demo_proc
IS
   plscope_demo_proc   NUMBER;
BEGIN
   DECLARE
      plscope_demo_proc   EXCEPTION;
   BEGIN
      RAISE plscope_demo_proc;
   END;

   plscope_demo_proc := 1;
END plscope_demo_proc;
/

/* Find all occurrences of a given name */

  SELECT line
       , name
       , TYPE
       , usage
       , signature
    FROM all_identifiers
   WHERE     owner = USER
         AND object_name = 'PLSCOPE_DEMO_PROC'
         AND name = 'PLSCOPE_DEMO_PROC'
ORDER BY line
/

/* Find all usages of a variable declared with a given name */

  SELECT usg.line, usg.TYPE, usg.usage
    FROM all_identifiers dcl, all_identifiers usg
   WHERE     dcl.owner = USER
         AND dcl.object_name = 'PLSCOPE_DEMO_PROC'
         AND dcl.name = 'PLSCOPE_DEMO_PROC'
         AND dcl.usage = 'DECLARATION'
         AND dcl.TYPE = 'VARIABLE'
         AND usg.signature = dcl.signature
         AND usg.usage <> 'DECLARATION'
ORDER BY line
/

/* Exception declared but never raised and/or handled */

CREATE OR REPLACE PROCEDURE plscope_demo_proc
IS
   e_bad_data   EXCEPTION;
   PRAGMA EXCEPTION_INIT (e_bad_data, -20900);
BEGIN
   RAISE e_bad_data;
EXCEPTION
   WHEN e_bad_data
   THEN
      log_error ();
END plscope_demo_proc;
/

/* Show all usages of this exception */

  SELECT line
       , TYPE
       , usage
       , signature
    FROM all_identifiers
   WHERE     owner = USER
         AND object_name = 'PLSCOPE_DEMO_PROC'
         AND name = 'E_BAD_DATA'
ORDER BY line
/

/* Now identify programs with declared but not used exceptions */

CREATE OR REPLACE PROCEDURE plscope_demo_proc
IS
   e_bad_data    EXCEPTION;
   PRAGMA EXCEPTION_INIT (e_bad_data, -20900);
   e_bad_data2   EXCEPTION;
BEGIN
   RAISE e_bad_data2;
EXCEPTION
   WHEN e_bad_data2
   THEN
      log_error ();
END plscope_demo_proc;
/

WITH subprograms_with_exception
     AS (SELECT DISTINCT owner
                       , object_name
                       , object_type
                       , name
           FROM all_identifiers has_exc
          WHERE     has_exc.owner = USER
                AND has_exc.usage = 'DECLARATION'
                AND has_exc.TYPE = 'EXCEPTION'),
     subprograms_with_raise_handle
     AS (SELECT DISTINCT owner
                       , object_name
                       , object_type
                       , name
           FROM all_identifiers with_rh
          WHERE     with_rh.owner = USER
                AND with_rh.usage = 'REFERENCE'
                AND with_rh.TYPE = 'EXCEPTION')
SELECT * FROM subprograms_with_exception
MINUS
SELECT * FROM subprograms_with_raise_handle
/

/* Package level variables in the specification */

SELECT object_name, name, line
  FROM all_identifiers ai
 WHERE     ai.owner = USER
       AND ai.TYPE = 'VARIABLE'
       AND ai.usage = 'DECLARATION'
       AND ai.object_type = 'PACKAGE'
/