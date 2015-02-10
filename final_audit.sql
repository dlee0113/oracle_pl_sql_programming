/*-- final_audit.sql */

CREATE OR REPLACE TRIGGER audit_update
   AFTER UPDATE OF strike, spare, score
   ON frame
   REFERENCING OLD AS prior_to_cheat NEW AS after_cheat
   FOR EACH ROW
   WHEN (   prior_to_cheat.strike != after_cheat.strike
         OR prior_to_cheat.spare != after_cheat.spare
         OR prior_to_cheat.score != after_cheat.score)
BEGIN
   INSERT INTO frame_audit (
                               bowler_id
                             , game_id
                             , frame_number
                             , old_strike
                             , new_strike
                             , old_spare
                             , new_spare
                             , old_score
                             , new_score
                             , change_date
                             , operation
              )
       VALUES (
                  :after_cheat.bowler_id
                , :after_cheat.game_id
                , :after_cheat.frame_number
                , :prior_to_cheat.strike
                , :after_cheat.strike
                , :prior_to_cheat.spare
                , :after_cheat.spare
                , :prior_to_cheat.score
                , :after_cheat.score
                , SYSDATE
                , 'UPDATE'
              );
END;
/


/*======================================================================
| Supplement to the third edition of Oracle PL/SQL Programming by Steven
| Feuerstein with Bill Pribyl, Copyright (c) 1997-2002 O'Reilly &
| Associates, Inc. To submit corrections or find more code samples visit
| http://www.oreilly.com/catalog/oraclep3/
*/