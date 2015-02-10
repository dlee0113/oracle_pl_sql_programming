create or replace function authorized_emps
(
    p_schema_name    in varchar2,
    p_object_name    in varchar2
)
return varchar2
is
    l_return_val        varchar2(2000);
begin
    l_return_val := 'SAL <= 1500';
    return l_return_val;
end;

