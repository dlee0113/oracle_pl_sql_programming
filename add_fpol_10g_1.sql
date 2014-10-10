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



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
