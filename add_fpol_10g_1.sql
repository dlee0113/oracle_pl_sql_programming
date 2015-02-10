begin
   dbms_fga.add_policy (
      object_schema   => 'HR',
      object_name     => 'EMP',
      policy_name     => 'EMP_DML',
      audit_column    => 'SALARY, COMM',
      audit_condition => 'SALARY >= 150000 OR EMPID = 100',
      statement_types => 'SELECT, INSERT, DELETE, UPDATE'
   );
end;
/
