
-- populate tickertable with 1 million rows
TRUNCATE TABLE tickertable;
exec stockpivot_pkg.load_stocks_parallel;
COMMIT;
exec DBMS_STATS.GATHER_TABLE_STATS(USER, 'TICKERTABLE');
set autotrace traceonly statistics
SELECT * FROM tickertable;
SELECT * FROM tickertable;
SELECT * FROM tickertable;
set autotrace off



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/

