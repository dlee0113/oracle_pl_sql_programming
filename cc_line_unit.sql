CREATE OR REPLACE PROCEDURE calculate_totals
IS
BEGIN
   RAISE VALUE_ERROR;
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line
                  (   'Current line number '
                   || $$plsql_line
                  );
      DBMS_OUTPUT.put_line
                     (   'Failed in program '
                      || $$plsql_unit
                     );
END calculate_totals;
/

EXEC calculate_totals;

CREATE OR REPLACE PACKAGE calc_pkg
IS
   PROCEDURE calculate_totals;
END calc_pkg;
/

CREATE OR REPLACE PACKAGE BODY calc_pkg
IS
   PROCEDURE calculate_totals
   IS
   BEGIN
      RAISE VALUE_ERROR;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line
                  (   'Current line number '
                   || $$plsql_line
                  );
         DBMS_OUTPUT.put_line
                     (   'Failed in program '
                      || $$plsql_unit
                     );
   END calculate_totals;
END calc_pkg;
/

EXEC calc_pkg.calculate_totals;


/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/