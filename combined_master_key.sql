VARIABLE enc_val varchar2(2000)
/

DECLARE
   l_key          VARCHAR2 (2000) := '1234567890123456';
   l_master_key   VARCHAR2 (2000) := '&master_key';
   l_in_val       VARCHAR2 (2000) := 'Confidential Data';
   l_mod NUMBER
         :=   DBMS_CRYPTO.encrypt_aes128
            + DBMS_CRYPTO.chain_cbc
            + DBMS_CRYPTO.pad_pkcs5;
   l_enc          RAW (2000);
   l_enc_key      RAW (2000);
BEGIN
   l_enc_key :=
      UTL_RAW.bit_xor (UTL_I18N.string_to_raw (l_key, 'AL32UTF8')
                     , UTL_I18N.string_to_raw (l_master_key, 'AL32UTF8')
                      );
   l_enc :=
      DBMS_CRYPTO.encrypt (UTL_I18N.string_to_raw (l_in_val, 'AL32UTF8')
                         , l_mod
                         , l_enc_key
                          );
   DBMS_OUTPUT.put_line ('Encrypted=' || l_enc);
   :enc_val := RAWTOHEX (l_enc);
END;
/

DECLARE
   l_key          VARCHAR2 (2000) := '1234567890123456';
   l_master_key   VARCHAR2 (2000) := '&master_key';
   l_in_val       RAW (2000) := HEXTORAW (:enc_val);
   l_mod NUMBER
         :=   DBMS_CRYPTO.encrypt_aes128
            + DBMS_CRYPTO.chain_cbc
            + DBMS_CRYPTO.pad_pkcs5;
   l_dec          RAW (2000);
   l_enc_key      RAW (2000);
BEGIN
   l_enc_key :=
      UTL_RAW.bit_xor (UTL_I18N.string_to_raw (l_key, 'AL32UTF8')
                     , UTL_I18N.string_to_raw (l_master_key, 'AL32UTF8')
                      );
   l_dec := DBMS_CRYPTO.decrypt (l_in_val, l_mod, l_enc_key);
   DBMS_OUTPUT.put_line ('Decrypted=' || UTL_I18N.raw_to_char (l_dec));
END;
/
