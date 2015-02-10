create or replace procedure set_dept_ctx
(
    p_attr in varchar2,
    p_val  in varchar2
)
is
begin
    dbms_session.set_context
       ('DEPT_CTX', p_attr, p_val);
end;
/
