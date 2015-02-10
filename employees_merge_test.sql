
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

