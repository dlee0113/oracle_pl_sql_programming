
--
-- Note: Uses mystats_pkg available at www.oracle-developer.net/utilities.php
--

set verify off
set serveroutput on
set autotrace traceonly statistics

prompt
prompt Running &1....
prompt ==========================================================

exec mystats_pkg.ms_start;
exec stockpivot_pkg.&1;
exec mystats_pkg.ms_stop(mystats_pkg.statname_ntt('redo size'));
commit;

set autotrace off



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/


