update plsql_profiler_units set total_time = 0;
execute prof_report_utilities.rollup_all_runs;

set pagesize 999
set linesize 120
column unit format a20
column line# format 99999
column time_Count format a15
column text format a60

spool slowest2.txt

select
    to_char(p1.total_time/10000000, '99999999') || '-' ||
    TO_CHAR (p1.total_occur) as time_count,
    substr(p2.unit_owner, 1, 20) || '.' || 
    decode(p2.unit_name, '', '<anonymous>', 
       substr(p2.unit_name,1, 20)) as unit,
    TO_CHAR (p1.line#) || '-' || p3.text text
  from
    plsql_profiler_data p1,
    plsql_profiler_units p2,
   all_source p3, plsql_profiler_grand_total p4
  where
    p2.unit_owner NOT IN ('SYS', 'SYSTEM') AND
    p1.runID = &&firstparm AND
    (p1.total_time >= p4.grand_total/100) AND
    p1.runID = p2.runid and
    p2.unit_number=p1.unit_number and
    p3.type='PACKAGE BODY' and
    p3.owner = p2.unit_owner and
    p3.line = p1.line# and
    p3.name=p2.unit_name
  order by p1.total_time desc;
  
spool off
  




/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/

