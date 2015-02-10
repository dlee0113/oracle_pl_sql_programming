REM
REM Define a variable to hold the encrypted value
variable enc_val varchar2(2000);
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
         utl_i18n.string_to_raw (l_in_val, 'AL32UTF8'),
         l_mod,
         utl_i18n.string_to_raw (l_key, 'AL32UTF8')
      );
   dbms_output.put_line ('Encrypted='||l_enc);
   :enc_val := rawtohex(l_enc);
end;
/
declare
   l_key     varchar2(2000) := '1234567890123456';
   l_in_val  raw (2000) := hextoraw(:enc_val);
   l_mod     number := dbms_crypto.ENCRYPT_AES128
                     + dbms_crypto.CHAIN_CBC
                     + dbms_crypto.PAD_PKCS5;
   l_dec     raw (2000);
begin
   l_dec := dbms_crypto.decrypt
      (
         l_in_val,
         l_mod,
         UTL_I18N.STRING_TO_RAW (l_key, 'AL32UTF8')
      );
   dbms_output.put_line 
        ('Decrypted='||utl_i18n.raw_to_char(l_dec));
end;
/
