clear screen
set serveroutput on

declare
  procedure greatest(a in pls_integer, b in pls_integer)
  is
  begin
    if a > b then
      dbms_output.put_line('a is greater');
    elsif a < b then
      dbms_output.put_line('b is greater');
    else
      dbms_output.put_line('a and b are equal');
    end if;
  end;
  procedure greatest2(a in pls_integer, b in pls_integer)
  is
  begin
    if a > b then
      dbms_output.put_line('a is greater');
    else if a < b then
      dbms_output.put_line('b is greater');
    else
      dbms_output.put_line('a and b are equal');
    end if;
    end if;
  end;
begin
  greatest(1,2);
  greatest(2,2);
  greatest(3,2);
  greatest2(1,2);
  greatest2(2,2);
  greatest2(3,2);
end;
/
