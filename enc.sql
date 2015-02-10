declare 
   l_key     varchar2(2000) := '1234567890123456'; 
   l_in_val  varchar2(2000) := 'ConfidentialData'; 
   l_mod     number := dbms_crypto.ENCRYPT_AES128 
                       + dbms_crypto.CHAIN_CBC 
                       + dbms_crypto.PAD_PKCS5; 
   l_enc     raw (2000); 
begin 
   l_enc := dbms_crypto.encrypt 
   ( 
       UTL_I18N.STRING_TO_RAW (l_in_val, 'AL32UTF8'), 
       l_mod, 
       UTL_I18N.STRING_TO_RAW (l_key, 'AL32UTF8') 
  ); 
  dbms_output.put_line ('Encrypted='||l_enc); 
end; 

