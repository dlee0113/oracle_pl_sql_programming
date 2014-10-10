 
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



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/

