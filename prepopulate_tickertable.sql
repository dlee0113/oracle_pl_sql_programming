
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
