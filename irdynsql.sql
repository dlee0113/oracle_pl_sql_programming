/* Formatted on 2002/02/22 08:24 (Formatter Plus v4.6.0) */
SET ECHO ON
SET FEEDBACK ON
SET VERIFY ON
SPOOL whichsch.log

CONNECT SCOTT/TIGER

CREATE OR REPLACE PROCEDURE showestack
IS
BEGIN
   p.l (RPAD ('=', 60, '='));
   p.l (DBMS_UTILITY.format_call_stack);
   p.l (RPAD ('=', 60, '='));
END;
/
REM Create reusable program containing dyn SQL as INVOKER RIGHTS

CREATE OR REPLACE PROCEDURE ir_runddl
AUTHID CURRENT_USER
IS
   l_owner   VARCHAR2 (30);
BEGIN
   --showestack;
   EXECUTE IMMEDIATE 'CREATE TABLE demo_table (col1 DATE)';

   SELECT owner
     INTO l_owner
     FROM all_objects
    WHERE object_name = 'DEMO_TABLE';

   DBMS_OUTPUT.put_line (
         '==>Successfully created '
      || ' '
      || l_owner
      || '.DEMO_TABLE'
   );
   EXECUTE IMMEDIATE 'DROP TABLE demo_table';
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (
            '==>Failed to create DEMO_TABLE'
      );
      DBMS_OUTPUT.put_line (
            '   Error: '
         || SQLERRM
      );
END;
/
CREATE OR REPLACE PROCEDURE dr_runddl
-- Overrides invoker with definer rights
IS
BEGIN
   ir_runddl;
END;
/
GRANT execute on ir_runddl to public;


GRANT execute on dr_runddl to public;


CONNECT demo/demo


CREATE OR REPLACE PROCEDURE ir_ir_runddl
AUTHID CURRENT_USER
IS
BEGIN
   DBMS_OUTPUT.put_line (
      'DEMO Invoker SCOTT Invoker'
   );
   scott.ir_runddl;
END;
/
CREATE OR REPLACE PROCEDURE dr_ir_runddl
IS
BEGIN
   DBMS_OUTPUT.put_line (
      'DEMO Definer SCOTT Invoker'
   );
   scott.ir_runddl;
END;
/
CREATE OR REPLACE PROCEDURE ir_dr_runddl
AUTHID CURRENT_USER
IS
BEGIN
   DBMS_OUTPUT.put_line (
      'DEMO Invoker SCOTT Definer'
   );
   scott.dr_runddl;
END;
/
CREATE OR REPLACE PROCEDURE dr_dr_runddl
IS
BEGIN
   DBMS_OUTPUT.put_line (
      'DEMO Definer SCOTT Definer'
   );
   scott.dr_runddl;
END;
/
DROP table demo_table;

DESC demo_table

SET FEEDBACK OFF

@@ssoo

BEGIN
   p.l (
      'Without explicit create table priv for DEMO.'
   );
   ir_ir_runddl;
   ir_dr_runddl;
   dr_ir_runddl;
   dr_dr_runddl;
END;

/

REM Try adding super privs to DEMO.

CONNECT SYSTEM/MANAGER
SET FEEDBACK OFF
GRANT create table to demo;

CONNECT demo/demo
SET FEEDBACK OFF

@@ssoo

BEGIN
   p.l (
      'Added explicit create table priv only to DEMO.'
   );
   ir_ir_runddl;
   ir_dr_runddl;
   dr_ir_runddl;
   dr_dr_runddl;
END;
/

REM Try adding super privs only to SCOTT.

CONNECT SYSTEM/MANAGER
SET FEEDBACK OFF
REVOKE create table from demo;
GRANT create table to scott;

CONNECT demo/demo
SET FEEDBACK OFF
@@ssoo

BEGIN
   p.l (
      'Added explicit create table priv only to SCOTT.'
   );
   ir_ir_runddl;
   ir_dr_runddl;
   dr_ir_runddl;
   dr_dr_runddl;
END;


/



REM Revoke super privs.



CONNECT SYSTEM/MANAGER

REVOKE create table from demo;

REVOKE create table from scott;

/*
RESULTS:

Without explicit create table priv for DEMO.
DEMO Invoker SCOTT Invoker
==>Successfully created  DEMO.DEMO_TABLE
DEMO Invoker SCOTT Definer
==>Failed to create DEMO_TABLE
   Error: ORA-01031: insufficient privileges
DEMO Definer SCOTT Invoker
==>Failed to create DEMO_TABLE
   Error: ORA-01031: insufficient privileges
DEMO Definer SCOTT Definer
==>Failed to create DEMO_TABLE
   Error: ORA-01031: insufficient privileges
   
Added explicit create table priv only to DEMO.
DEMO Invoker SCOTT Invoker
==>Successfully created  DEMO.DEMO_TABLE
DEMO Invoker SCOTT Definer
==>Failed to create DEMO_TABLE
   Error: ORA-01031: insufficient privileges
DEMO Definer SCOTT Invoker
==>Successfully created  DEMO.DEMO_TABLE
DEMO Definer SCOTT Definer
==>Failed to create DEMO_TABLE
   Error: ORA-01031: insufficient privileges
   
Added explicit create table priv only to SCOTT.
DEMO Invoker SCOTT Invoker
==>Successfully created  DEMO.DEMO_TABLE
DEMO Invoker SCOTT Definer
==>Successfully created  SCOTT.DEMO_TABLE
DEMO Definer SCOTT Invoker
==>Failed to create DEMO_TABLE
   Error: ORA-01031: insufficient privileges
DEMO Definer SCOTT Definer
==>Successfully created  SCOTT.DEMO_TABLE

*/   


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
