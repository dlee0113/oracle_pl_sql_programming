declare
   l_in_val varchar2(2000) := 'CriticalData';
   l_hash   raw(2000);
begin
   l_hash := dbms_crypto.hash (
      src => UTL_I18N.STRING_TO_RAW (l_in_val, 'AL32UTF8'),
      typ => dbms_crypto.hash_sh1
   );
   dbms_output.put_line('Hash='||l_hash);
end;




/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/