CONN common/common

CREATE FUNCTION current_user1
   RETURN VARCHAR2
IS
BEGIN
   RETURN SYS_CONTEXT ('userenv', 'current_user');
END;
/

CREATE FUNCTION current_user2
   RETURN VARCHAR2
   AUTHID CURRENT_USER
IS
BEGIN
   RETURN SYS_CONTEXT ('userenv', 'current_user');
END;
/

CREATE FUNCTION current_user3
   RETURN VARCHAR2
IS
BEGIN
   RETURN current_user1;
END;
/

CREATE VIEW test22
   BEQUEATH CURRENT_USER
AS
   SELECT SYS_CONTEXT ('userenv', 'current_user') u0,
          current_user2 u1,
          current_user2 u2,
          current_user3 u3
     FROM DUAL;

CREATE VIEW test23
   BEQUEATH DEFINER
AS
   SELECT SYS_CONTEXT ('userenv', 'current_user') u0,
          current_user2 u1,
          current_user2 u2,
          current_user3 u3
     FROM DUAL;

GRANT SELECT ON test22 TO PUBLIC;
GRANT SELECT ON test23 TO PUBLIC;

COL u0 FOR a10
COL u1 FOR a10
COL u2 FOR a10
COL u3 FOR a10
SET PAGES 1000 LIN 200

CONN common/common
SELECT * FROM common.test22
UNION ALL
SELECT * FROM common.test23;

CONN northeast/northeast
SELECT * FROM common.test22
UNION ALL
SELECT * FROM common.test23;


/*
SQL> conn common/common
connected.
SQL> SELECT * FROM common.test22
2  union all
3  select * from common.test23;

u0       u1          u2     u3
---------- ---------- ---------- ----------
common       common     common     common
common       common     common     common

SQL> conn northeast/northeast
connected.
SQL> SELECT * FROM common.test22
2  union all
3  select * from common.test23;

u0       u1          u2     u3
---------- ---------- ---------- ----------
northeast  northeast  northeast  common
northeast  common     common     common

SQL> SELECT common.current_user1 u1, common.current_user2 u2, common.current_user3 u3 FROM DUAL;

u1       u2          u3
---------- ---------- ----------
common       northeast  common
*/