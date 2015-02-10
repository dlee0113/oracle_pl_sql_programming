create or replace function authorized_emps
(
    p_schema_name    in varchar2,
    p_object_name    in varchar2
)
return varchar2
is
   l_deptno      number;
   l_return_val  varchar2(2000);
begin
   if (p_schema_name = USER) then
      l_return_val := null;
   else
      l_return_val := sys_context('DEPT_CTX','DEPTNO_LIST');
   end if;
   return l_return_val;
end;

