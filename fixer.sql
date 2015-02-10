DROP TABLE stuff_to_fix;
CREATE TABLE stuff_to_fix
(stuff VARCHAR2(1000),
 fixed VARCHAR2(1));

CREATE OR REPLACE PACKAGE fixer AS

  PROCEDURE fix_stuff;
  PROCEDURE fix_this ( p_thing_to_fix VARCHAR2 );

END fixer;
/

CREATE OR REPLACE PACKAGE BODY fixer AS

  /*----------------------------------------------------------*/
  PROCEDURE fix_this ( p_thing_to_fix VARCHAR2 ) IS
  /*----------------------------------------------------------*/
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO stuff_to_fix
    (stuff,fixed)
    VALUES(p_thing_to_fix,'N');
    COMMIT;
  END fix_this;

  /*----------------------------------------------------------*/
  PROCEDURE fix_stuff IS
  /*----------------------------------------------------------*/

    CURSOR curs_get_stuff_to_fix IS
    SELECT stuff,
           ROWID
      FROM stuff_to_fix
     WHERE fixed = 'N';

  BEGIN

    FOR v_stuff_rec IN curs_get_stuff_to_fix LOOP

      EXECUTE IMMEDIATE v_stuff_rec.stuff;

      UPDATE stuff_to_fix
      SET fixed = 'Y'
      WHERE ROWID = v_stuff_rec.rowid;

    END LOOP;

    COMMIT;

  END fix_stuff;

END fixer;
/



/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
