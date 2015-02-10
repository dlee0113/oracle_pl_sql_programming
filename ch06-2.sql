set serveroutput on


declare
   n number;
begin
   begin
      n := 'a';
   exception
      when value_error
      then
         dbms_output.put_line ('Value Error');
   end;
   begin
      select 'a'
        into n
        from dual
      ;
   exception
      when value_error
      then  
         dbms_output.put_line ('Value Error');
   end;
   begin
      select to_number('a')
        into n
        from dual
      ;
   exception
      when invalid_number
      then
         dbms_output.put_line ('Invalid Number');
   end;
end;
/
