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



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
