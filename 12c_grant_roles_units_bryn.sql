COLUMN Object_Name FORMAT A20
COLUMN Object_Type FORMAT A20
COLUMN Role FORMAT A20
COLUMN Table_Name FORMAT A20
COLUMN Grantor FORMAT A20
COLUMN Grantee FORMAT A20
COLUMN Granted_Role FORMAT A20
COLUMN Admin_Option FORMAT A12
COLUMN Privilege FORMAT A20
COLUMN Object_Name FORMAT A11
COLUMN Object_Type FORMAT A11
COLUMN Role FORMAT A9

CLEAR SCREEN
CONNECT Sys/Sys@HoL/My_PDB AS SYSDBA

DECLARE
   PROCEDURE drop_role (who IN VARCHAR2)
   IS
      role_does_not_exist   EXCEPTION;
      PRAGMA EXCEPTION_INIT (role_does_not_exist, -01919);
   BEGIN
      EXECUTE IMMEDIATE 'drop role ' || who || ' cascade';
   EXCEPTION
      WHEN role_does_not_exist
      THEN
         NULL;
   END drop_role;
BEGIN
   drop_role ('r_Show_t1');
   drop_role ('r_Show_t2');
END;
/

DECLARE
   PROCEDURE drop_user (who IN VARCHAR2)
   IS
      user_does_not_exist   EXCEPTION;
      PRAGMA EXCEPTION_INIT (user_does_not_exist, -01918);
   BEGIN
      EXECUTE IMMEDIATE 'drop user ' || who || ' cascade';
   EXCEPTION
      WHEN user_does_not_exist
      THEN
         NULL;
   END drop_user;
BEGIN
   drop_user ('App');
   drop_user ('Client');
END;
/

GRANT
  CREATE SESSION,
  UNLIMITED TABLESPACE,
  CREATE TABLE,
  CREATE PROCEDURE,
  CREATE ROLE
TO app IDENTIFIED BY p
/
GRANT SELECT ON dba_role_privs TO app
/
GRANT
  CREATE SESSION
TO client IDENTIFIED BY p
/
CONNECT App/p@HoL/My_PDB
--------------------------------------------------------------------------------

CREATE TABLE t1
(
   pk     INTEGER PRIMARY KEY,
   fact   VARCHAR2 (10)
)
/

CREATE TABLE t2
(
   pk     INTEGER PRIMARY KEY,
   fact   VARCHAR2 (10)
)
/

BEGIN
   INSERT INTO t1 (pk, fact)
        VALUES (1, 't1 Fact 1');

   INSERT INTO t1 (pk, fact)
        VALUES (2, 't1 Fact 2');

   INSERT INTO t2 (pk, fact)
        VALUES (1, 't2 Fact 1');

   INSERT INTO t2 (pk, fact)
        VALUES (2, 't2 Fact 2');

   COMMIT;
END;
/

CREATE PROCEDURE show_t1
   AUTHID CURRENT_USER
IS
BEGIN
   FOR j IN (  SELECT fact
                 FROM app.t1
             ORDER BY 1)
   LOOP
      DBMS_OUTPUT.put_line (j.fact);
   END LOOP;

   DBMS_OUTPUT.put_line ('');
END show_t1;
/

CREATE PROCEDURE show_t2
   AUTHID CURRENT_USER
IS
BEGIN
   FOR j IN (  SELECT fact
                 FROM app.t2
             ORDER BY 1)
   LOOP
      DBMS_OUTPUT.put_line (j.fact);
   END LOOP;

   DBMS_OUTPUT.put_line ('');
END show_t2;
/

BEGIN
   show_t1 ();
   show_t2 ();
END;
/

GRANT EXECUTE ON app.show_t1 TO client
/
GRANT EXECUTE ON app.show_t2 TO client
/

CONNECT Client/p@HoL/My_PDB

DECLARE
   table_doesnt_exist   EXCEPTION;
   PRAGMA EXCEPTION_INIT (table_doesnt_exist, -00942);
BEGIN
   BEGIN
      app.show_t1 ();
   EXCEPTION
      WHEN table_doesnt_exist
      THEN
         DBMS_OUTPUT.put_line ('ORA-0094 as expected from Show_t1');
   END;

   BEGIN
      app.show_t2 ();
   EXCEPTION
      WHEN table_doesnt_exist
      THEN
         DBMS_OUTPUT.put_line ('ORA-0094 as expected from Show_t2');
   END;
END;
/

CONNECT App/p@HoL/My_PDB

CREATE ROLE r_show_t1
/
CREATE ROLE r_show_t2
/

--------------------------------------------------------------------------------
-- Mini teaching point.
-- The creator of a role can drop it too. So App doesn't need "Drop Any Role".
-- the creator of a role has "grant with admin option" on it.

SELECT granted_role, admin_option
  FROM dba_role_privs
 WHERE grantee = 'APP'
/

DROP ROLE r_show_t1
/
DROP ROLE r_show_t2
/
CREATE ROLE r_show_t1
/
CREATE ROLE r_show_t2
/
--------------------------------------------------------------------------------

GRANT SELECT ON t1 TO r_show_t1
/
GRANT SELECT ON t2 TO r_show_t2
/
GRANT r_show_t1 TO procedure Show_t1
/
GRANT r_show_t2 TO procedure Show_t2
/

  SELECT object_name, object_type, role
    FROM user_code_role_privs
ORDER BY 1, 2
/

  SELECT table_name, grantee, privilege
    FROM user_tab_privs
   WHERE grantor = 'APP' AND table_name IN ('SHOW_T1', 'SHOW_T2', 'T1', 'T2')
ORDER BY 1, 2, 3
/

CONNECT Client/p@HoL/My_PDB

BEGIN
   app.show_t1 ();
   app.show_t2 ();
END;
/