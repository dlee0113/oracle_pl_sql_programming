/*
PL/Scope Example from AMIS Blog, by Lucas Jellama

With permission of Lucas Jellama

http://technology.amis.nl/blog/2584/enforcing-plsql-naming-conventions-through-a-simple-sql-query-using-oracle-11g-plscope

*/
ALTER SESSION SET plscope_settings='identifiers:all'
/

CREATE OR REPLACE PACKAGE great_package
IS
   some_public_global_variable   NUMBER (10);
   g_and_another_one             BOOLEAN;

   PROCEDURE wonderful_program (input_param1 IN NUMBER, p_param2 IN OUT DATE)

;
END great_package;
/

CREATE OR REPLACE PACKAGE BODY great_package
IS
   TYPE emprec IS RECORD (l_name VARCHAR2 (20), job   VARCHAR2 (20));

   g_emp      emprec;
   global_1   POSITIVE;

   PROCEDURE wonderful_program (input_param1 IN NUMBER, p_param2 IN OUT DATE)
   IS
      name       VARCHAR2 (100) := 'LUCAS';
      v_salary   NUMBER (10, 2);
      b_job      VARCHAR2 (20);
      hiredate   DATE;
   BEGIN
      v_salary := 5432.12;
      DBMS_OUTPUT.put_line ('My Name is ' || name);
      DBMS_OUTPUT.put_line ('My Job is ' || b_job);
      hiredate := SYSDATE - 1;
      DBMS_OUTPUT.put_line ('I started this job on ' || hiredate);
   END wonderful_program;
END great_package;
/

/*
Here's a query to search for the following naming convention violations:

    * type definitions should be named starting with t_
    * names of global (package level) variables should start with g_
    * parameters are named p_<parameter description>
    * local variables have names starting with l_
    * variable and parameter names should be written in lowercase
    * plus: no global variables in package spec

*/

WITH identifiers
       AS (SELECT i.name
                , i.TYPE
                , i.usage
                , s.line
                , i.object_type
                , i.object_name
                , s.text source
             FROM    user_identifiers i
                  JOIN
                     user_source s
                  ON (    s.name = i.object_name
                      AND s.TYPE = i.object_type
                      AND s.line = i.line)
            WHERE object_name = 'GREAT_PACKAGE'),
    global_section
       AS (  SELECT MIN (line) end_line, object_name
               FROM identifiers
              WHERE object_type = 'PACKAGE BODY'
                    AND TYPE IN ('PROCEDURE', 'FUNCTION')
           GROUP BY object_name),
    naming_convention_violations
       AS (SELECT name identifier
                , 'line ' || line || ': ' || source sourceline
                , CASE
                     WHEN     TYPE = 'RECORD'
                          AND usage = 'DECLARATION'
                          AND SUBSTR (LOWER (name), 1, 2) <> 't_'
                     THEN
                        'Violated convention that type definitions should be called t_<name>'
                     WHEN TYPE IN
                                ('FORMAL IN', 'FORMAL IN OUT', 'FORMAL OUT')
                          AND usage = 'DECLARATION'
                          AND SUBSTR (LOWER (name), 1, 2) <> 'p_'
                     THEN
                        'Violated convention that (input and output) parameters should be called p_<name>'
                     WHEN TYPE = 'VARIABLE' AND usage = 'DECLARATION'
                     THEN
                        CASE
                           WHEN line < global_section.end_line /* global variable */
                                                              AND SUBSTR (LOWER (name), 1, 2) <> 'g_'
                           THEN
                              'Violated convention that global variables should be called g_<name>'
                           WHEN line > global_section.end_line /* local variable */
                                                              AND SUBSTR (LOWER (name), 1, 2) <> 'l_'
                           THEN
                              'Violated convention that local variables should be called l_<name>'
                        END
                  END
                     MESSAGE
             FROM    identifiers
                  JOIN
                     global_section
                  USING (object_name)),
    global_violations
       AS (SELECT name identifier
                , 'line ' || line || ': ' || source sourceline
                , CASE
                     WHEN     TYPE = 'VARIABLE'
                          AND usage = 'DECLARATION'
                          AND object_type = 'PACKAGE'
                     THEN
                        'Violated convention that there should not be any Global Variables in a Package Specification'
                  END
                     MESSAGE
             FROM identifiers),
    casing_violations
       AS (SELECT name identifier
                , 'line ' || line || ': ' || source sourceline
                , CASE
                     WHEN     TYPE = 'VARIABLE'
                          AND usage = 'DECLARATION'
                          AND INSTR (source, LOWER (name)) = 0
                     THEN
                        'Violated convention that variable names should spelled in lowercase only'
                  END
                     MESSAGE
             FROM identifiers),
    convention_violations AS (SELECT *
                                FROM naming_convention_violations
                              UNION ALL
                              SELECT *
                                FROM global_violations
                              UNION ALL
                              SELECT *
                                FROM casing_violations)
SELECT *
  FROM convention_violations
 WHERE MESSAGE IS NOT NULL
/
 