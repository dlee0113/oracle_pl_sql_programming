/*
Oracle PL/SQL Programming 5th Edition

www.stevenfeuerstein.com/books

Objection creation and example scripts for Chapter 16

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
   EXECUTE IMMEDIATE 'CREATE INDEX emp_u_1 ON employees (last_name)';
END;
/

CREATE OR REPLACE PROCEDURE exec_ddl (ddl_string IN VARCHAR2)
IS
BEGIN
   EXECUTE IMMEDIATE ddl_string;
END;
/

DROP TABLE company
/

CREATE TABLE company
(
   name               VARCHAR2 (100)
 , address1           VARCHAR2 (100)
 , address2           VARCHAR2 (100)
 , city               VARCHAR2 (100)
 , state              VARCHAR2 (100)
 , zipcode            VARCHAR2 (100)
 , ceo_compensation   NUMBER
 , cost_cutting       VARCHAR2 (100)
)
/

CREATE OR REPLACE FUNCTION company_table_name (id_in IN INTEGER)
   RETURN VARCHAR2
IS
BEGIN
   RETURN 'company';
END;
/

CREATE OR REPLACE PACKAGE company_pkg
IS
   current_company_id   INTEGER;
END;
/

DECLARE
   CV            sys_refcursor;
   mega_bucks    company.ceo_compensation%TYPE;
   achieved_by   company.cost_cutting%TYPE;
BEGIN
   OPEN CV FOR
      'SELECT ceo_compensation, cost_cutting
        FROM '
      || company_table_name (company_pkg.current_company_id);

   LOOP
      FETCH CV
      INTO mega_bucks, achieved_by;

      EXIT WHEN CV%NOTFOUND;
   END LOOP;

   CLOSE CV;
END;
/

DECLARE
   CV         sys_refcursor;
   ceo_info   company%ROWTYPE;
BEGIN
   OPEN CV FOR
      'SELECT *
        FROM ' || company_table_name (company_pkg.current_company_id);

   LOOP
      FETCH CV
      INTO ceo_info;

      EXIT WHEN CV%NOTFOUND;
   END LOOP;

   CLOSE CV;
END;
/

CREATE OR REPLACE PACKAGE company_pkg
IS
   current_company_id   INTEGER;

   TYPE ceo_info_rt IS RECORD (
      mega_bucks    company.ceo_compensation%TYPE
    , achieved_by   company.cost_cutting%TYPE
   );
END company_pkg;
/

DECLARE
   CV    sys_refcursor;
   rec   company_pkg.ceo_info_rt;
BEGIN
   OPEN CV FOR
      'SELECT ceo_compensation, cost_cutting
        FROM '
      || company_table_name (company_pkg.current_company_id);

   LOOP
      FETCH CV
      INTO rec;

      EXIT WHEN CV%NOTFOUND;
   END LOOP;

   CLOSE CV;
END;
/

CREATE OR REPLACE PROCEDURE truncobj (nm  IN VARCHAR2
                                    , tp  IN VARCHAR2:= 'TABLE'
                                    , sch IN VARCHAR2:= NULL
                                     )
IS
BEGIN
   EXECUTE IMMEDIATE 'TRUNCATE ' || tp || ' ' || NVL (sch, USER) || '.' || nm;
END;
/

CREATE TABLE ceo_compensation (company_id INTEGER, salary NUMBER)
/

CREATE OR REPLACE PROCEDURE wrong_incentive (company_in  IN INTEGER
                                           , new_layoffs IN NUMBER
                                            )
IS
   sql_string          VARCHAR2 (32767);
   sal_after_layoffs   NUMBER;
BEGIN
   sql_string := 'UPDATE ceo_compensation
          SET salary = salary + 10 * :layoffs
        WHERE company_id = :company
       RETURNING salary INTO :newsal';

   EXECUTE IMMEDIATE sql_string
      USING new_layoffs, company_in, OUT sal_after_layoffs;

   DBMS_OUTPUT.put_line (
      'CEO compensation after latest round of layoffs $' || sal_after_layoffs
   );
END;
/

CREATE OR REPLACE PROCEDURE analyze_new_technology (
   tech_name           IN     VARCHAR2
 , analysis_year       IN     INTEGER
 , number_of_adherents IN OUT NUMBER
 , projected_revenue      OUT NUMBER
)
IS
BEGIN
   NULL;
END;
/

DECLARE
   devoted_followers   NUMBER;
   est_revenue         NUMBER;
BEGIN
   EXECUTE IMMEDIATE 'BEGIN analyze_new_technology (:p1, :p2, :p3, :p4); END;'
      USING 'Java', 2002, IN OUT devoted_followers, OUT est_revenue;
END;
/

CREATE OR REPLACE PROCEDURE updnumval (col_in   IN VARCHAR2
                                     , start_in IN DATE
                                     , end_in   IN DATE
                                     , val_in   IN NUMBER
                                      )
IS
   dml_str VARCHAR2 (32767)
         :=    'UPDATE emp SET '
            || col_in
            || ' = :val 
        WHERE hiredate BETWEEN :lodate AND :hidate 
        AND :val IS NOT NULL';
BEGIN
   EXECUTE IMMEDIATE dml_str USING val_in, start_in, end_in, val_in;
END;
/

CREATE OR REPLACE PROCEDURE updnumval (col_in   IN VARCHAR2
                                     , start_in IN DATE
                                     , end_in   IN DATE
                                     , val_in   IN NUMBER
                                      )
IS
   dml_str VARCHAR2 (32767)
         :=    'BEGIN
          UPDATE emp SET '
            || col_in
            || ' = :val 
           WHERE hiredate BETWEEN :lodate AND :hidate 
           AND :val IS NOT NULL;
       END;';
BEGIN
   EXECUTE IMMEDIATE dml_str USING val_in, start_in, end_in;
END;
/

DECLARE
   cur     PLS_INTEGER := DBMS_SQL.open_cursor;
   cols    DBMS_SQL.desc_tab;
   ncols   PLS_INTEGER;
BEGIN
   -- Parse the query.
   DBMS_SQL.parse (cur
                 , 'SELECT hire_date, salary FROM employees'
                 , DBMS_SQL.native
                  );
   -- Retrieve column information
   DBMS_SQL.describe_columns (cur, ncols, cols);

   -- Display each of the column names
   FOR colind IN 1 .. ncols
   LOOP
      DBMS_OUTPUT.put_line (cols (colind).col_name);
   END LOOP;

   DBMS_SQL.close_cursor (cur);
END;
/

DECLARE
   l_cursor   PLS_INTEGER;
   l_result   PLS_INTEGER;
BEGIN
   FOR i IN 1 .. counter
   LOOP
      l_cursor := DBMS_SQL.open_cursor;
      DBMS_SQL.parse (l_cursor
                    , 'SELECT ... where col = ' || i
                    , DBMS_SQL.native
                     );
      l_result := DBMS_SQL.execute (l_cursor);
      DBMS_SQL.close_cursor (l_cursor);
   END LOOP;
END;
/

DECLARE
   l_cursor   PLS_INTEGER;
   l_result   PLS_INTEGER;
BEGIN
   l_cursor := DBMS_SQL.open_cursor;
   DBMS_SQL.parse (l_cursor
                 , 'SELECT ... WHERE col = :value'
                 , DBMS_SQL.native
                  );

   FOR i IN 1 .. counter
   LOOP
      DBMS_SQL.bind_variable (l_cursor, 'value', i);
      l_result := DBMS_SQL.execute (l_cursor);
   END LOOP;

   DBMS_SQL.close_cursor (l_cursor);
END;
/