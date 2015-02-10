/*

Compare performance of repeated querying of data to
caching in the PGA (packaged collection) and the
new Oracle 11g Result Cache.

To compile and run this test script, you will first need to
run the following script.

Note that to compile the my_session package and display PGA
usage statistics, you will need SELECT authority on:

sys.v_$session
sys.v_$sesstat
sys.v_$statname

Author: Steven Feuerstein

*/

@@plvtmr.pkg
@@mysess.pkg
@@11g_emplu.pkg
@@11g_emplu_compare.sp

SET SERVEROUTPUT ON

BEGIN
   test_emplu (100000);
/*

With 100000 iterations:

PGA before tests are run:
session PGA: 2057168

Execute query each time Elapsed: 5.65 seconds. Factored: .00006 seconds.
session PGA: 1139664

Oracle 11g result cache Elapsed: .3 seconds. Factored: 0 seconds.
session PGA: 1139664

Cache table in PGA memory Elapsed: .12 seconds. Factored: 0 seconds.
session PGA: 1336272

*/   
END;
/
