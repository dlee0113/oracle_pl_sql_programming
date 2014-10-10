
set serveroutput on
set autotrace traceonly statistics
select * from employees_staging;
select * from employees_staging;
set autotrace off
set timing on

prompt
prompt Legacy merge processing...
prompt ==========================================================

exec employee_pkg.upsert_employees;
rollback;

prompt
prompt Pipelined merge processing...
prompt ==========================================================

exec employee_pkg.merge_employees;
rollback;



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/

