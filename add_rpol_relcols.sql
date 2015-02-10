begin
   -- drop the policy first.
   dbms_rls.drop_policy (
      object_schema     => 'HR',
      object_name      => 'EMP',
      policy_name      => 'EMP_POLICY'
   );
   --
   -- add the policy
   --
   dbms_rls.add_policy (
      object_schema     => 'HR',
      object_name       => 'EMP',
      policy_name       => 'EMP_POLICY',
      function_schema   => 'RLSOWNER',
      policy_function   => 'AUTHORIZED_EMPS',
      statement_types   => 'INSERT, UPDATE, DELETE, SELECT',
      update_check      => true,
      sec_relevant_cols => 'SAL, COMM'
   );
end;
