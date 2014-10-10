create or replace function authorized_emps
(
   p_schema_name    in varchar2,
   p_object_name    in varchar2
)
return varchar2
is
   l_return_val     varchar2(2000);
begin
   l_return_val := 'SAL <= 1500';
   return l_return_val;
end;




/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
