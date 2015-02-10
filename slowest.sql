UPDATE plsql_profiler_units
   SET total_time = 0;

EXECUTE prof_report_utilities.rollup_all_runs;

SET PAGESIZE 999
SET LINESIZE 120
COLUMN unit FORMAT a20
COLUMN line# FORMAT 99999
COLUMN time_Count FORMAT a15
COLUMN text FORMAT a60

SPOOL slowest2.txt

  SELECT    TO_CHAR (p1.total_time / 10000000, '99999999')
         || '-'
         || TO_CHAR (p1.total_occur)
            AS time_count,
            SUBSTR (p2.unit_owner, 1, 20)
         || '.'
         || DECODE (p2.unit_name,
                    '', '<anonymous>',
                    SUBSTR (p2.unit_name, 1, 20))
            AS unit,
         TO_CHAR (p1.line#) || '-' || p3.text text
    FROM plsql_profiler_data p1,
         plsql_profiler_units p2,
         all_source p3,
         (SELECT SUM (total_time) AS grand_total
            FROM plsql_profiler_units) p4
   WHERE     p2.unit_owner NOT IN ('SYS', 'SYSTEM')
         AND p1.runid = &&firstparm
         AND (p1.total_time >= p4.grand_total / 100)
         AND p1.runid = p2.runid
         AND p2.unit_number = p1.unit_number
         AND p3.TYPE = 'PACKAGE BODY'
         AND p3.owner = p2.unit_owner
         AND p3.line = p1.line#
         AND p3.name = p2.unit_name
ORDER BY p1.total_time DESC;

SPOOL OFF



/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/