/* Formatted on 2002/02/13 10:58 (Formatter Plus v4.6.0) */
CONNECT SYSTEM/MANAGER

DROP table emp_thru_role;

CREATE TABLE emp_thru_role
 (
  empno number(4),
  ename varchar2(10),
  job varchar2(9),
  mgr number(4),
  hiredate date,
  sal number(7,2),
  comm number(7,2),
  deptno number(2)
 );
 
INSERT INTO emp_thru_role
            (empno, ename)
     VALUES (1000, 'BIG BOSS');

COMMIT ;

DROP public synonym emp_thru_role;
CREATE PUBLIC synonym emp_thru_role for emp_thru_role;

DROP role invoker_scott_emp;
CREATE ROLE invoker_scott_emp NOT identified;

DROP role invoker_system_emp;
CREATE ROLE invoker_system_emp NOT identified;
GRANT select on emp_thru_role to invoker_system_emp;

GRANT invoker_scott_emp to demo with admin option;

GRANT invoker_system_emp to demo with admin option;

CONNECT SCOTT/TIGER

DROP table emp_thru_role;
CREATE TABLE emp_thru_role as select * from emp;

GRANT select on emp_thru_role to invoker_scott_emp;

/* Formatted on 2002/02/13 15:35 (Formatter Plus v4.6.0) */
CREATE OR REPLACE PROCEDURE showcount (use_schema_in IN BOOLEAN := FALSE )
AUTHID CURRENT_USER
IS
   l_count   PLS_INTEGER;
BEGIN
   IF use_schema_in
   THEN
      SELECT COUNT (*)
        INTO l_count
        FROM scott.emp_thru_role;
      DBMS_OUTPUT.put_line ('count of scott.emp_thru_role = ' || l_count);
   ELSE
      SELECT COUNT (*)
        INTO l_count
        FROM emp_thru_role;
      DBMS_OUTPUT.put_line ('count of emp_thru_role = ' || l_count);
   END IF;

   
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (   'Error counting emp_thru_role = '
                            || SQLERRM);
END;
/

GRANT EXECUTE ON showcount TO DEMO;

CONNECT DEMO/DEMO
@@ssoo

DECLARE
   PROCEDURE setrole (role_in IN VARCHAR2)
   IS
   BEGIN
      DBMS_OUTPUT.put_line (   'Set role to '
                            || role_in);
      sys.DBMS_SESSION.set_role (role_in);
   END;
BEGIN
   setrole ('invoker_system_emp');
   scott.showcount;
   scott.showcount (TRUE);
   DBMS_OUTPUT.put_line ('');
   setrole ('invoker_scott_emp');
   scott.showcount;
   scott.showcount (TRUE);
END;

/

/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
