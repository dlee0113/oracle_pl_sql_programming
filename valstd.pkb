CREATE OR REPLACE PACKAGE BODY valstd
IS
   PROCEDURE pl (
      str         IN   VARCHAR2
    , len         IN   INTEGER := 80
    , expand_in   IN   BOOLEAN := TRUE
   )
   IS
      v_len     PLS_INTEGER     := LEAST (len, 255);
      v_len2    PLS_INTEGER;
      v_chr10   PLS_INTEGER;
      v_str     VARCHAR2 (2000);
   BEGIN
      IF LENGTH (str) > v_len
      THEN
         v_chr10 := INSTR (str, CHR (10));

         IF v_chr10 > 0 AND v_len >= v_chr10
         THEN
            v_len := v_chr10 - 1;
            v_len2 := v_chr10 + 1;
         ELSE
            v_len2 := v_len + 1;
         END IF;

         v_str := SUBSTR (str, 1, v_len);
         DBMS_OUTPUT.put_line (v_str);
         pl (SUBSTR (str, v_len2), len, expand_in);
      ELSE
         -- Save the string in case we hit an error and need to recover.
         v_str := str;
         DBMS_OUTPUT.put_line (str);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF expand_in
         THEN
            DBMS_OUTPUT.ENABLE (1000000);
            DBMS_OUTPUT.put_line (v_str);
         ELSE
            RAISE;
         END IF;
   END;

   PROCEDURE pl (str1 IN VARCHAR2, str2 IN VARCHAR2)
   IS
   BEGIN
      pl (str1 || ' - ' || str2);
   END pl;

   PROCEDURE disp_header (str_in IN VARCHAR2)
   IS
   BEGIN
      pl ('==================');
      pl ('VALIDATE STANDARDS');
      pl ('==================');
      pl (str_in);
      pl ('');
   END disp_header;

   PROCEDURE progwith (str IN VARCHAR2)
   IS
      TYPE info_rt IS RECORD (
         NAME   user_source.NAME%TYPE
       , text   user_source.text%TYPE
      );

      TYPE info_aat IS TABLE OF info_rt
         INDEX BY PLS_INTEGER;

      info_aa   info_aat;
   BEGIN
      SELECT NAME || '-' || line
           , text
      BULK COLLECT INTO info_aa
        FROM user_source
       WHERE UPPER (text) LIKE '%' || UPPER (str) || '%'
         AND NAME != 'VALSTD'
         AND NAME != 'ERRNUMS';

      disp_header ('Checking for presence of "' || str || '"');

      FOR indx IN info_aa.FIRST .. info_aa.LAST
      LOOP
         pl (info_aa (indx).NAME, info_aa (indx).text);
      END LOOP;
   END progwith;

   PROCEDURE exception_handling
   IS
   BEGIN
      progwith ('RAISE_APPLICATION_ERROR');
      progwith ('EXCEPTION_INIT');
      progwith ('-20');
   END;

   PROCEDURE encap_compliance
   IS
      SUBTYPE qualified_name_t IS VARCHAR2 (200);

      TYPE refby_rt IS RECORD (
         NAME            qualified_name_t
       , referenced_by   qualified_name_t
      );

      TYPE refby_aat IS TABLE OF refby_rt
         INDEX BY PLS_INTEGER;

      refby_aa   refby_aat;
   BEGIN
      SELECT   owner || '.' || NAME refs_table
             , referenced_owner || '.' || referenced_name table_referenced
      BULK COLLECT INTO refby_aa
          FROM all_dependencies
         WHERE owner = USER
           AND TYPE IN ('PACKAGE', 'PACKAGE BODY', 'PROCEDURE', 'FUNCTION')
           AND referenced_type IN ('TABLE', 'VIEW')
           AND referenced_owner NOT IN ('SYS', 'SYSTEM')
      ORDER BY owner, NAME, referenced_owner, referenced_name;

      disp_header ('Programs that reference tables or views');

      FOR indx IN refby_aa.FIRST .. refby_aa.LAST
      LOOP
         pl (refby_aa (indx).NAME, refby_aa (indx).referenced_by);
      END LOOP;
   END;
END valstd;
/
