create or replace function get_enc_val
(
   p_in_val    in varchar2,
   p_key       in varchar2
)
return varchar2
is
   l_enc_val raw(4000);
begin
   l_enc_val := dbms_crypto.encrypt
      (
         src => utl_i18n.string_to_raw (p_in_val, 'AL32UTF8'),
         key => utl_i18n.string_to_raw (p_key, 'AL32UTF8'),
         typ => dbms_crypto.encrypt_aes128 +
                dbms_crypto.chain_cbc +
                dbms_crypto.pad_pkcs5
      );
   return l_enc_val;
end;
/



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/