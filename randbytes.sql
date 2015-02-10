declare
   l_key    raw(16);
begin
   l_key := dbms_crypto.randombytes(16);
end;

/
