CREATE OR REPLACE TRIGGER after_suspend
AFTER SUSPEND
ON DATABASE
DECLARE

  -- cursor to get the username for the current session
  CURSOR curs_get_username IS
  SELECT username
    FROM v$session
   WHERE audsid = SYS_CONTEXT('USERENV','SESSIONID');
  v_username VARCHAR2(30);

  -- cursor to get the quota for the user/tablespace
  CURSOR curs_get_ts_quota ( cp_tbspc VARCHAR2,
                             cp_user  VARCHAR2 ) IS
  SELECT max_bytes
    FROM dba_ts_quotas
   WHERE tablespace_name = cp_tbspc
     AND username = cp_user;
  v_old_quota NUMBER;
  v_new_quota NUMBER;

  -- hold information from SPACE_ERROR_INFO
  v_error_type     VARCHAR2(30);
  v_object_type    VARCHAR2(30);
  v_object_owner   VARCHAR2(30);
  v_tbspc_name     VARCHAR2(30);
  v_object_name    VARCHAR2(30);
  v_subobject_name VARCHAR2(30);

  -- SQL to fix things
  v_sql            VARCHAR2(1000);

BEGIN

  -- if this is a space related error...
  IF ORA_SPACE_ERROR_INFO ( error_type => v_error_type,
                            object_type => v_object_type,
                            object_owner => v_object_owner,
                            table_space_name => v_tbspc_name,
                            object_name => v_object_name,
                            sub_object_name => v_subobject_name ) THEN

    -- if the error is a tablespace quota being exceeded...
    IF v_error_type = 'SPACE QUOTA EXCEEDED' AND
       v_object_type = 'TABLE SPACE' THEN

      -- get the username
      OPEN curs_get_username;
      FETCH curs_get_username INTO v_username;
      CLOSE curs_get_username;

      -- get the current quota
      OPEN curs_get_ts_quota(v_object_name,v_username);
      FETCH curs_get_ts_quota INTO v_old_quota;
      CLOSE curs_get_ts_quota;

      -- create an ALTER USER statement and send it off to
      -- the fixer job because if we try it here we will raise
      -- ORA-30511: invalid DDL operation in system triggers
      v_new_quota := v_old_quota + 40960;
      v_sql := 'ALTER USER ' || v_username  || ' ' ||
               'QUOTA '      || v_new_quota || ' ' ||
               'ON '         || v_object_name;
      fixer.fix_this(v_sql);

    END IF;  -- tablespace quota exceeded

  END IF;  -- space related error

END;
/

SHO ERR


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
