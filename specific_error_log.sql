/*-- specific_error_log.sql */
DROP TABLE error_log;
CREATE TABLE error_log
(username     VARCHAR2(30),
 error_number NUMBER,
 sequence     NUMBER,
 timestamp    DATE);

CREATE OR REPLACE TRIGGER error_log
AFTER SERVERERROR
ON SCHEMA
BEGIN

  -- special handling of user defined errors
  -- 20000 through 20010 raised by calls to
  -- RAISE_APPLICATION_ERROR
  FOR counter IN 20000..20010 LOOP
    IF ORA_IS_SERVERERROR(counter) THEN
      DBMS_OUTPUT.PUT_LINE('error_log ' || counter);
    END IF;
  END LOOP;

  FOR counter IN -20010..-20000 LOOP
    IF ORA_IS_SERVERERROR(counter) THEN
      DBMS_OUTPUT.PUT_LINE('error_log ' || counter);
    END IF;
  END LOOP;

END;
/



/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
