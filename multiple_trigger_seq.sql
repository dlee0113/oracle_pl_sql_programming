/*-- multiple_trigger_seq.sql */
DROP TABLE incremented_values;

CREATE TABLE incremented_values
(value_inserted    NUMBER,
 value_incremented NUMBER);

CREATE OR REPLACE TRIGGER increment_by_one
BEFORE INSERT ON incremented_values
FOR EACH ROW
BEGIN
  :new.value_incremented := :new.value_incremented + 1;
END;
/

CREATE OR REPLACE TRIGGER increment_by_two
BEFORE INSERT ON incremented_values
FOR EACH ROW
BEGIN
  IF :new.value_incremented > 1 THEN
    :new.value_incremented := :new.value_incremented + 2;
  END IF;
END;
/

INSERT INTO incremented_values
VALUES(1,1);

SELECT *
  FROM incremented_values;


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
