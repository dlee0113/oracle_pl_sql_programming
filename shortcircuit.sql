clear screen
set serveroutput on

declare
  lbool boolean;
  procedure whatisit(bool_in in boolean)
  is
  begin
    if bool_in then
      dbms_output.put_line('True');
    elsif bool_in = false then
      dbms_output.put_line('False');
    else
      dbms_output.put_line('Null');
    end if;
  end;
begin
  lbool := null and null;
  whatisit(lbool);
  lbool := false and null;
  whatisit(lbool);
  lbool := true and null;
  whatisit(lbool);
  lbool := null and false;
  whatisit(lbool);
  lbool := false and false;
  whatisit(lbool);
  lbool := true and false;
  whatisit(lbool);
  lbool := null and true;
  whatisit(lbool);
  lbool := false and true;
  whatisit(lbool);
  lbool := true and true;
  whatisit(lbool);
end;
/
