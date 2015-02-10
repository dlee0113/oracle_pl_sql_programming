DROP TABLE compensation
/

CREATE TABLE compensation
(
   name                      VARCHAR2 (100)
 , title                     VARCHAR2 (100)
 , salary                    NUMBER
 , bonus                     NUMBER
 , stock_options             INTEGER
 , mercedes_benz_allowance   NUMBER
 , yacht_allowance           NUMBER
)
/

BEGIN
   INSERT INTO compensation
       VALUES ('John DayAndNight', 'JANITOR', 10000, 500, NULL, NULL, NULL
              );

   INSERT INTO compensation
       VALUES ('Holly Cubicle', 'PROGRAMMER', 50000, 2000, NULL, NULL, NULL
              );

   INSERT INTO compensation
       VALUES (
                  'Sandra Watchthebucks'
                , 'CFO'
                , 20000000
                , 2000000
                , 2000000
                , 500000
                , 500000
              );

   INSERT INTO compensation
       VALUES (
                  'Hiram Coldheart, XVII'
                , 'CEO'
                , 100000000
                , 20000000
                , 20000000
                , 2500000
                , 2500000
              );

   COMMIT;
END;
/

CREATE OR REPLACE FUNCTION salforexec (title_in IN VARCHAR2)
   RETURN NUMBER
/* Why "for Exec"? Cause the query assumes NOT NULL values
   for all of that good stuff you in the SELECT below. */
IS
   CURSOR ceo_compensation
   IS
      SELECT   salary
             + bonus
             + stock_options
             + mercedes_benz_allowance
             + yacht_allowance
        FROM compensation
       WHERE title = title_in;

   big_bucks   NUMBER;
BEGIN
   OPEN ceo_compensation;

   FETCH ceo_compensation
   INTO big_bucks;

   RETURN big_bucks;
END;
/

CREATE TYPE name_tab IS TABLE OF VARCHAR2 (200);
/

CREATE TYPE number_tab IS TABLE OF NUMBER;
/

DECLARE
   big_bucks      NUMBER := salforexec ('CEO');
   min_sal        NUMBER := big_bucks / 50;
   names          name_tab;
   old_salaries   number_tab;
   new_salaries   number_tab;

   CURSOR affected_employees (
      ceosal IN NUMBER
   )
   IS
      SELECT name, salary + bonus old_salary
        FROM compensation
       WHERE title != 'CEO'
             AND ( (salary + bonus < ceosal / 50)                 -- underpaid
                  OR (salary + bonus > ceosal / 10))   -- overpaid and NOT CEO
                                                    ;
BEGIN
   OPEN affected_employees (big_bucks);

   FETCH affected_employees
   BULK COLLECT INTO names, old_salaries;

   CLOSE affected_employees;

   FORALL indx IN names.FIRST .. names.LAST
                 UPDATE compensation
                    SET salary =
                           DECODE (GREATEST (min_sal, salary),
                                   min_sal, min_sal,
                                   salary / 5
                                  )
                  WHERE name = names (indx)
              RETURNING salary
      BULK COLLECT INTO new_salaries;

   FOR indx IN names.FIRST .. names.LAST
   LOOP
      DBMS_OUTPUT.put_line(   RPAD (names (indx), 20)
                           || RPAD (' Old: ' || old_salaries (indx), 15)
                           || ' New: '
                           || new_salaries (indx));
   END LOOP;
END;
/

/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/