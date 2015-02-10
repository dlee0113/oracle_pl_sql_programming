/* Create a "dummy" package so you don't have to install
   PL/Vision to get this example to work. You should NOT
   run this script inside the schema that owns PL/Vision! */
CREATE OR REPLACE PACKAGE plvddd
IS
   PROCEDURE tbl (sch IN VARCHAR2, tab IN VARCHAR2);
END;
/
CREATE OR REPLACE PACKAGE plvddd
IS
   PROCEDURE tbl (sch IN VARCHAR2, tab IN VARCHAR2) IS
   BEGIN NULL; END;
END;
/
   
BEGIN
    plvddd.tbl (USER, 'employee');
    log81.putline (1, 'Reverse engineered employee with putline');
    ROLLBACK;
    log81.saveline (1, 'Reverse engineered employee with saveline');
    ROLLBACK;
END;
/

SELECT code, text FROM log81tab;

DROP PACKAGE PLVddd;


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
