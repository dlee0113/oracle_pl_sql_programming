begin
   dbms_rls.drop_policy (
      object_schema         => 'HR',
      object_name           => 'EMP',
      policy_name           => 'EMP_POLICY'
);
   dbms_rls.add_policy (
      object_schema         => 'HR',
      object_name           => 'EMP',
      policy_name           => 'EMP_POLICY',
      function_schema       => 'RLSOWNER',
      policy_function       => 'AUTHORIZED_EMPS',
      statement_types       => 'SELECT',
      update_check          => true,
      sec_relevant_cols     => 'SAL, COMM',
      sec_relevant_cols_opt => dbms_rls.all_rows
);
end;



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
