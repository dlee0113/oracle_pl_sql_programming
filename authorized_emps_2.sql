create or replace function authorized_emps
(
   p_schema_name    in varchar2,
   p_object_name    in varchar2
)
return varchar2
is
   l_deptno            number;
   l_return_val        varchar2(2000);
begin
   if (p_schema_name = USER) then
      l_return_val := null;
   else
      select deptno
      into l_deptno
      from emp
      where ename = USER;
      l_return_val := 'DEPTNO = '||l_deptno;
   end if;
   return l_return_val;
end;




/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
