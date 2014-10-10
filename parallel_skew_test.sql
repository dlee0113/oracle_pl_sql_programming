
set verify off

prompt
prompt Running &1....
prompt ==========================================================

INSERT INTO parallel_skew_test (parallel_option, session_number, record_count)
SELECT '&1', ROWNUM, record_count
FROM  (
       SELECT ticker, COUNT(*) AS record_count
       FROM   TABLE(
                 stocks_skew_pkg.pipe_stocks_&1.(
                    CURSOR(SELECT /*+ PARALLEL(t, 4) */ * FROM tickertable t)))
       GROUP  BY
              ticker
      );

COMMIT;



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/


