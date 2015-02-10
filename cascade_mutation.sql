DROP TABLE detail_table;
DROP TABLE master_table;

CREATE TABLE master_table
(master_id NUMBER NOT NULL PRIMARY KEY);

CREATE TABLE detail_table
(detail_id NUMBER NOT NULL,
 master_id NUMBER NOT NULL,
   CONSTRAINT detail_to_emp
   FOREIGN KEY (master_id)
   REFERENCES master_table (master_id)
   ON DELETE CASCADE);

CREATE OR REPLACE TRIGGER after_delete_master
AFTER DELETE ON master_table
FOR EACH ROW
DECLARE
  CURSOR curs_count_detail IS
  SELECT COUNT(*)
    FROM detail_table;
  v_detail_count NUMBER;
BEGIN
  OPEN curs_count_detail;
  FETCH curs_count_detail INTO v_detail_count;
  CLOSE curs_count_detail;
END;
/

BEGIN
  FOR master_counter IN 1..10 LOOP
    INSERT INTO master_table
    VALUES(master_counter);
    FOR detail_counter IN 1..2 LOOP
      INSERT INTO detail_table
      VALUES(detail_counter,
             master_counter);
    END LOOP;
  END LOOP;
END;
/

COMMIT;

SELECT *
  FROM master_table;

SELECT *
  FROM detail_table;

DELETE master_table;

SELECT *
  FROM master_table;

SELECT *
  FROM detail_table;



/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
