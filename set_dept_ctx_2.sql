create or replace procedure set_dept_ctx
is
   l_str    varchar2(2000);
   l_ret    varchar2(2000);
begin
   for deptrec in
   (
      select deptno
      from emp_access
      where username = USER
   ) loop
      l_str := l_str||deptrec.deptno||',';
   end loop;
   if l_str is null then
      -- no access records found, no records
      -- should be displayed.
      l_ret := '1=2';
   else
      l_str := rtrim(l_str,',');
      l_ret := 'DEPTNO IN ('||l_str||')';
   dbms_session.set_context
      ('DEPT_CTX', 'DEPTNO_LIST',l_ret);
   end if;
end;

