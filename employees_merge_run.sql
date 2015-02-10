
define num_rows = &1;

spool employees_merge_test_&num_rows..txt

@employees_merge_test.sql &num_rows

spool off
