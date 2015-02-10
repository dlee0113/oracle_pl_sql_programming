CONNECT SYS/SYS AS SYSDBA
grant select on source$ to SCOTT
/
CONNECT SCOTT/TIGER
SET SERVEROUTPUT ON
--------------------------------------------------------------------------------
-- Put the code in place.
-- source$ is a convenient table with lots of rows.


create or replace procedure putline ( approach in varchar2 , ol pls_integer) is
  t0 integer; t1 integer;
  cursor cur is select * from sys.source$;
  one_row cur%rowtype;
  type t is table of cur%rowtype index by pls_integer; many_rows t;
begin
  t0 := Dbms_Utility.Get_Cpu_Time();


  case approach
    when 'implicit for loop' then
      for j in cur loop
        null;
      end loop;


    when 'explicit open, fetch, close' then
      open cur;
      loop
        fetch cur into one_row;
        exit when cur%NotFound;
      end loop;
      close cur;


    when 'bulk fetch' then
      open cur;
      loop
        fetch cur bulk collect into many_rows limit 100;
        exit when many_rows.Count() < 1;
      end loop;
      close cur;


  end case;
  t1 := Dbms_Utility.Get_Cpu_Time();
  Dbms_Output.Put_Line ('Timing for ' || approach || 
     ' with opt level ' || TO_CHAR (ol) || ' = ' || TO_CHAR (t1-t0 ));
end putline;
/
SET FEEDBACK OFF
--------------------------------------------------------------------------------
-- Time it at optimize levels 1 and 2 
--
-- Level 1


alter procedure putline compile plsql_optimize_level=1 
/
call putline( 'implicit for loop' , 1)          -- 2073
/
call putline( 'explicit open, fetch, close' , 1) -- 2063
/
call putline( 'bulk fetch' , 1)                  -- 252
/


--------------------------------------------------------------------------------
-- Level 2


alter procedure putline compile plsql_optimize_level=2 
/
call putline( 'implicit for loop' , 2)          -- 263 <<== NOTE THE CHANGE !
/
call putline( 'explicit open, fetch, close' , 2) -- as for level 1
/
call putline( 'bulk fetch' , 2)                  -- as for level 1
/
