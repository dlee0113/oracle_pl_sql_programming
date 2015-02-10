/*-- bowlerama_full_audit.sql */
CREATE OR REPLACE TRIGGER audit_frames
AFTER INSERT OR UPDATE OR DELETE ON frame
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    INSERT INTO frame_audit(bowler_id,game_id,frame_number,
                            new_strike,new_spare,new_score,
                            change_date,operation)
    VALUES(:new.bowler_id,:new.game_id,:new.frame_number,
           :new.strike,:new.spare,:new.score,
           SYSDATE,'INSERT');
  ELSIF UPDATING THEN
    INSERT INTO frame_audit(bowler_id,game_id,frame_number,
                              old_strike,new_strike,
                              old_spare,new_spare,
                            old_score,new_score,
                            change_date,operation)
    VALUES(:new.bowler_id,:new.game_id,:new.frame_number,
           :old.strike,:new.strike,
           :old.spare,:new.spare,
           :old.score,:new.score,
           SYSDATE,'UPDATE');
  ELSIF DELETING THEN
    INSERT INTO frame_audit(bowler_id,game_id,frame_number,
                            old_strike,old_spare,old_score,
                            change_date,operation)
    VALUES(:old.bowler_id,:old.game_id,:old.frame_number,
           :old.strike,:old.spare,:old.score,
           SYSDATE,'DELETE');    
  END IF;
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/
