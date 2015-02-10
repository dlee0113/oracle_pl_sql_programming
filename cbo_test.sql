
set echo on
set autotrace traceonly explain

SELECT *
FROM   TABLE(pipe_employees) e;

SELECT *
FROM   departments           d
,      TABLE(pipe_employees) e
WHERE  d.department_id = e.department_id;

SELECT /*+ CARDINALITY(e, 50000) */ 
       *
FROM   TABLE(pipe_employees) e;

SELECT /*+ CARDINALITY(e, 50000) */
       *
FROM   departments           d
,      TABLE(pipe_employees) e
WHERE  d.department_id = e.department_id;

SELECT /*+ OPT_ESTIMATE(table, e, scale_rows=6) */
       *
FROM   TABLE(pipe_employees) e;

SELECT /*+ OPT_ESTIMATE(table, e, scale_rows=6) */
       *
FROM   departments           d
,      TABLE(pipe_employees) e
WHERE  d.department_id = e.department_id;

SELECT /*+ DYNAMIC_SAMPLING(e 5) */
       *
FROM   TABLE(pipe_employees) e;

SELECT /*+ DYNAMIC_SAMPLING(e 5) */
       *
FROM   departments           d
,      TABLE(pipe_employees) e
WHERE  d.department_id = e.department_id;

SELECT /*+ LEADING(d) USE_HASH(e) */
       *
FROM   departments           d
,      TABLE(pipe_employees) e
WHERE  d.department_id = e.department_id;

ASSOCIATE STATISTICS WITH FUNCTIONS pipe_employees USING pipelined_stats_ot;

SELECT *
FROM   departments                  d
,      TABLE(pipe_employees(50000)) e
WHERE  d.department_id = e.department_id;

DISASSOCIATE STATISTICS FROM FUNCTIONS pipe_employees;

set autotrace off

DECLARE
   v_task      VARCHAR2(30);
   v_task_name VARCHAR2(30) := 'cbo_test';
   v_sql       CLOB;
BEGIN

   /* SQL to be tuned... */
   v_sql := 'SELECT *
             FROM   departments           d
             ,      TABLE(pipe_employees) e
             WHERE  d.department_id = e.department_id';

   /* Create a SQL Tuning task for our SQL... */
   v_task := DBMS_SQLTUNE.CREATE_TUNING_TASK(
                sql_text    => v_sql,
                time_limit  => 10,
                scope       => 'COMPREHENSIVE',
                task_name   => v_task_name,
                description => 'Tuning pipelined function plans'
                );

   /* Execute the task... */
   DBMS_SQLTUNE.EXECUTE_TUNING_TASK(
      task_name => v_task_name
      );

END;
/

set long 80000
col recs format a140
 
SELECT DBMS_SQLTUNE.REPORT_TUNING_TASK('cbo_test') AS recs
FROM   dual;

exec DBMS_SQLTUNE.DROP_TUNING_TASK('cbo_test');

set echo off


