COLUMN NAME FORMAT A30
COLUMN plsql_ccflags FORMAT A30

ALTER SESSION SET plsql_ccflags = 'app_debug:TRUE';

CREATE OR REPLACE PROCEDURE test_ccflags
IS
BEGIN
   NULL;
END test_ccflags;
/

SELECT name, plsql_ccflags
  FROM user_plsql_object_settings
 WHERE NAME LIKE '%CCFLAGS%';

ALTER SESSION SET plsql_ccflags = 'app_debug:FALSE';

CREATE OR REPLACE PROCEDURE test_ccflags_new
IS
BEGIN
   NULL;
END test_ccflags_new;
/

ALTER  PROCEDURE test_ccflags COMPILE REUSE SETTINGS;

SELECT name, plsql_ccflags
  FROM user_plsql_object_settings
 WHERE NAME LIKE '%CCFLAGS%';