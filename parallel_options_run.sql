
@prepopulate_tickertable.sql

spool parallel_options_test.txt

ALTER SESSION FORCE PARALLEL QUERY;

@parallel_options_test.sql any
@parallel_options_test.sql range
@parallel_options_test.sql hash
@parallel_options_test.sql any_ordered
@parallel_options_test.sql range_ordered
@parallel_options_test.sql hash_ordered
@parallel_options_test.sql any_clustered
@parallel_options_test.sql range_clustered
@parallel_options_test.sql hash_clustered

ALTER SESSION DISABLE PARALLEL QUERY;

SELECT parallel_option
,     (end_time-start_time)/100 AS elapsed_seconds
FROM   parallel_options_test
ORDER  BY
       elapsed_seconds;

spool off

