begin
   dbms_rls.add_policy (
      object_name      => 'EMP',
      policy_name      => 'EMP_POLICY',
      function_schema  => 'HR',
      policy_function  => 'AUTHORIZED_EMPS',
      statement_types  => 'INSERT, UPDATE, DELETE, SELECT',
      update_check     => true
   );
end;
/
