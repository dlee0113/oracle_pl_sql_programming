begin
  dbms_fga.add_policy (
    object_schema => 'HR',
    object_name   => 'EMP',
    policy_name   => 'EMP_SEL',
    audit_column  => 'SAL, COMM',
    audit_condition => 'SAL >= 150000 OR EMPID = 100'
  );
end;

