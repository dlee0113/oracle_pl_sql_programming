begin
   dbms_fga.add_policy (
      object_schema => 'HR',
      object_name   => 'EMP',
      policy_name   => 'EMP_SEL',
      audit_column  => 'SAL, COMM',
      audit_condition => 'SAL >= 150000 OR EMPID = 100'
   );
end;




/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
