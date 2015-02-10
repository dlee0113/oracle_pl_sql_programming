
-- ensure tickertable has 1 million rows

TRUNCATE TABLE parallel_skew_test;

spool parallel_skew_test.txt

ALTER SESSION FORCE PARALLEL QUERY;

@parallel_skew_test.sql any
@parallel_skew_test.sql range_high
@parallel_skew_test.sql hash_high
@parallel_skew_test.sql range_low
@parallel_skew_test.sql hash_low

ALTER SESSION DISABLE PARALLEL QUERY;

SELECT *
FROM   parallel_skew_test
PIVOT (
       SUM(record_count)
       FOR parallel_option
       IN  ('any'        AS nrecs_any,
            'hash_low'   AS nrecs_hash_low_card,
            'hash_high'  AS nrecs_hash_high_card,
            'range_low'  AS nrecs_range_low_card,
            'range_high' AS nrecs_range_high_card)
);

spool off

