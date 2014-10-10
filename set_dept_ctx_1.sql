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



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
