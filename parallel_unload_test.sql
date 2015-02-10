
set serveroutput on
set timing on
col file_name format a30

prompt
prompt Legacy unload (1 million rows)...
prompt ===============================================

DECLARE
   v_rc SYS_REFCURSOR;
BEGIN
   OPEN v_rc FOR SELECT ticker     || ',' || 
                        price_type || ',' ||
                        price      || ',' ||
                        TO_CHAR(price_date,'YYYYMMDDHH24MISS')
                 FROM   tickertable;
   unload_pkg.legacy_unload( p_source => v_rc,
                             p_filename => 'tickertable',
                             p_directory => 'DIR' );
END;
/

prompt
prompt Parallel unload...
prompt ===============================================

SELECT *
FROM   TABLE(
          unload_pkg.parallel_unload( 
             p_source => CURSOR(SELECT /*+ PARALLEL(t, 4) */
                                       ticker     || ',' || 
                                       price_type || ',' ||
                                       price      || ',' ||
                                       TO_CHAR(price_date,'YYYYMMDDHH24MISS')
                                FROM   tickertable t),
             p_filename => 'tickertable',
             p_directory => 'DIR' ));


prompt
prompt Parallel buffered unload...
prompt ===============================================

SELECT *
FROM   TABLE(
          unload_pkg.parallel_unload_buffered( 
             p_source => CURSOR(SELECT /*+ PARALLEL(t, 4) */
                                       ticker     || ',' || 
                                       price_type || ',' ||
                                       price      || ',' ||
                                       TO_CHAR(price_date,'YYYYMMDDHH24MISS')
                                FROM   tickertable t),
             p_filename => 'tickertable',
             p_directory => 'DIR' ));



