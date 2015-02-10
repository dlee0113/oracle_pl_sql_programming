 
set autotrace traceonly statistics
select * from stocktable;
select * from stocktable;
set autotrace off

spool stockpivot_test.txt

truncate table tickertable;

@stockpivot_test load_stocks_legacy
@stockpivot_test load_stocks_forall
@stockpivot_test load_stocks
@stockpivot_test load_stocks_array
@stockpivot_test load_stocks_parallel

spool off
