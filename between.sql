clear screen
set serveroutput on

declare
  lsalary pls_integer;
begin
  lsalary := 20000;
  
  case
    when lsalary between 10000 and 20000 then
      dbms_output.put_line('between 10000 and 20000 (inclusive)');
    when lsalary between 20000 and 40000 then
      dbms_output.put_line('between 20000 and 40000');
    else
      null;
  end case;
end;
/
select
  case
    when &lsalary between 10000 and 20000 then
      'between 10000 and 20000 (inclusive)'
    when &lsalary between 20000 and 40000 then
      'between 20000 and 40000'
    else
      null
  end bet
from dual;



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/

