DECLARE
   l_enc_val   BLOB;
   l_in_val    CLOB;
   l_key       VARCHAR2 (16) := '1234567890123456';
BEGIN
   DBMS_CRYPTO.encrypt (dst      => l_enc_val,
                        src      => l_in_val,
                        KEY      => utl_i18n.string_to_raw (l_key, 'AL32UTF8'),
                        typ      =>   DBMS_CRYPTO.encrypt_aes128
                                    + DBMS_CRYPTO.chain_cbc
                                    + DBMS_CRYPTO.pad_pkcs5
                       );
END;
/



/*======================================================================
| Supplement to the fifth edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2009 O'Reilly Media, Inc. 
| To submit corrections or find more code samples visit
| http://oreilly.com/catalog/9780596514464/
*/
