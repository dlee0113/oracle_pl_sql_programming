clear screen
set serveroutput on
drop sequence recseq;
create sequence recseq start with 1 nocache;
create or replace function getseq(name_in in varchar2) return number
is
  sqlstatement varchar2(32767);
  l_returnvalue number;
begin
  -- needs error handling and auth_id current user clause, 
--  but for demonstration purposes what the he...
  sqlstatement := 'select '||name_in||'.nextval from dual';
  execute immediate sqlstatement into l_returnvalue;
  RETURN l_returnvalue;
end;
/
sho err;

declare
  type myrec is record
  ( id number not null default getseq('recseq')
  , name varchar2(30) not null default 'No name specified'
  );
  
  lrec myrec;
begin
  dbms_output.put_line(lrec.id);
  dbms_output.put_line(lrec.name);
  lrec.name := 'Patrick';
  dbms_output.put_line(lrec.name);
  begin
    lrec.name := '';
    dbms_output.put_line(lrec.name);
  exception
    when others then
      dbms_output.put_line('Cannot change name to NULL or ''''');
  end;
end;
/
drop function getseq;
