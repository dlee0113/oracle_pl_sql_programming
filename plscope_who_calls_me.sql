CREATE OR REPLACE PROCEDURE plch_show_usages (
   pkg_in    IN VARCHAR2,
   prog_in   IN VARCHAR2)
IS
BEGIN
   FOR rec
      IN (SELECT srch.object_name, srch.name
            FROM user_identifiers srch, user_identifiers src
           WHERE     src.object_name = pkg_in
                 AND src.object_type = 'PACKAGE'
                 and src.usage = 'DECLARATION'
                 AND src.name = prog_in
                 AND src.signature = srch.signature
                 AND srch.usage = 'CALL')
   LOOP
      DBMS_OUTPUT.put_line (rec.object_name || '.' || rec.name);
   END LOOP;
END;
/

BEGIN
   plch_show_usages ('PLSQL_DEMO', 'MY_PROCEDURE');
END;
/