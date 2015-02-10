REM Create the tables

@bowlerama_tables.sql

CREATE OR REPLACE TRIGGER audit_update
   AFTER UPDATE
   ON frame
   REFERENCING OLD AS prior_to_cheat NEW AS after_cheat
   FOR EACH ROW
BEGIN
   INSERT INTO frame_audit (
                               bowler_id
                             , game_id
                             , old_score
                             , new_score
                             , change_date
                             , operation
              )
       VALUES (
                  :after_cheat.bowler_id
                , :after_cheat.game_id
                , :prior_to_cheat.score
                , :after_cheat.score
                , SYSDATE
                , 'UPDATE'
              );
END;
/

CREATE OR REPLACE TRIGGER before_insert_row
   BEFORE INSERT
   ON frame
   FOR EACH ROW
BEGIN
   DBMS_OUTPUT.put_line ('Before Insert Row');
   DBMS_OUTPUT.put_line ('Old Bowler ID ' || :old.bowler_id);
   DBMS_OUTPUT.put_line ('New Bowler ID ' || :new.bowler_id);
   DBMS_OUTPUT.put_line ('Old ROWID ' || ROWIDTOCHAR (:old.ROWID));
   DBMS_OUTPUT.put_line ('New ROWID ' || ROWIDTOCHAR (:new.ROWID));
END;
/


CREATE OR REPLACE TRIGGER after_insert_row
   AFTER INSERT
   ON frame
   FOR EACH ROW
BEGIN
   DBMS_OUTPUT.put_line ('After Insert Row');
   DBMS_OUTPUT.put_line ('Old Bowler ID ' || :old.bowler_id);
   DBMS_OUTPUT.put_line ('New Bowler ID ' || :new.bowler_id);
   DBMS_OUTPUT.put_line ('Old ROWID ' || ROWIDTOCHAR (:old.ROWID));
   DBMS_OUTPUT.put_line ('New ROWID ' || ROWIDTOCHAR (:new.ROWID));
END;
/


CREATE OR REPLACE TRIGGER before_update_row
   BEFORE UPDATE
   ON frame
   FOR EACH ROW
BEGIN
   DBMS_OUTPUT.put_line ('Before Update Row');
   DBMS_OUTPUT.put_line ('Old Bowler ID ' || :old.bowler_id);
   DBMS_OUTPUT.put_line ('New Bowler ID ' || :new.bowler_id);
   DBMS_OUTPUT.put_line ('Old ROWID ' || ROWIDTOCHAR (:old.ROWID));
   DBMS_OUTPUT.put_line ('New ROWID ' || ROWIDTOCHAR (:new.ROWID));
END;
/


CREATE OR REPLACE TRIGGER after_update_row
   AFTER UPDATE
   ON frame
   FOR EACH ROW
BEGIN
   DBMS_OUTPUT.put_line ('After Update Row');
   DBMS_OUTPUT.put_line ('Old Bowler ID ' || :old.bowler_id);
   DBMS_OUTPUT.put_line ('New Bowler ID ' || :new.bowler_id);
   DBMS_OUTPUT.put_line ('Old ROWID ' || ROWIDTOCHAR (:old.ROWID));
   DBMS_OUTPUT.put_line ('New ROWID ' || ROWIDTOCHAR (:new.ROWID));
END;
/


CREATE OR REPLACE TRIGGER before_delete_row
   BEFORE DELETE
   ON frame
   FOR EACH ROW
BEGIN
   DBMS_OUTPUT.put_line ('Before Delete Row');
   DBMS_OUTPUT.put_line ('Old Bowler ID ' || :old.bowler_id);
   DBMS_OUTPUT.put_line ('New Bowler ID ' || :new.bowler_id);
   DBMS_OUTPUT.put_line ('Old ROWID ' || ROWIDTOCHAR (:old.ROWID));
   DBMS_OUTPUT.put_line ('New ROWID ' || ROWIDTOCHAR (:new.ROWID));
END;
/


CREATE OR REPLACE TRIGGER after_delete_row
   AFTER DELETE
   ON frame
   FOR EACH ROW
BEGIN
   DBMS_OUTPUT.put_line ('After Delete Row');
   DBMS_OUTPUT.put_line ('Old Bowler ID ' || :old.bowler_id);
   DBMS_OUTPUT.put_line ('New Bowler ID ' || :new.bowler_id);
   DBMS_OUTPUT.put_line ('Old ROWID ' || ROWIDTOCHAR (:old.ROWID));
   DBMS_OUTPUT.put_line ('New ROWID ' || ROWIDTOCHAR (:new.ROWID));
END;
/


BEGIN
   INSERT INTO frame (bowler_id, game_id, frame_number, strike, spare, score
                     )
       VALUES (1, 1, 1, 'Y', 'N', NULL
              );

   UPDATE frame
      SET bowler_id = bowler_id;

   DELETE frame;
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/