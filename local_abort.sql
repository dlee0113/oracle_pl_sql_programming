CREATE OR REPLACE TRIGGER after_suspend
AFTER SUSPEND
ON SCHEMA
DECLARE

  CURSOR curs_get_sid IS
  SELECT sid
    FROM v$session
   WHERE audsid = SYS_CONTEXT('USERENV','SESSIONID');
  v_sid NUMBER;

BEGIN

  OPEN curs_get_sid;
  FETCH curs_get_sid INTO v_sid;
  CLOSE curs_get_sid;
  DBMS_RESUMABLE.ABORT(v_sid);

END;
/

SHO ERR


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
