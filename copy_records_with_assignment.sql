clear screen
set serveroutput on
declare
  type type1_rt is record
  ( field1 varchar2(30)
  , field2 number
  , field3 date
  );
  
  type type2_rt is record
  ( field1 varchar2(30)
  , field2 number
  , field3 date
  ); 
  
  lvar1 type1_rt;
  lvar2 type2_rt;
begin
  lvar1.field1 := 'Patrick';
  lvar1.field2 := 36;
  lvar1.field3 := to_date('12291972','MMDDYYYY');
  
  lvar2 := lvar1;
  dbms_output.put_line(lvar2.field1);
end;
/

declare
  type type1_rt is record
  ( field1 varchar2(30)
  , field2 number
  , field3 date
  );
  
  type type2_rt is record
  ( field1 date
  , field2 varchar2(30)
  , field3 number
  ); 
  
  lvar1 type1_rt;
  lvar2 type2_rt;
begin
  lvar1.field1 := 'Patrick';
  lvar1.field2 := 36;
  lvar1.field3 := to_date('12291972','MMDDYYYY');
  
  lvar2 := lvar1;
  dbms_output.put_line(lvar2.field2);
end;
/

declare
  type type1_rt is record
  ( field1 varchar2(30)
  , field2 number
  , field3 date
  );
  
  type type2_rt is record
  ( field1 varchar2(30)
  , field2 number
  , field3 date
  ); 
  
  lvar1 type1_rt;
  lvar2 type1_rt;
begin
  lvar1.field1 := 'Patrick';
  lvar1.field2 := 36;
  lvar1.field3 := to_date('12291972','MMDDYYYY');
  
  lvar2 := lvar1;
  dbms_output.put_line(lvar2.field1);
end;
/
