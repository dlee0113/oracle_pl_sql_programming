CREATE OR REPLACE TRIGGER what_privs
   AFTER GRANT ON SCHEMA
DECLARE
   v_grant_type     VARCHAR2 (30);
   v_num_grantees   BINARY_INTEGER;
   v_grantee_list   ora_name_list_t;
   v_num_privs      BINARY_INTEGER;
   v_priv_list      ora_name_list_t;
BEGIN
   v_grant_type := ora_dict_obj_type;
   v_num_grantees := ora_grantee (v_grantee_list);
   v_num_privs := ora_privilege_list (v_priv_list);

   IF v_grant_type = 'ROLE PRIVILEGE'
   THEN
      DBMS_OUTPUT.put_line (
         CHR (9) || 'The following roles/privileges were granted'
      );

      FOR counter IN 1 .. v_num_privs
      LOOP
         DBMS_OUTPUT.put_line (
            CHR (9) || CHR (9) || 'Privilege ' || v_priv_list (counter)
         );
      END LOOP;
   ELSIF v_grant_type = 'OBJECT PRIVILEGE'
   THEN
      DBMS_OUTPUT.put_line (
         CHR (9) || 'The following object privileges were granted'
      );

      FOR counter IN 1 .. v_num_privs
      LOOP
         DBMS_OUTPUT.put_line (
            CHR (9) || CHR (9) || 'Privilege ' || v_priv_list (counter)
         );
      END LOOP;

      DBMS_OUTPUT.put (CHR (9) || 'On ' || ora_dict_obj_name);

      IF ora_with_grant_option
      THEN
         DBMS_OUTPUT.put_line (' with grant option');
      ELSE
         DBMS_OUTPUT.put_line ('');
      END IF;
   ELSIF v_grant_type = 'SYSTEM PRIVILEGE'
   THEN
      DBMS_OUTPUT.put_line (
         CHR (9) || 'The following system privileges were granted'
      );

      FOR counter IN 1 .. v_num_privs
      LOOP
         DBMS_OUTPUT.put_line (
            CHR (9) || CHR (9) || 'Privilege ' || v_priv_list (counter)
         );
      END LOOP;
   ELSE
      DBMS_OUTPUT.put_line ('I have no idea what was granted');
   END IF;

   FOR counter IN 1 .. v_num_grantees
   LOOP
      DBMS_OUTPUT.put_line (
         CHR (9) || 'Grant Recipient ' || v_grantee_list (counter)
      );
   END LOOP;
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
