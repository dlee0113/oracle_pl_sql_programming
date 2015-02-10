begin
   dbms_rls.drop_policy (
      object_schema         => 'HR',
      object_name           => 'DEPT',
      policy_name           => 'EMP_DEPT_POLICY'
   );
   dbms_rls.add_policy (
      object_schema         => 'HR',
      object_name           => 'DEPT',
      policy_name           => 'EMP_DEPT_POLICY',
      function_schema       => 'RLSOWNER',
      policy_function       => 'AUTHORIZED_EMPS',
      statement_types       => 'SELECT, INSERT, UPDATE, DELETE',
      update_check          => true,
      policy_type           => dbms_rls.shared_static
   );
   dbms_rls.add_policy (
      object_schema         => 'HR',
      object_name           => 'EMP',
      policy_name           => 'EMP_DEPT_POLICY',
      function_schema       => 'RLSOWNER',
      policy_function       => 'AUTHORIZED_EMPS',
      statement_types       => 'SELECT, INSERT, UPDATE, DELETE',
      update_check          => true,
      policy_type           => dbms_rls.shared_static
   );
end;

