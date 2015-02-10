
set verify off
set timing on
set serveroutput on

var s NUMBER;
var e NUMBER;

set autotrace traceonly statistics

prompt
prompt Running &1....
prompt ==========================================================

exec :s := DBMS_UTILITY.GET_TIME;

SELECT *
FROM   TABLE(
          stocks_pkg.pipe_stocks_&1.(
             CURSOR(SELECT /*+ PARALLEL(t, 4) */ * FROM tickertable t)));

exec :e := DBMS_UTILITY.GET_TIME;

set autotrace off

INSERT INTO parallel_options_test ( parallel_option, start_time, end_time )
VALUES ( '&1', :s, :e );
COMMIT;

